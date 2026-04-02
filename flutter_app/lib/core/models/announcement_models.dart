import 'package:flutter/foundation.dart';

class Announcement {
  final String id;
  final String title;
  final String content;
  final DateTime createdAt;
  final String priority;

  Announcement({
    required this.id,
    required this.title,
    required this.content,
    required this.createdAt,
    required this.priority,
  });

  factory Announcement.fromMap(Map<String, dynamic> map) {
    return Announcement(
      id: map['id'].toString(),
      title: map['title'] ?? '',
      content: map['content'] ?? '',
      createdAt: DateTime.parse(map['created_at']),
      priority: map['priority'] ?? 'normal',
    );
  }
}
