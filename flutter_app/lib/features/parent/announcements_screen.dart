import 'package:flutter/material.dart';
import '../../core/theme.dart';
import 'parent_profile_overlay.dart';
import 'package:provider/provider.dart';
import '../../core/services/announcement_service.dart';
import '../common/announcement_card.dart';
import 'package:intl/intl.dart';

class ParentNewsScreen extends StatelessWidget {
  const ParentNewsScreen({super.key});

  String _formatDate(DateTime date) {
    return DateFormat('MMM d, h:mm a').format(date.toLocal());
  }

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
                   CircleAvatar(
                    radius: 16,
                    backgroundColor: SchoolGridTheme.primary,
                    child: Text('P', style: const TextStyle(fontSize: 12, color: Colors.white)),
                  ),
                  const SizedBox(width: 8),
                   Text('Parent', style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w500)),
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
        onRefresh: () async => context.read<AnnouncementService>().fetchAnnouncements(),
        child: Consumer<AnnouncementService>(
          builder: (context, service, _) {
            if (service.isLoading && service.announcements.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            final announcements = service.announcements;

            if (announcements.isEmpty) {
              return SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: SizedBox(
                   height: MediaQuery.of(context).size.height - kToolbarHeight - 100,
                   child: const Center(
                     child: Text('No announcements posted yet.', style: TextStyle(color: Colors.grey)),
                   ),
                ),
              );
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Text(
                    'Announcements',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: announcements.length,
                    itemBuilder: (context, index) {
                      final ann = announcements[index];
                      return AnnouncementCard(
                        title: ann.title,
                        date: _formatDate(ann.createdAt),
                        content: ann.content,
                        priority: ann.priority,
                      );
                    },
                  ),
                ),
              ],
            );
          },
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

