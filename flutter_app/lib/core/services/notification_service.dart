import 'package:flutter/material.dart';

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  void notifyTeacher(String title, String body) {
    // In a real app, this would use FCM or a similar service
    debugPrint('NOTIFICATION [TEACHER]: $title - $body');
  }

  void notifyStudent(String studentId, String title, String body) {
    // In a real app, this would target a specific student
    debugPrint('NOTIFICATION [STUDENT ID=$studentId]: $title - $body');
  }

  void logEvent(String role, String event, String details) {
    debugPrint('EVENT LOG [$role]: $event - $details');
  }
}
