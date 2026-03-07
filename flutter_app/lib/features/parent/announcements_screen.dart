import 'package:flutter/material.dart';
import '../../core/theme.dart';
import 'parent_profile_overlay.dart';

class ParentNewsScreen extends StatelessWidget {
  const ParentNewsScreen({super.key});

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
            const Text(
              'Announcements',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const AnnouncementCard(
              title: 'Annual Day Preparations',
              date: 'Feb 20',
              content: 'Rehearsals begin next week for all participating students...',
            ),
            const AnnouncementCard(
              title: 'Parent-Teacher Meeting',
              date: 'Feb 25',
              content: 'PTM scheduled for classes 5-10 on Saturday...',
            ),
            const AnnouncementCard(
              title: 'Sports Day Registration',
              date: 'Feb 18',
              content: 'Register your child for upcoming sports events...',
            ),
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
}

class AnnouncementCard extends StatelessWidget {
  final String title;
  final String date;
  final String content;

  const AnnouncementCard({
    super.key,
    required this.title,
    required this.date,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                Text(
                  date,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              content,
              style: const TextStyle(color: Color(0xFF64748B)),
            ),
          ],
        ),
      ),
    );
  }
}
