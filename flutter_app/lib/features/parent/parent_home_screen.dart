import 'package:flutter/material.dart';
import '../../core/theme.dart';
import 'package:go_router/go_router.dart';
import 'parent_profile_overlay.dart';

import 'package:provider/provider.dart';
import '../../core/services/homework_service.dart';
import '../../core/models/homework_models.dart';
import '../common/doubt_discussion_screen.dart';
import 'package:intl/intl.dart';

import '../../core/services/user_service.dart';
import '../../core/services/notification_service.dart';

class ParentHomeScreen extends StatefulWidget {
  const ParentHomeScreen({super.key});

  @override
  State<ParentHomeScreen> createState() => _ParentHomeScreenState();
}

class _ParentHomeScreenState extends State<ParentHomeScreen> {
  String? _selectedChildId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UserService>().fetchProfile().then((_) {
        final children = context.read<UserService>().children;
        if (children.isNotEmpty) {
          setState(() => _selectedChildId = children.first.studentId);
          context.read<HomeworkService>().fetchHomework(classId: children.first.classId);
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final userService = context.watch<UserService>();
    final homeworkService = context.watch<HomeworkService>();

    if (userService.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final profile = userService.profile;
    final children = userService.children;

    // Set initial selected child if not set
    if (_selectedChildId == null && children.isNotEmpty) {
      _selectedChildId = children.first.studentId;
    }

    final selectedChild = children.isEmpty 
        ? null 
        : children.firstWhere((c) => c.studentId == _selectedChildId, orElse: () => children.first);

    final homeworks = selectedChild == null 
        ? <Homework>[] 
        : homeworkService.homeworks.where((h) {
            return h.classId.trim() == selectedChild.classId.trim() && 
                   h.sectionId.trim() == selectedChild.sectionId.trim();
          }).toList();

    return Scaffold(
      appBar: AppBar(
        leadingWidth: 80,
        leading: const Center(
          child: Text(
            'SC',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: SchoolGridTheme.primary,
            ),
          ),
        ),
        title: const Text('SchoolConnect'),
        actions: [
          Consumer<AppNotificationService>(
            builder: (context, notificationService, _) => Badge(
              label: Text(notificationService.unreadCount.toString()),
              isLabelVisible: notificationService.unreadCount > 0,
              child: IconButton(
                icon: const Icon(Icons.notifications_none),
                onPressed: () => context.push('/notifications'),
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => const ParentProfileOverlay(),
              );
            },
            child: Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: SchoolGridTheme.primary,
                    child: Text(
                      profile?.fullName.substring(0, 1).toUpperCase() ?? '?',
                      style: const TextStyle(fontSize: 12, color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    profile?.fullName.split(' ').first ?? 'Parent',
                    style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w500),
                  ),
                  const Icon(Icons.keyboard_arrow_down, color: Colors.black54),
                ],
              ),
            ),
          ),
        ],
        backgroundColor: Colors.white,
        foregroundColor: SchoolGridTheme.primary,
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: () async => userService.fetchProfile(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'Good morning, ${profile?.fullName ?? "Parent"} 👋',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const Text(
                'SchoolGrid Central',
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
              const SizedBox(height: 24),
              if (children.isEmpty)
                const Center(child: Text('No children linked to this account', style: TextStyle(color: Colors.grey)))
              else
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: children.map((child) => Padding(
                      padding: const EdgeInsets.only(right: 12.0),
                      child: _buildChildChip(child),
                    )).toList(),
                  ),
                ),
              const SizedBox(height: 24),
              const Text(
                'Today\'s Homework',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              if (homeworks.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 40),
                    child: Column(
                      children: [
                        Icon(Icons.assignment_outlined, size: 48, color: Colors.grey[300]),
                        const SizedBox(height: 16),
                        Text('No homework posted yet', style: TextStyle(color: Colors.grey[500])),
                      ],
                    ),
                  ),
                )
              else
                ...homeworks.map((hw) => HomeworkCard(
                      homework: hw,
                      selectedChild: selectedChild,
                    )),
              const SizedBox(height: 16),
              const AnnouncementTile(count: 2),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/parent-help-center'),
        backgroundColor: const Color(0xFF1E293B),
        child: const Icon(Icons.message_outlined, color: Colors.white),
      ),
    );
  }

  Widget _buildChildChip(ChildInfo child) {
    bool isSelected = _selectedChildId == child.studentId;
    return GestureDetector(
      onTap: () {
        setState(() => _selectedChildId = child.studentId);
        context.read<HomeworkService>().fetchHomework(classId: child.classId);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? SchoolGridTheme.primary : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          child.displayLabel,
          style: TextStyle(
            color: isSelected ? Colors.white : const Color(0xFF64748B),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class HomeworkCard extends StatelessWidget {
  final Homework homework;
  final ChildInfo? selectedChild;

  const HomeworkCard({
    super.key,
    required this.homework,
    this.selectedChild,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: SchoolGridTheme.primaryLight,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.book_outlined, color: SchoolGridTheme.primary, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        homework.title,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        homework.description,
                        style: const TextStyle(color: Color(0xFF64748B)),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.calendar_today_outlined, size: 14, color: Color(0xFF64748B)),
                          const SizedBox(width: 4),
                          Text(
                            'Due: ${DateFormat('MMM d').format(homework.dueDate)}',
                            style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (homework.doubts.any((d) => d.status == DoubtStatus.answered))
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0FDF4),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFBBF7D0)),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.check_circle_outline, color: Color(0xFF16A34A), size: 14),
                        SizedBox(width: 4),
                        Text('Solved', style: TextStyle(color: Color(0xFF16A34A), fontSize: 12, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  )
                else if (homework.acknowledgments.any((a) => a.studentId == selectedChild?.studentId))
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE0F2FE),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text('Acknowledged', style: TextStyle(color: Color(0xFF0369A1), fontSize: 10, fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'at ${DateFormat('h:mm a').format(homework.acknowledgments.firstWhere((a) => a.studentId == selectedChild?.studentId).timestamp)}',
                        style: const TextStyle(fontSize: 10, color: Colors.grey),
                      ),
                    ],
                  )
                else
                  ElevatedButton(
                    onPressed: () async {
                      if (selectedChild != null) {
                        final success = await context.read<HomeworkService>().acknowledgeHomework(
                          homeworkId: homework.id,
                          studentId: selectedChild!.studentId,
                          studentName: selectedChild!.fullName,
                          applicationNumber: 'APP-${selectedChild!.studentId.substring(0, 8)}',
                        );
                        
                        if (context.mounted && !success) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Failed to acknowledge homework.')),
                          );
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF1F5F9),
                      foregroundColor: const Color(0xFF1E293B),
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                      minimumSize: const Size(0, 32),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('Acknowledge', style: TextStyle(fontSize: 12)),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () {
                if (selectedChild == null) return;

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DoubtDiscussionScreen(
                      homeworkId: homework.id,
                      studentId: selectedChild!.studentId,
                      parentId: selectedChild!.parentId,
                    ),
                  ),
                );
              },
              child: Row(
                children: [
                  const Icon(Icons.chat_bubble_outline, size: 16, color: SchoolGridTheme.primary),
                  const SizedBox(width: 8),
                  Text(
                    homework.doubts.isEmpty ? 'Ask a Doubt' : 'Discussion (${homework.totalDoubts})',
                    style: const TextStyle(color: SchoolGridTheme.primary, fontWeight: FontWeight.w500),
                  ),
                  const Spacer(),
                  if (homework.unansweredDoubts > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.red[50],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${homework.unansweredDoubts} new',
                        style: TextStyle(color: Colors.red[700], fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AnnouncementTile extends StatelessWidget {
  final int count;
  const AnnouncementTile({super.key, required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          const Icon(Icons.notifications_none_outlined, color: Colors.orange),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$count unread announcements',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const Text(
                  'Tap to view',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: Colors.grey),
        ],
      ),
    );
  }
}
