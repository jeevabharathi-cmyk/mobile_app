import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserProfile {
  final String id;
  final String fullName;
  final String role;
  final String? email;
  final String? phone;
  final String? schoolId;
  final String? avatarUrl;

  UserProfile({
    required this.id,
    required this.fullName,
    required this.role,
    this.email,
    this.phone,
    this.schoolId,
    this.avatarUrl,
  });

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      id: map['id'],
      fullName: map['full_name'] ?? '',
      role: map['role'] ?? '',
      email: map['email'],
      phone: map['phone'],
      schoolId: map['school_id'],
      avatarUrl: map['avatar_url'],
    );
  }
}

class TeacherClass {
  final String classId;
  final String sectionId;
  final String subjectId;
  final String className;
  final String subject;
  final String schedule;

  TeacherClass({
    required this.classId,
    required this.sectionId,
    required this.subjectId,
    required this.className,
    required this.subject,
    required this.schedule,
  });
}

class ChildInfo {
  final String studentId;
  final String parentId;
  final String classId;
  final String sectionId;
  final String fullName;
  final String className;
  final String sectionName;

  ChildInfo({
    required this.studentId,
    required this.parentId,
    required this.classId,
    required this.sectionId,
    required this.fullName,
    required this.className,
    required this.sectionName,
  });

  String get displayLabel => '$fullName · $className$sectionName';
}

class UserService extends ChangeNotifier {
  final _supabase = Supabase.instance.client;
  UserProfile? _profile;
  String? _teacherId;
  List<TeacherClass> _teacherClasses = [];
  List<ChildInfo> _children = [];
  bool _isLoading = false;
  StreamSubscription? _teacherAssignmentsSubscription;
  StreamSubscription? _teacherTableSubscription;

  UserProfile? get profile => _profile;
  String? get teacherId => _teacherId;
  List<TeacherClass> get teacherClasses => _teacherClasses;
  List<ChildInfo> get children => _children;
  bool get isLoading => _isLoading;

  Future<void> fetchProfile() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      final response = await _supabase
          .from('profiles')
          .select()
          .eq('id', user.id)
          .single();
      
      _profile = UserProfile.fromMap(response);

