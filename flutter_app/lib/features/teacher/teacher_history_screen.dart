import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/theme.dart';

import 'package:provider/provider.dart';
import '../../core/services/homework_service.dart';
import '../../core/models/homework_models.dart';
import 'package:intl/intl.dart';

class TeacherHistoryScreen extends StatelessWidget {
  const TeacherHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final homeworkService = context.watch<HomeworkService>();
    final homeworks = homeworkService.homeworks;
    final stats = homeworkService.getStats();

    return Scaffold(
      appBar: AppBar(title: const Text('Post History')),
      body: Column(
        children: [
          _buildEngagementStats(stats),
          const Divider(height: 1),
          Expanded(
            child: homeworks.isEmpty
                ? const Center(child: Text('No history found'))
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: homeworks.length,
                    itemBuilder: (context, index) {
                      final hw = homeworks[index];
                      return PostHistoryCard(homework: hw);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEngagementStats(Map<String, dynamic> stats) {
    return Container(
      padding: const EdgeInsets.all(20),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Doubt Engagement',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF64748B)),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStatItem('Total', stats['totalDoubts'].toString(), Colors.blue),
              _buildStatItem('Answered', stats['answeredCount'].toString(), Colors.green),
              _buildStatItem('Acks', stats['totalAcks'].toString(), Colors.purple),
              _buildStatItem('Avg Time', stats['avgResponseTime'], Colors.orange),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
      ],
    );
  }
}

class PostHistoryCard extends StatelessWidget {
  final Homework homework;

  const PostHistoryCard({super.key, required this.homework});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: SchoolGridTheme.primaryLight, borderRadius: BorderRadius.circular(8)),
          child: const Icon(LucideIcons.fileText, color: SchoolGridTheme.primary),
        ),
        title: Text(homework.title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text('${homework.className} · ${DateFormat('MMM d').format(homework.postedAt)}'),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text('${homework.totalDoubts} doubts', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            Text(
              homework.unansweredDoubts == 0 ? 'All Answered' : '${homework.unansweredDoubts} pending',
              style: TextStyle(
                fontSize: 10,
                color: homework.unansweredDoubts == 0 ? Colors.green : Colors.orange,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
