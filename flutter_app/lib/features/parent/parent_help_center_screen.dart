import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:file_picker/file_picker.dart';
import '../../core/theme.dart';

class ParentHelpCenterScreen extends StatefulWidget {
  const ParentHelpCenterScreen({super.key});

  @override
  State<ParentHelpCenterScreen> createState() => _ParentHelpCenterScreenState();
}

class _ParentHelpCenterScreenState extends State<ParentHelpCenterScreen> {
  final TextEditingController _messageController = TextEditingController();
  final List<Map<String, dynamic>> _messages = [
    {
      'text': 'Welcome to Parent Support! How can we help you today?',
      'isUser': false,
    },
    {
      'text': 'Common topics: \n• Linking multiple children\n• Homework notifications\n• Updating parent contact info',
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
            'text': 'We have received your message. A school representative will get back to you shortly via the app or your registered email.',
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
              'Parent Support',
              style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
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
                      _SupportMessage(
                        text: msg['text'],
                        isUser: msg['isUser'],
                      ),
                      if (msg['attachment'] != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _AttachmentPreview(file: msg['attachment']),
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
          _ChatInput(
            controller: _messageController,
            onAttach: _pickFile,
            onSend: _sendMessage,
          ),
        ],
      ),
    );
  }
}

class _SupportMessage extends StatelessWidget {
  final String text;
  final bool isUser;
  const _SupportMessage({required this.text, this.isUser = false});

  @override
  Widget build(BuildContext context) {
    if (text.isEmpty) return const SizedBox.shrink();
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isUser ? SchoolGridTheme.primary : const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(12).copyWith(
          bottomLeft: isUser ? const Radius.circular(12) : Radius.zero,
          bottomRight: isUser ? Radius.zero : const Radius.circular(12),
        ),
      ),
      child: Text(
        text,
        style: const TextStyle(color: Colors.white, fontSize: 14, height: 1.4),
      ),
    );
  }
}

class _AttachmentPreview extends StatelessWidget {
  final PlatformFile? file;
  const _AttachmentPreview({this.file});

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
              color: SchoolGridTheme.primary,
              size: 40,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: const BoxDecoration(
              color: Color(0xFF1E293B),
              borderRadius: BorderRadius.only(
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
                    file?.name ?? 'attachment',
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

class _ChatInput extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onAttach;
  final VoidCallback onSend;

  const _ChatInput({
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
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(24),
              ),
              child: TextField(
                controller: controller,
                decoration: const InputDecoration(
                  hintText: 'Ask for help...',
                  border: InputBorder.none,
                ),
                onSubmitted: (_) => onSend(),
              ),
            ),
          ),
          const SizedBox(width: 8),
          CircleAvatar(
            backgroundColor: SchoolGridTheme.primary,
            child: IconButton(
              icon: const Icon(Icons.send, color: Colors.white, size: 20),
              onPressed: onSend,
            ),
          ),
        ],
      ),
    );
  }
}
