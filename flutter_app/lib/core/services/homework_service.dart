import 'package:flutter/foundation.dart';
import '../models/homework_models.dart';
import 'notification_service.dart';

class HomeworkService extends ChangeNotifier {
  final List<Homework> _homeworks = [];
  
  List<Homework> get homeworks => List.unmodifiable(_homeworks);

  void postHomework({
    required String title,
    required String description,
    required String className,
    required DateTime dueDate,
  }) {
    final homework = Homework(
      id: 'HW-${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      description: description,
      className: className,
      dueDate: dueDate,
      postedAt: DateTime.now(),
    );
    _homeworks.insert(0, homework);
    notifyListeners();
    
    // Log operation
    debugPrint('Event: Homework Posted ID=${homework.id}');
  }

  void addDoubt({
    required String homeworkId,
    required String studentId,
    required String studentName,
    required String content,
  }) {
    final index = _homeworks.indexWhere((hw) => hw.id == homeworkId);
    if (index != -1) {
      final doubt = Doubt(
        id: 'DBT-${DateTime.now().millisecondsSinceEpoch}',
        homeworkId: homeworkId,
        studentId: studentId,
        studentName: studentName,
        content: content,
        timestamp: DateTime.now(),
      );
      
      final updatedHomework = _homeworks[index].copyWith(
        doubts: [..._homeworks[index].doubts, doubt],
      );
      _homeworks[index] = updatedHomework;
      notifyListeners();

      // Real-time notification to teacher (simulated)
      NotificationService.instance.notifyTeacher(
        'New Doubt',
        'A new doubt has been posted by $studentName for "${_homeworks[index].title}"',
      );

      debugPrint('Event: Doubt Submitted ID=${doubt.id} HWID=$homeworkId');
    }
  }

  void replyToDoubt({
    required String homeworkId,
    required String doubtId,
    required String teacherId,
    required String teacherName,
    required String content,
  }) {
    final hwIndex = _homeworks.indexWhere((hw) => hw.id == homeworkId);
    if (hwIndex != -1) {
      final doubts = List<Doubt>.from(_homeworks[hwIndex].doubts);
      final dbtIndex = doubts.indexWhere((d) => d.id == doubtId);
      
      if (dbtIndex != -1) {
        doubts[dbtIndex].status = DoubtStatus.answered;
        doubts[dbtIndex].reply = DoubtReply(
          teacherId: teacherId,
          teacherName: teacherName,
          content: content,
          timestamp: DateTime.now(),
        );

        final updatedHomework = _homeworks[hwIndex].copyWith(doubts: doubts);
        _homeworks[hwIndex] = updatedHomework;
        notifyListeners();

        // Real-time notification to student (simulated)
        NotificationService.instance.notifyStudent(
          doubts[dbtIndex].studentId,
          'Doubt Answered',
          'Teacher $teacherName answered your doubt on "${_homeworks[hwIndex].title}"',
        );

        debugPrint('Event: Doubt Answered ID=$doubtId HWID=$homeworkId');
      }
    }
  }

  void acknowledgeHomework({
    required String homeworkId,
    required String studentName,
    required String applicationNumber,
  }) {
    final index = _homeworks.indexWhere((hw) => hw.id == homeworkId);
    if (index != -1) {
      // Check if already acknowledged by this application number
      final exists = _homeworks[index].acknowledgments.any((a) => a.applicationNumber == applicationNumber);
      if (exists) return;

      final ack = HomeworkAcknowledgment(
        studentName: studentName,
        applicationNumber: applicationNumber,
        timestamp: DateTime.now(),
      );

      final updatedHomework = _homeworks[index].copyWith(
        acknowledgments: [..._homeworks[index].acknowledgments, ack],
      );
      _homeworks[index] = updatedHomework;
      notifyListeners();

      debugPrint('Event: Acknowledged ID=$homeworkId Student=$studentName Time=${ack.timestamp}');
    }
  }

  // Stats for the user
  Map<String, dynamic> getStats() {
    int total = 0;
    int answered = 0;
    int totalAcks = 0;
    Duration totalResponseTime = Duration.zero;
    int responseCount = 0;

    for (var hw in _homeworks) {
      total += hw.totalDoubts;
      answered += hw.answeredDoubts;
      totalAcks += hw.totalAcknowledgments;
      
      for (var doubt in hw.doubts) {
        if (doubt.reply != null) {
          totalResponseTime += doubt.reply!.timestamp.difference(doubt.timestamp);
          responseCount++;
        }
      }
    }

    return {
      'totalDoubts': total,
      'answeredCount': answered,
      'unansweredCount': total - answered,
      'totalAcks': totalAcks,
      'avgResponseTime': responseCount > 0 
          ? (totalResponseTime.inMinutes / responseCount).toStringAsFixed(1) + ' mins'
          : 'N/A',
    };
  }
}