      if (_profile?.role == 'teacher') {
        await _fetchTeacherData();
      } else if (_profile?.role == 'parent') {
        await _fetchParentData();
      }
    } catch (e) {
      debugPrint('Error fetching profile: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _fetchTeacherData() async {
    try {
      debugPrint('Fetching teacher data for profile: ${_profile!.id}');
      
      // 1. First try to get ALL teachers to debug RLS
      final allTeachers = await _supabase
          .from('teachers')
          .select('id, full_name, profile_id');
      debugPrint('All visible teachers: $allTeachers');
      
      // 2. Get the actual Teacher record linked to this profile
      final teacherRes = await _supabase
          .from('teachers')
          .select('id')
          .eq('profile_id', _profile!.id)
          .maybeSingle();

      debugPrint('Teacher query result: $teacherRes');

      if (teacherRes == null) {
        debugPrint('No teacher record found for profile ${_profile!.id}');
        return;
      }

      _teacherId = teacherRes['id'];
      final teacherId = _teacherId;

      // 1. Setup real-time listener for the teacher's own record (to catch array updates)
      _teacherTableSubscription?.cancel();
      _teacherTableSubscription = _supabase
          .from('teachers')
          .stream(primaryKey: ['id'])
          .eq('id', teacherId!)
          .listen((data) {
            debugPrint('Real-time: Teacher record changed for $teacherId');
            _fetchTeacherData(); 
          });

      // 2. Fetch all classes, sections, and subjects for lookup
      final classesRes = await _supabase.from('classes').select('id, name');
      final sectionsRes = await _supabase.from('sections').select('id, name, class_id');
      final subjectsRes = await _supabase.from('subjects').select('id, name');

      final List<dynamic> allAddClasses = classesRes as List;
      final List<dynamic> allAddSections = sectionsRes as List;
      final List<dynamic> allAddSubjects = subjectsRes as List;

      // 3. Fetch teacher assignments with IDs and names
      final response = await _supabase
          .from('teacher_assignments')
          .select('''
            class_id,
            section_id,
            subject_id,
            classes (name),
            sections (name),
            subjects (name)
          ''')
          .eq('teacher_id', teacherId as Object);

      final List<TeacherClass> assignments = (response as List).map((item) {
        final className = item['classes']['name'];
        final sectionName = item['sections']['name'];
        final subjectName = item['subjects']['name'];
        return TeacherClass(
          classId: item['class_id'],
          sectionId: item['section_id'],
          subjectId: item['subject_id'],
          className: '$className$sectionName',
          subject: subjectName,
          schedule: 'Assigned',
        );
      }).toList();

      // Look into teachers table classes array to see if any are not in teacher_assignments
      // We need to fetch the classes array from a fresh query since the first one was limited
      final teacherArrRes = await _supabase.from('teachers').select('classes, subjects').eq('id', teacherId).single();
      final List<dynamic> teacherClassesArr = teacherArrRes['classes'] ?? [];
      final List<dynamic> teacherSubjectsArr = teacherArrRes['subjects'] ?? [];

      for (var clsName in teacherClassesArr) {
        final String nameStr = clsName.toString().toLowerCase();
        bool exists = assignments.any((a) => a.className.toLowerCase().contains(nameStr));
        
        if (!exists) {
          final matchedClass = allAddClasses.firstWhere(
            (c) => c['name'].toString().toLowerCase().contains(nameStr),
            orElse: () => <String, dynamic>{},
          );

          if (matchedClass.isNotEmpty) {
            final classId = matchedClass['id'] ?? '';
            final matchedSection = allAddSections.firstWhere(
              (s) => s['class_id'] == classId,
              orElse: () => <String, dynamic>{},
            );
            final sectionId = matchedSection['id'] ?? '';
            
            final String subjectName = teacherSubjectsArr.isNotEmpty ? teacherSubjectsArr[0].toString() : 'General';
            final matchedSubject = allAddSubjects.firstWhere(
              (s) => s['name'].toString().toLowerCase() == subjectName.toLowerCase(),
              orElse: () => <String, dynamic>{},
            );
            final subjectId = matchedSubject['id'] ?? '';

            if (classId.toString().isNotEmpty) {
              assignments.add(TeacherClass(
                classId: classId,
                sectionId: sectionId,
                subjectId: subjectId,
                className: matchedClass['name'] ?? 'Class',
                subject: subjectName,
                schedule: 'Admin Assigned',
              ));
            }
          }
        }
      }

      _teacherClasses = assignments;
      notifyListeners();

      // 3. Setup real-time listener for assignments
      _teacherAssignmentsSubscription?.cancel();
      _teacherAssignmentsSubscription = _supabase
          .from('teacher_assignments')
          .stream(primaryKey: ['id'])
          .eq('teacher_id', teacherId)
          .listen((data) {
            debugPrint('Real-time: Teacher assignments changed for $teacherId');
            _fetchTeacherData();
          });
    } catch (e) {
      debugPrint('Error fetching teacher data: $e');
    }
  }

  Future<void> _fetchParentData() async {
    try {
      debugPrint('Fetching parent data for profile: ${_profile!.id}');
      
      final response = await _supabase
          .from('student_parents')
          .select('''
            student_id,
            parent_id,
            students (
              id,
              name,
              class_id,
              section_id,
              classes (id, name),
              sections (id, name)
            )
          ''')
          .eq('parent_id', _profile!.id);

      debugPrint('Parent student links response: $response');

      final List<dynamic> data = response as List<dynamic>;
      _children = data.map((link) {
        final student = link['students'] as Map<String, dynamic>?;
        if (student == null) return null;

        final classes = student['classes'] as Map<String, dynamic>?;
        final sections = student['sections'] as Map<String, dynamic>?;

        return ChildInfo(
          studentId: student['id'] ?? '',
          parentId: link['parent_id'] ?? '',
          classId: (student['class_id'] ?? '').toString().trim(),
          sectionId: (student['section_id'] ?? '').toString().trim(),
          fullName: student['name'] ?? 'Unknown',
          className: classes?['name'] ?? 'N/A',
          sectionName: sections?['name'] ?? '',
        );
      }).whereType<ChildInfo>().toList();
      
      debugPrint('Fetched ${_children.length} children');
    } catch (e) {
      debugPrint('Error fetching parent data: $e');
    }
  }

  void clear() {
    _profile = null;
    _teacherClasses = [];
    _children = [];
    _teacherAssignmentsSubscription?.cancel();
    _teacherAssignmentsSubscription = null;
    _teacherTableSubscription?.cancel();
    _teacherTableSubscription = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _teacherAssignmentsSubscription?.cancel();
    _teacherTableSubscription?.cancel();
    super.dispose();
  }
}
