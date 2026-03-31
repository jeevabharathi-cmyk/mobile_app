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

  Future<void> fetchHomework({String? teacherId, String? className}) async {
    _isLoading = true;
    notifyListeners();

    try {
      var query = _supabase.from('homework').select('*, doubts(*, doubt_replies(*)), acknowledgments(*)');
      
      if (teacherId != null) {
        query = query.eq('teacher_id', teacherId);
      }
      if (className != null) {
        query = query.ilike('class_name', '%$className%');
      }

      final response = await query.order('created_at', ascending: false);
      
      // Map response to Homework models (assuming models are updated or using fromMap)
      _homeworks = (response as List).map((hw) => Homework.fromMap(hw)).toList();
    } catch (e) {
      debugPrint('Error fetching homework: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> postHomework({
    required String title,
    required String description,
    required String className,
    required DateTime dueDate,
  }) async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    try {
      await _supabase.from('homework').insert({
        'title': title,
        'description': description,
        'class_name': className,
        'due_date': dueDate.toIso8601String(),
        'teacher_id': user.id,
      });
      
      await fetchHomework(teacherId: user.id);
      
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
