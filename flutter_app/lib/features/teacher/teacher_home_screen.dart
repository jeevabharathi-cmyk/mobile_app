import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/theme.dart';
import 'post_homework_modal.dart';

class TeacherHomeScreen extends StatelessWidget {
  const TeacherHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SchoolConnect'),
        actions: [
          IconButton(icon: const Icon(LucideIcons.bell), onPressed: () {}),
          const CircleAvatar(
            backgroundColor: SchoolGridTheme.primary,
            child: Text('AS', style: TextStyle(color: Colors.white)),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const GreetingSection(),
            const SizedBox(height: 24),
            const SectionHeader(title: 'Your Classes'),
            const SizedBox(height: 12),
            const ClassCard(className: 'Class 8A', subject: 'Mathematics', schedule: 'Mon, Wed, Fri - 9:00 AM'),
            const ClassCard(className: 'Class 9B', subject: 'Mathematics', schedule: 'Tue, Thu - 10:00 AM'),
            const ClassCard(className: 'Class 10A', subject: 'Mathematics', schedule: 'Mon, Wed - 11:00 AM'),
            const SizedBox(height: 24),
            const SectionHeader(title: 'Recent Posts & Status'),
            const SizedBox(height: 12),
            const PostStatusTile(
              title: 'Chapter 5 Exercises',
              subtitle: 'Class 8A · 2 hours ago',
              doubts: 0,
            ),
            const PostStatusTile(
              title: 'Unit Test Announcement',
              subtitle: 'Class 9B · Yesterday',
              doubts: 2,
            ),
          ],
        ),
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            heroTag: 'help_center',
            onPressed: () {
              context.push('/teacher-help-center');
            },
            backgroundColor: const Color(0xFF1E293B), // Dark color as seen in reference
            child: const Icon(LucideIcons.messageSquare, color: Colors.white),
          ),
          const SizedBox(height: 16),
          FloatingActionButton(
            heroTag: 'add_homework',
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                builder: (context) => const PostHomeworkModal(),
              );
            },
            backgroundColor: SchoolGridTheme.primary,
            child: const Icon(Icons.add, color: Colors.white),
          ),
        ],
      ),
    );
  }
}

class GreetingSection extends StatelessWidget {
  const GreetingSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const CircleAvatar(
          radius: 30,
          backgroundColor: SchoolGridTheme.primary,
          child: Text('AS', style: TextStyle(fontSize: 20, color: Colors.white)),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Good morning, Mrs. Sharma 👋',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            Text(
              'Mathematics Teacher',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
            ),
          ],
        ),
      ],
    );
  }
}

class SectionHeader extends StatelessWidget {
  final String title;
  const SectionHeader({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
    );
  }
}

class ClassCard extends StatelessWidget {
  final String className;
  final String subject;
  final String schedule;

  const ClassCard({super.key, required this.className, required this.subject, required this.schedule});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: SchoolGridTheme.primaryLight, borderRadius: BorderRadius.circular(8)),
          child: const Icon(LucideIcons.bookOpen, color: SchoolGridTheme.primary),
        ),
        title: Text('$className — $subject', style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(schedule),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      ),
    );
  }
}

class PostStatusTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final int doubts;

  const PostStatusTile({super.key, required this.title, required this.subtitle, required this.doubts});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: SchoolGridTheme.primaryLight, borderRadius: BorderRadius.circular(8)),
                  child: const Icon(LucideIcons.fileText, color: SchoolGridTheme.primary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
                      Text(subtitle, style: const TextStyle(color: Colors.grey)),
                    ],
                  ),
                ),
                TextButton.icon(
                  onPressed: () {},
                  icon: const Icon(LucideIcons.messageSquare, size: 16),
                  label: Text('Doubts ($doubts)'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
