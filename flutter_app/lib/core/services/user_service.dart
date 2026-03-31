import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserProfile {
  final String id;
  final String fullName;
  final String role;
  final String? email;
  final String? schoolId;
  final String? avatarUrl;

  UserProfile({
    required this.id,
    required this.fullName,
    required this.role,
    this.email,
    this.schoolId,
    this.avatarUrl,
  });

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      id: map['id'],
      fullName: map['full_name'] ?? '',
      role: map['role'] ?? '',
      email: map['email'],
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
      // 1. Get the actual Teacher record linked to this profile
      final teacherRes = await _supabase
          .from('teachers')
          .select('id')
          .eq('profile_id', _profile!.id)
          .maybeSingle();

      if (teacherRes == null) {
        debugPrint('No teacher record found for profile ${_profile!.id}');
        return;
      }

      _teacherId = teacherRes['id'];
      final teacherId = _teacherId;

      // 2. Fetch teacher assignments with IDs and names
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
          .eq('teacher_id', teacherId);

      _teacherClasses = (response as List).map((item) {
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
    } catch (e) {
      debugPrint('Error fetching teacher data: $e');
    }
  }

  Future<void> _fetchParentData() async {
    try {
      // Fetch students linked to this parent via student_parents table
      final response = await _supabase
          .from('student_parents')
          .select('''
            parent_id,
            students (
              id,
              full_name,
              class_id,
              section_id,
              classes (name),
              sections (name)
            )
          ''')
          .eq('parent_id', _profile!.id);

      _children = (response as List).map((item) {
        final student = item['students'];
        return ChildInfo(
          studentId: student['id'],
          parentId: item['parent_id'],
          classId: student['class_id'],
          sectionId: student['section_id'],
          fullName: student['full_name'],
          className: student['classes']['name'],
          sectionName: student['sections']['name'],
        );
      }).toList();
    } catch (e) {
      debugPrint('Error fetching parent data: $e');
    }
  }

  void clear() {
    _profile = null;
    _teacherClasses = [];
    _children = [];
    notifyListeners();
  }
}
