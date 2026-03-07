import 'package:flutter/material.dart';
import '../../core/theme.dart';
import 'parent_profile_overlay.dart';

class ParentHomeScreen extends StatefulWidget {
  const ParentHomeScreen({super.key});

  @override
  State<ParentHomeScreen> createState() => _ParentHomeScreenState();
}

class _ParentHomeScreenState extends State<ParentHomeScreen> {
  String _selectedChild = 'Aarav · 8A';

  @override
  Widget build(BuildContext context) {
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
          IconButton(icon: const Icon(Icons.notifications_none), onPressed: () {}),
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
                  const CircleAvatar(
                    radius: 16,
                    backgroundColor: SchoolGridTheme.primary,
                    child: Text('SM', style: TextStyle(fontSize: 12, color: Colors.white)),
                  ),
                  const SizedBox(width: 8),
                  const Text('Sunil', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w500)),
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  'Good morning, Mr. Mehta 👋',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const Text(
              'Delhi Public School',
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                _buildChildChip('Aarav · 8A'),
                const SizedBox(width: 12),
                _buildChildChip('Ishita · 5B'),
              ],
            ),
            const SizedBox(height: 24),
            const Text(
              'Today\'s Homework',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            if (_selectedChild == 'Aarav · 8A') ...[
              const HomeworkCard(
                subject: 'Mathematics',
                details: 'Page 45, Ex 1-5',
                dueDate: 'Tomorrow',
                status: 'Acknowledge',
              ),
              const HomeworkCard(
                subject: 'Science',
                details: 'Read Chapter 3',
                dueDate: 'Today',
                status: 'Done',
              ),
              const HomeworkCard(
                subject: 'English',
                details: 'Essay on Environment',
                dueDate: 'Mar 5',
                status: 'Acknowledge',
              ),
            ] else ...[
              const HomeworkCard(
                subject: 'Hindi',
                details: 'Learn poem',
                dueDate: 'Today',
                status: 'Done',
              ),
              const HomeworkCard(
                subject: 'EVS',
                details: 'Draw water cycle',
                dueDate: 'Tomorrow',
                status: 'Acknowledge',
              ),
            ],
            const SizedBox(height: 16),
            const AnnouncementTile(count: 2),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: const Color(0xFF1E293B),
        child: const Icon(Icons.message_outlined, color: Colors.white),
      ),
    );
  }

  Widget _buildChildChip(String label) {
    bool isSelected = _selectedChild == label;
    return GestureDetector(
      onTap: () => setState(() => _selectedChild = label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? SchoolGridTheme.primary : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
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
  final String subject;
  final String details;
  final String dueDate;
  final String status;

  const HomeworkCard({
    super.key,
    required this.subject,
    required this.details,
    required this.dueDate,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    bool isDone = status == 'Done';
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
                        subject,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        details,
                        style: const TextStyle(color: Color(0xFF64748B)),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.calendar_today_outlined, size: 14, color: Color(0xFF64748B)),
                          const SizedBox(width: 4),
                          Text(
                            'Due: $dueDate',
                            style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (isDone)
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
                        Text('Done', style: TextStyle(color: Color(0xFF16A34A), fontSize: 12, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  )
                else
                  ElevatedButton(
                    onPressed: () {},
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
              onTap: () {},
              child: const Row(
                children: [
                  Icon(Icons.chat_bubble_outline, size: 16, color: SchoolGridTheme.primary),
                  SizedBox(width: 8),
                  Text(
                    'Ask a Doubt',
                    style: TextStyle(color: SchoolGridTheme.primary, fontWeight: FontWeight.w500),
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
