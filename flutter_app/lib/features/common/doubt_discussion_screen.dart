import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/models/homework_models.dart';
import '../../core/services/user_service.dart';
import '../../core/services/homework_service.dart';
import '../../core/theme.dart';

class DoubtDiscussionScreen extends StatefulWidget {
  final String homeworkId;
  final String? studentId;
  final String? parentId;
  final bool isTeacher;

  const DoubtDiscussionScreen({
    super.key,
    required this.homeworkId,
    this.studentId,
    this.parentId,
    this.isTeacher = false,
  });

  @override
  State<DoubtDiscussionScreen> createState() => _DoubtDiscussionScreenState();
}

class _DoubtDiscussionScreenState extends State<DoubtDiscussionScreen> {
  final _textController = TextEditingController();

  void _handleSubmit(String content) async {
    if (content.trim().isEmpty) return;

    final service = context.read<HomeworkService>();
    
    if (!widget.isTeacher) {
      if (widget.studentId != null && widget.parentId != null) {
        final success = await service.addDoubt(
          homeworkId: widget.homeworkId,
          studentId: widget.studentId!,
          parentId: widget.parentId!,
          content: content,
        );
        
        if (mounted) {
          if (success) {
            _textController.clear();
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Failed to send doubt. Please try again.')),
            );
          }
        }
      }
    }
  }

  void _showReplyDialog(Doubt doubt) {
    final replyController = TextEditingController();
    final userService = context.read<UserService>();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Reply to ${doubt.studentName}'),
        content: TextField(
          controller: replyController,
          maxLines: 3,
          decoration: const InputDecoration(hintText: 'Enter your response...'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final teacherId = userService.teacherId;
              if (teacherId != null) {
                await context.read<HomeworkService>().replyToDoubt(
                  doubtId: doubt.id,
                  teacherId: teacherId,
                  teacherName: userService.profile!.fullName,
                  content: replyController.text,
                );
              }
              Navigator.pop(context);
            },
            child: const Text('Send Reply'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final homework = context.watch<HomeworkService>().homeworks.firstWhere((h) => h.id == widget.homeworkId);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(homework.title, style: const TextStyle(fontSize: 16)),
            Text(homework.className, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.normal)),
          ],
        ),
        backgroundColor: Colors.white,
        foregroundColor: SchoolGridTheme.primary,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: homework.doubts.length,
              itemBuilder: (context, index) {
                final doubt = homework.doubts[index];
                return _buildDoubtItem(doubt);
              },
            ),
          ),
          if (!widget.isTeacher) _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildDoubtItem(Doubt doubt) {
    bool isAnswered = doubt.status == DoubtStatus.answered;

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 14,
                backgroundColor: Colors.grey[200],
                child: Text(doubt.studentName[0], style: const TextStyle(fontSize: 12, color: Colors.black87)),
              ),
              const SizedBox(width: 8),
              Text(doubt.studentName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              const Spacer(),
              Text(
                DateFormat('MMM d, h:mm a').format(doubt.timestamp),
                style: const TextStyle(fontSize: 11, color: Colors.grey),
              ),
            ],
          ),
          Container(
            margin: const EdgeInsets.only(left: 36, top: 4),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(doubt.content, style: const TextStyle(fontSize: 14)),
          ),
          if (isAnswered && doubt.reply != null)
            Container(
              margin: const EdgeInsets.only(left: 36, top: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.reply, size: 14, color: Colors.green),
                      const SizedBox(width: 4),
                      Text(
                        'Reply from ${doubt.reply!.teacherName}',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.green),
                      ),
                    ],
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 4),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0FDF4),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFDCFCE7)),
                    ),
                    child: Text(doubt.reply!.content, style: const TextStyle(fontSize: 14)),
                  ),
                ],
              ),
            )
          else if (widget.isTeacher)
            Padding(
              padding: const EdgeInsets.only(left: 36, top: 8),
              child: TextButton.icon(
                onPressed: () => _showReplyDialog(doubt),
                icon: const Icon(Icons.reply, size: 16),
                label: const Text('Reply'),
                style: TextButton.styleFrom(
                  foregroundColor: SchoolGridTheme.primary,
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 8,
        bottom: MediaQuery.of(context).padding.bottom + 8,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -2)),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _textController,
              decoration: InputDecoration(
                hintText: 'Ask a doubt...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: const Color(0xFFF1F5F9),
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
            ),
          ),
          const SizedBox(width: 12),
          CircleAvatar(
            backgroundColor: SchoolGridTheme.primary,
            child: IconButton(
              icon: const Icon(Icons.send, color: Colors.white, size: 20),
              onPressed: () => _handleSubmit(_textController.text),
            ),
          ),
        ],
      ),
    );
  }
}
