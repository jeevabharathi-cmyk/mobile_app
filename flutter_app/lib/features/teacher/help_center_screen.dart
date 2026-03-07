import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:file_picker/file_picker.dart';
import '../../core/theme.dart';

class HelpCenterScreen extends StatefulWidget {
  const HelpCenterScreen({super.key});

  @override
  State<HelpCenterScreen> createState() => _HelpCenterScreenState();
}

class _HelpCenterScreenState extends State<HelpCenterScreen> {
  final TextEditingController _messageController = TextEditingController();
  final List<Map<String, dynamic>> _messages = [
    {
      'text': 'repeatedly moved outside the screen and automatically closed during the exam. Additionally, I experienced unexpected internet connectivity issues, which further interrupted my test session.',
      'isUser': false,
    },
    {
      'text': 'Due to these technical difficulties, I was unable to complete the exam properly. I kindly request you to review my case and grant me an opportunity for a re-exam.',
      'isUser': false,
    },
  ];

  PlatformFile? _attachedFile;

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'png', 'jpg', 'jpeg'],
    );

    if (result != null) {
      setState(() {
        _attachedFile = result.files.first;
      });
    }
  }

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty && _attachedFile == null) return;

    setState(() {
      _messages.add({
        'text': _messageController.text.trim(),
        'isUser': true,
        'attachment': _attachedFile,
      });
      _messageController.clear();
      _attachedFile = null;
    });

    // Simulate auto-reply
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _messages.add({
            'text': 'Thank you for reporting this. Our technical team has received your summary and will review the attached documents shortly. We will notify you of the outcome.',
            'isUser': false,
          });
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            const CircleAvatar(
              radius: 16,
              backgroundColor: SchoolGridTheme.primaryLight,
              child: Icon(LucideIcons.user, size: 18, color: SchoolGridTheme.primary),
            ),
            const SizedBox(width: 12),
            const Text(
              'SchoolConnect Pro Support',
              style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.keyboard_arrow_down, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          const Divider(height: 1),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length + (_attachedFile != null ? 1 : 0),
              itemBuilder: (context, index) {
                if (index < _messages.length) {
                  final msg = _messages[index];
                  return Column(
                    crossAxisAlignment: msg['isUser'] ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                    children: [
                      SupportMessage(
                        text: msg['text'],
                        isUser: msg['isUser'],
                      ),
                      if (msg['attachment'] != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: AttachmentPreview(file: msg['attachment']),
                        ),
                    ],
                  );
                } else {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.attach_file, size: 16),
                              const SizedBox(width: 8),
                              Text(_attachedFile!.name, style: const TextStyle(fontSize: 12)),
                              IconButton(
                                icon: const Icon(Icons.close, size: 16),
                                onPressed: () => setState(() => _attachedFile = null),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }
              },
            ),
          ),
          ChatInput(
            controller: _messageController,
            onAttach: _pickFile,
            onSend: _sendMessage,
          ),
        ],
      ),
    );
  }
}

class SupportMessage extends StatelessWidget {
  final String text;
  final bool isUser;
  const SupportMessage({super.key, required this.text, this.isUser = false});

  @override
  Widget build(BuildContext context) {
    if (text.isEmpty) return const SizedBox.shrink();
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isUser ? SchoolGridTheme.primary : const Color(0xFF004A85),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: const TextStyle(color: Colors.white, fontSize: 15, height: 1.4),
      ),
    );
  }
}

class AttachmentPreview extends StatelessWidget {
  final PlatformFile? file;
  const AttachmentPreview({super.key, this.file});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            alignment: Alignment.center,
            child: Icon(
              file?.extension == 'pdf' ? Icons.picture_as_pdf : Icons.image,
              color: Colors.teal[400],
              size: 40,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF004A85),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(7),
                bottomRight: Radius.circular(7),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.insert_drive_file, color: Colors.white, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    file?.name ?? 'Screenshot 2026-...',
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ChatInput extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onAttach;
  final VoidCallback onSend;

  const ChatInput({
    super.key,
    required this.controller,
    required this.onAttach,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, -1),
            blurRadius: 10,
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(LucideIcons.paperclip, color: SchoolGridTheme.primary),
            onPressed: onAttach,
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(4),
              ),
              child: TextField(
                controller: controller,
                decoration: const InputDecoration(
                  hintText: 'Type your message...',
                  border: InputBorder.none,
                ),
                onSubmitted: (_) => onSend(),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send, color: SchoolGridTheme.primary),
            onPressed: onSend,
          ),
        ],
      ),
    );
  }
}
