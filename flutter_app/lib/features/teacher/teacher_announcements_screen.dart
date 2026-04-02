import 'package:flutter/material.dart';
import '../../core/theme.dart';
import 'package:provider/provider.dart';
import '../../core/services/announcement_service.dart';
import '../common/announcement_card.dart';
import 'package:intl/intl.dart';

class TeacherAnnouncementsScreen extends StatelessWidget {
  const TeacherAnnouncementsScreen({super.key});

  String _formatDate(DateTime date) {
    return DateFormat('MMM d, h:mm a').format(date.toLocal());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Announcements'),
        backgroundColor: Colors.white,
        foregroundColor: SchoolGridTheme.primary,
        elevation: 1,
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
                   height: MediaQuery.of(context).size.height - kToolbarHeight,
                   child: const Center(
                     child: Text('No announcements posted yet.', style: TextStyle(color: Colors.grey)),
                   ),
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16.0),
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
            );
          },
        ),
      ),
    );
  }
}
