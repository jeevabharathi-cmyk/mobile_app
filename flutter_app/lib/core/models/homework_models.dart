import 'package:flutter/foundation.dart';

enum DoubtStatus {
  unanswered,
  answered,
}

class DoubtReply {
  final String teacherId;
  final String teacherName;
  final String content;
  final DateTime timestamp;

  DoubtReply({
    required this.teacherId,
    required this.teacherName,
    required this.content,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
    'teacherId': teacherId,
    'teacherName': teacherName,
    'content': content,
    'timestamp': timestamp.toIso8601String(),
  };

  factory DoubtReply.fromMap(Map<String, dynamic> map) => DoubtReply(
    teacherId: map['teacher_id'],
    teacherName: map['teacher_name'],
    content: map['content'],
    timestamp: DateTime.parse(map['created_at']),
  );
}

class Doubt {
  final String id;
  final String homeworkId;
  final String studentId;
  final String studentName;
  final String content;
  final DateTime timestamp;
  DoubtStatus status;
  DoubtReply? reply;

  Doubt({
    required this.id,
    required this.homeworkId,
    required this.studentId,
    required this.studentName,
    required this.content,
    required this.timestamp,
    this.status = DoubtStatus.unanswered,
    this.reply,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'homeworkId': homeworkId,
    'studentId': studentId,
    'studentName': studentName,
    'content': content,
    'timestamp': timestamp.toIso8601String(),
    'status': status.name,
    'reply': reply?.toJson(),
  };

  factory Doubt.fromJson(Map<String, dynamic> json) => Doubt(
    id: json['id'],
    homeworkId: json['homeworkId'],
    studentId: json['studentId'],
    studentName: json['studentName'],
    content: json['content'],
    timestamp: DateTime.parse(json['timestamp']),
    status: DoubtStatus.values.byName(json['status']),
    reply: json['reply'] != null ? DoubtReply.fromJson(json['reply']) : null,
  );

  factory Doubt.fromMap(Map<String, dynamic> map) {
    var studentName = 'Student';
    if (map['students'] != null) {
      studentName = map['students']['name'] ?? 'Student';
    }

    return Doubt(
      id: map['id'].toString(),
      homeworkId: map['homework_id'].toString(),
      studentId: map['student_id'] ?? '',
      studentName: studentName,
      content: map['content'] ?? '',
      timestamp: DateTime.parse(map['created_at']),
      status: map['status'] == 'answered' ? DoubtStatus.answered : DoubtStatus.unanswered,
      reply: (map['doubt_replies'] != null && (map['doubt_replies'] as List).isNotEmpty)
          ? DoubtReply.fromMap((map['doubt_replies'] as List).first)
          : null,
    );
  }
}

class HomeworkAcknowledgment {
  final String studentName;
  final String applicationNumber;
  final DateTime timestamp;

  HomeworkAcknowledgment({
    required this.studentName,
    required this.applicationNumber,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
    'studentName': studentName,
    'applicationNumber': applicationNumber,
    'timestamp': timestamp.toIso8601String(),
  };

  factory HomeworkAcknowledgment.fromJson(Map<String, dynamic> json) => HomeworkAcknowledgment(
    studentName: json['studentName'],
    applicationNumber: json['applicationNumber'],
    timestamp: DateTime.parse(json['timestamp']),
  );

  factory HomeworkAcknowledgment.fromMap(Map<String, dynamic> map) => HomeworkAcknowledgment(
    studentName: map['student_name'] ?? '',
    applicationNumber: map['application_number'] ?? '',
    timestamp: DateTime.parse(map['created_at']),
  );
}

class Homework {
  final String id;
  final String title;
  final String description;
  final String className;
  final DateTime dueDate;
  final DateTime postedAt;
  final List<Doubt> doubts;
  final List<HomeworkAcknowledgment> acknowledgments;

  Homework({
    required this.id,
    required this.title,
    required this.description,
    required this.className,
    required this.dueDate,
    required this.postedAt,
    this.doubts = const [],
    this.acknowledgments = const [],
  });

  int get totalDoubts => doubts.length;
  int get answeredDoubts => doubts.where((d) => d.status == DoubtStatus.answered).length;
  int get unansweredDoubts => totalDoubts - answeredDoubts;
  int get totalAcknowledgments => acknowledgments.length;

  factory Homework.fromMap(Map<String, dynamic> map) {
    // Handle joins for names
    final className = map['classes']?['name'] ?? '';
    final sectionName = map['sections']?['name'] ?? '';
    final subjectName = map['subjects']?['name'] ?? '';

    return Homework(
      id: map['id'].toString(),
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      className: '$className$sectionName - $subjectName',
      dueDate: DateTime.parse(map['due_date']),
      postedAt: DateTime.parse(map['created_at']),
      doubts: (map['doubts'] as List? ?? []).map((d) => Doubt.fromMap(d)).toList(),
      acknowledgments: (map['acknowledgments'] as List? ?? [])
          .map((a) => HomeworkAcknowledgment.fromMap(a))
          .toList(),
    );
  }

  Homework copyWith({
    List<Doubt>? doubts,
    List<HomeworkAcknowledgment>? acknowledgments,
  }) {
    return Homework(
      id: id,
      title: title,
      description: description,
      className: className,
      dueDate: dueDate,
      postedAt: postedAt,
      doubts: doubts ?? this.doubts,
      acknowledgments: acknowledgments ?? this.acknowledgments,
    );
  }
}
