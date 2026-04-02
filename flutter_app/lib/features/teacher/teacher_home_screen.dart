import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/theme.dart';
import 'post_homework_modal.dart';

import 'package:provider/provider.dart';
import '../../core/services/homework_service.dart';
import '../../core/models/homework_models.dart';
import '../common/doubt_discussion_screen.dart';
import 'package:intl/intl.dart';

import '../../core/services/user_service.dart';

class TeacherHomeScreen extends StatefulWidget {
  const TeacherHomeScreen({super.key});

  @override
  State<TeacherHomeScreen> createState() => _TeacherHomeScreenState();
}

class _TeacherHomeScreenState extends State<TeacherHomeScreen> {
  @override
  void initState() {
    print('DEBUG: TeacherHomeScreen.initState called');
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userService = context.read<UserService>();
      userService.fetchProfile().then((_) {
        final profile = userService.profile;
        final teacherId = userService.teacherId;
        if (profile != null && profile.role == 'teacher' && teacherId != null) {
          print('DEBUG: Calling fetchHomework for teacher: $teacherId');
          context.read<HomeworkService>().fetchHomework(teacherId: teacherId);
        } else {
          print('DEBUG: conditions not met - profile: ${profile != null}, role: ${profile?.role}, teacherId: $teacherId');
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final userService = context.watch<UserService>();
    final homeworkService = context.watch<HomeworkService>();
    final homeworks = homeworkService.homeworks;

    if (userService.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final profile = userService.profile;

    return Scaffold(
      appBar: AppBar(
        title: const Text('SchoolConnect'),
        actions: [
          IconButton(icon: const Icon(LucideIcons.bell), onPressed: () {
            context.push('/teacher-announcements');
          }),
          CircleAvatar(
            backgroundColor: SchoolGridTheme.primary,
            child: Text(
              profile?.fullName.substring(0, 1).toUpperCase() ?? '?',
              style: const TextStyle(color: Colors.white),
            ),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GreetingSection(profile: profile),
            const SizedBox(height: 24),
            const SectionHeader(title: 'Your Classes'),
            const SizedBox(height: 12),
            if (userService.teacherClasses.isEmpty)
              const Center(child: Text('No classes assigned yet', style: TextStyle(color: Colors.grey)))
            else
              ...userService.teacherClasses.map((cls) => ClassCard(
                    className: cls.className,
                    subject: cls.subject,
                    schedule: cls.schedule,
                  )),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SectionHeader(title: 'Recent Posts & Status'),
                if (homeworks.isNotEmpty)
                  Text(
                    '${homeworks.length} Posts',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            if (homeworks.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 40),
                  child: Column(
                    children: [
                      Icon(Icons.post_add, size: 48, color: Colors.grey[300]),
                      const SizedBox(height: 16),
                      Text('No homework posted yet', style: TextStyle(color: Colors.grey[500])),
                      const SizedBox(height: 8),
                      Text('Tap + to post your first homework', style: TextStyle(color: Colors.grey[400], fontSize: 12)),
                    ],
                  ),
                ),
              )
            else
              ...homeworks.map((hw) => PostStatusTile(homework: hw)),
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
            backgroundColor: const Color(0xFF1E293B),
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
  final UserProfile? profile;
  const GreetingSection({super.key, this.profile});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 30,
          backgroundColor: SchoolGridTheme.primary,
          child: Text(
            profile?.fullName.substring(0, 1).toUpperCase() ?? '?',
            style: const TextStyle(fontSize: 20, color: Colors.white),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Good morning, ${profile?.fullName ?? "Teacher"} 👋',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              Text(
                profile?.role.toUpperCase() ?? 'Teacher',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
              ),
            ],
          ),
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
  final Homework homework;

  const PostStatusTile({super.key, required this.homework});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
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
                      Text(homework.title, style: const TextStyle(fontWeight: FontWeight.w600)),
                      Text('${homework.className} · Just now', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Stack(
                      children: [
                        TextButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DoubtDiscussionScreen(homeworkId: homework.id, isTeacher: true),
                              ),
                            );
                          },
                          icon: const Icon(LucideIcons.messageSquare, size: 16),
                          label: Text('Doubts (${homework.totalDoubts})'),
                        ),
                        if (homework.unansweredDoubts > 0)
                          Positioned(
                            right: 0,
                            top: 0,
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                            ),
                          ),
                      ],
                    ),
                    GestureDetector(
                      onTap: () => _showAcknowledgeDialog(context, homework),
                      child: Padding(
                        padding: const EdgeInsets.only(right: 8.0, top: 4),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(LucideIcons.userCheck, size: 12, color: Colors.green),
                            const SizedBox(width: 4),
                            Text(
                              '${homework.totalAcknowledgments} Acknowledged',
                              style: const TextStyle(fontSize: 10, color: Colors.green, fontWeight: FontWeight.bold, decoration: TextDecoration.underline),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showAcknowledgeDialog(BuildContext context, Homework homework) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Acknowledgments - ${homework.title}'),
        content: SizedBox(
          width: double.maxFinite,
          child: homework.acknowledgments.isEmpty
              ? const Text('No students have acknowledged yet.')
              : ListView.builder(
                  shrinkWrap: true,
                  itemCount: homework.acknowledgments.length,
                  itemBuilder: (context, index) {
                    final ack = homework.acknowledgments[index];
                    return ListTile(
                      dense: true,
                      title: Text(ack.studentName, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text('App No: ${ack.applicationNumber}'),
                      trailing: Text(
                        DateFormat('h:mm a, MMM d').format(ack.timestamp),
                        style: const TextStyle(fontSize: 10, color: Colors.grey),
                      ),
                    );
                  },
                ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
        ],
      ),
    );
  }
}
