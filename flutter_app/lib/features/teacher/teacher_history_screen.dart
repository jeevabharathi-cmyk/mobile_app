import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/theme.dart';

class TeacherHistoryScreen extends StatelessWidget {
  const TeacherHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Post History')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 10,
        itemBuilder: (context, index) {
          return const PostHistoryCard(
            title: 'Mathematics Assignment',
            details: 'Class 8A · 2 hours ago',
          );
        },
      ),
    );
  }
}

class PostHistoryCard extends StatelessWidget {
  final String title;
  final String details;

  const PostHistoryCard({super.key, required this.title, required this.details});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: SchoolGridTheme.primaryLight, borderRadius: BorderRadius.circular(8)),
          child: const Icon(LucideIcons.fileText, color: SchoolGridTheme.primary),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(details),
      ),
    );
  }
}
