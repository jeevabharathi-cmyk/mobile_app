import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/homework_models.dart';
import 'notification_service.dart';

class HomeworkService extends ChangeNotifier {
  final _supabase = Supabase.instance.client;
  List<Homework> _homeworks = [];
  bool _isLoading = false;
  
  String? _currentTeacherId;
  String? _currentClassId;

  List<Homework> get homeworks => List.unmodifiable(_homeworks);
  bool get isLoading => _isLoading;

  void clearFilters() {
    _currentTeacherId = null;
    _currentClassId = null;
  }

  Map<String, dynamic> getStats() {
    int totalDoubts = 0;
    int answeredCount = 0;
    int totalAcks = 0;

    for (var hw in _homeworks) {
      totalDoubts += hw.totalDoubts;
      answeredCount += hw.answeredDoubts;
      totalAcks += hw.totalAcknowledgments;
    }

    return {
      'totalDoubts': totalDoubts,
      'answeredCount': answeredCount,
      'totalAcks': totalAcks,
      'avgResponseTime': '2.5h', // Mocked or calculated if needed
    };
  }

  Future<void> fetchHomework({String? teacherId, String? classId}) async {
    if (teacherId != null) _currentTeacherId = teacherId;
    if (classId != null) _currentClassId = classId;

    _isLoading = true;
    notifyListeners();

    try {
      var query = _supabase.from('homework').select('*, doubts(*, doubt_replies(*), students(name)), acknowledgments(*), classes(name), sections(name), subjects(name)');
      
      if (_currentTeacherId != null) {
        query = query.eq('teacher_id', _currentTeacherId!);
      }
      if (_currentClassId != null) {
        query = query.eq('class_id', _currentClassId!);
      }

      final response = await query.order('created_at', ascending: false);
      
      // map response to Homework models
      _homeworks = (response as List).map((hw) => Homework.fromMap(hw)).toList();
    } catch (e) {
      debugPrint('CRITICAL: Error fetching homework: $e');
      if (e is PostgrestException) {
        debugPrint('Postgrest details: ${e.message}, ${e.details}, ${e.hint}');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addDoubt({
    required String homeworkId,
    required String studentId,
    required String parentId,
    required String content,
  }) async {
    try {
      await _supabase.from('doubts').insert({
        'homework_id': homeworkId,
        'student_id': studentId,
        'parent_id': parentId,
        'content': content,
      });
      
      await fetchHomework(); 
      debugPrint('Event: Doubt Submitted');
      return true;
    } catch (e) {
      debugPrint('Error adding doubt: $e');
      return false;
    }
  }

  Future<bool> replyToDoubt({
    required String doubtId,
    required String teacherId,
    required String teacherName,
    required String content,
  }) async {
    try {
      await _supabase.from('doubt_replies').insert({
        'doubt_id': doubtId,
        'teacher_id': teacherId,
        'teacher_name': teacherName,
        'content': content,
      });

      await _supabase.from('doubts').update({'status': 'answered'}).eq('id', doubtId);
      
      await fetchHomework(teacherId: teacherId);
      debugPrint('Event: Doubt Answered');
      return true;
    } catch (e) {
      debugPrint('Error replying to doubt: $e');
      return false;
    }
  }

  Future<bool> postHomework({
    required String title,
    required String description,
    required String classId,
    required String sectionId,
    required String subjectId,
    required String teacherId,
    required DateTime dueDate,
    List<PlatformFile>? attachments,
  }) async {
    try {
      final response = await _supabase.from('homework').insert({
        'teacher_id': teacherId,
        'class_id': classId,
        'section_id': sectionId,
        'subject_id': subjectId,
        'title': title,
        'description': description,
        'due_date': '${dueDate.year}-${dueDate.month.toString().padLeft(2, '0')}-${dueDate.day.toString().padLeft(2, '0')}',
      }).select().single();
      
      final homeworkId = response['id'];

      // Handle attachments if any
      if (attachments != null && attachments.isNotEmpty) {
        for (var file in attachments) {
          if (file.path != null) {
            final fileName = '${DateTime.now().millisecondsSinceEpoch}_${file.name}';
            final path = 'homework/$homeworkId/$fileName';
            
            await _supabase.storage.from('attachments').upload(
              path,
              File(file.path!),
            );

            final fileUrl = _supabase.storage.from('attachments').getPublicUrl(path);

            await _supabase.from('attachments').insert({
              'parent_type': 'homework',
              'parent_id': homeworkId,
              'file_url': fileUrl,
              'file_name': file.name,
              'file_size': file.size,
              'mime_type': file.extension,
            });
          }
        }
      }
      
      await fetchHomework(teacherId: teacherId);
      debugPrint('Event: Homework Posted');
      return true;
    } catch (e) {
      debugPrint('Error posting homework: $e');
      return false;
    }
  }

  Future<bool> acknowledgeHomework({
    required String homeworkId,
    required String studentId,
    required String studentName,
    required String applicationNumber,
  }) async {
    final user = _supabase.auth.currentUser;
    if (user == null) return false;

    try {
      await _supabase.from('acknowledgments').insert({
        'homework_id': homeworkId,
        'student_id': studentId,
        'student_name': studentName,
        'application_number': applicationNumber,
        'parent_id': user.id,
      });
      
      await fetchHomework(); 
      debugPrint('Event: Homework Acknowledged');
      return true;
    } catch (e) {
      debugPrint('Error acknowledging homework: $e');
      return false;
    }
  }
  
}
