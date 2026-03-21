import 'package:flutter/material.dart';
import '../../core/theme.dart';
import 'package:provider/provider.dart';
import '../../core/services/homework_service.dart';
import 'package:intl/intl.dart';

class ParentHistoryScreen extends StatelessWidget {
  const ParentHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final homeworkService = context.watch<HomeworkService>();
    final homeworks = homeworkService.homeworks;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Homework History'),
        backgroundColor: Colors.white,
        foregroundColor: SchoolGridTheme.primary,
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildSummaryCard(),
          const Divider(height: 1),
          Expanded(
            child: homeworks.isEmpty
                ? const Center(child: Text('No history found'))
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: homeworks.length,
                    itemBuilder: (context, index) {
                      final hw = homeworks[index];
                      return _HistoryCard(homework: hw);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Academic Overview',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF64748B)),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStatItem('Assignments', '24', Colors.blue),
              _buildStatItem('Completed', '22', Colors.green),
              _buildStatItem('Pending', '2', Colors.orange),
              _buildStatItem('Attendance', '98%', Colors.purple),
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

class _HistoryCard extends StatelessWidget {
  final dynamic homework;

  const _HistoryCard({required this.homework});

  @override
  Widget build(BuildContext context) {
    bool isAcknowledged = homework.acknowledgments.any((a) => a.applicationNumber == 'APP-2024-001');

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade100),
      ),
      elevation: 0,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: isAcknowledged ? const Color(0xFFF0FDF4) : const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            isAcknowledged ? Icons.check_circle_outline : Icons.history,
            color: isAcknowledged ? Colors.green : SchoolGridTheme.primary,
          ),
        ),
        title: Text(homework.title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            'Child: Aarav Mehta · ${DateFormat('MMM d, yyyy').format(homework.postedAt)}',
            style: const TextStyle(fontSize: 12),
          ),
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: isAcknowledged ? const Color(0xFFDCFCE7) : const Color(0xFFFFEDD5),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            isAcknowledged ? 'Completed' : 'Pending',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: isAcknowledged ? Colors.green[700] : Colors.orange[700],
            ),
          ),
        ),
      ),
    );
  }
}
