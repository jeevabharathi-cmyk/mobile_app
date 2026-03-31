import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/homework_models.dart';
import 'notification_service.dart';

class HomeworkService extends ChangeNotifier {
  final _supabase = Supabase.instance.client;
  List<Homework> _homeworks = [];
  bool _isLoading = false;

  List<Homework> get homeworks => List.unmodifiable(_homeworks);
  bool get isLoading => _isLoading;

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
    _isLoading = true;
    notifyListeners();

    try {
      var query = _supabase.from('homework').select('*, doubts(*, doubt_replies(*), students(name)), acknowledgments(*), classes(name), sections(name), subjects(name)');
      
      if (teacherId != null) {
        query = query.eq('teacher_id', teacherId);
      }
      if (classId != null) {
        query = query.eq('class_id', classId);
      }

      final response = await query.order('created_at', ascending: false);
      
      // map response to Homework models
      _homeworks = (response as List).map((hw) => Homework.fromMap(hw)).toList();
    } catch (e) {
      debugPrint('Error fetching homework: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addDoubt({
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
    } catch (e) {
      debugPrint('Error adding doubt: $e');
    }
  }

  Future<void> replyToDoubt({
    required String doubtId,
    required String teacherId,
    required String content,
  }) async {
    try {
      await _supabase.from('doubt_replies').insert({
        'doubt_id': doubtId,
        'teacher_id': teacherId,
        'content': content,
      });
      
      await fetchHomework();
      debugPrint('Event: Doubt Answered');
    } catch (e) {
      debugPrint('Error replying to doubt: $e');
    }
  }

  Future<void> postHomework({
    required String title,
    required String description,
    required String classId,
    required String sectionId,
    required String subjectId,
    required String teacherId,
    required DateTime dueDate,
  }) async {
    try {
      await _supabase.from('homework').insert({
        'teacher_id': teacherId,
        'class_id': classId,
        'section_id': sectionId,
        'subject_id': subjectId,
        'title': title,
        'description': description,
        'due_date': '${dueDate.year}-${dueDate.month.toString().padLeft(2, '0')}-${dueDate.day.toString().padLeft(2, '0')}',
      });
      
      await fetchHomework(teacherId: teacherId);
      
      debugPrint('Event: Homework Posted');
    } catch (e) {
      debugPrint('Error posting homework: $e');
    }
  }

  Future<void> acknowledgeHomework({
    required String homeworkId,
    required String studentName,
    required String applicationNumber,
  }) async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    try {
      await _supabase.from('acknowledgments').insert({
        'homework_id': homeworkId,
        'student_name': studentName,
        'application_number': applicationNumber,
        'parent_id': user.id,
      });
      
      // Update local state if needed or refetch
      await fetchHomework(); // Or more specific fetch
    } catch (e) {
      debugPrint('Error acknowledging homework: $e');
    }
  }
  
  // Note: addDoubt and replyToDoubt would similarly use _supabase.from('doubts').insert(...)
}
