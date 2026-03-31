import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/theme.dart';

import 'package:provider/provider.dart';
import '../../core/services/homework_service.dart';
import '../../core/services/user_service.dart';

class PostHomeworkModal extends StatefulWidget {
  const PostHomeworkModal({super.key});

  @override
  State<PostHomeworkModal> createState() => _PostHomeworkModalState();
}

class _PostHomeworkModalState extends State<PostHomeworkModal> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  String? _selectedClass;
  DateTime? _dueDate;

  InputDecoration _inputDecoration(String label, {String? hintText}) {
    return InputDecoration(
      labelText: label,
      hintText: hintText,
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      labelStyle: const TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w500),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: SchoolGridTheme.primary, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    );
  }

  void _handlePostHomework() {
    if (_titleController.text.isEmpty || _descriptionController.text.isEmpty || _dueDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields and select a due date')),
      );
      return;
    }

    context.read<HomeworkService>().postHomework(
      title: _titleController.text,
      description: _descriptionController.text,
      className: _selectedClass!,
      dueDate: _dueDate!,
    );

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Homework posted successfully!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userService = context.watch<UserService>();
    final teacherClasses = userService.teacherClasses;
    final classNames = teacherClasses.map((c) => c.className).toList();

    if (_selectedClass == null && classNames.isNotEmpty) {
      _selectedClass = classNames.first;
    }

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        left: 20,
        right: 20,
        top: 12,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(width: 24),
                const Text(
                  'Post Homework',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Color(0xFF64748B)),
                  onPressed: () => Navigator.pop(context),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text(
              'Class',
              style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF334155), fontSize: 14),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _selectedClass,
              onChanged: (value) => setState(() => _selectedClass = value),
              items: classNames.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
              decoration: _inputDecoration(''),
              icon: const Icon(Icons.keyboard_arrow_down),
              hint: const Text('Select a class'),
            ),
            const SizedBox(height: 16),
            const Text(
              'Title',
              style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF334155), fontSize: 14),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _titleController,
              decoration: _inputDecoration('', hintText: 'e.g. Chapter 5 Exercises'),
            ),
            const SizedBox(height: 16),
            const Text(
              'Description',
              style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF334155), fontSize: 14),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _descriptionController,
              maxLines: 4,
              decoration: _inputDecoration('', hintText: 'Enter homework details...'),
            ),
            const SizedBox(height: 16),
            const Text(
              'Due Date',
              style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF334155), fontSize: 14),
            ),
            const SizedBox(height: 8),
            InkWell(
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (picked != null) setState(() => _dueDate = picked);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _dueDate == null ? 'dd-mm-yyyy' : '${_dueDate!.day}-${_dueDate!.month}-${_dueDate!.year}',
                      style: TextStyle(
                        color: _dueDate == null ? const Color(0xFF94A3B8) : const Color(0xFF1E293B),
                      ),
                    ),
                    const Icon(LucideIcons.calendar, size: 20, color: Color(0xFF1E293B)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: Theme(
                data: Theme.of(context).copyWith(
                  elevatedButtonTheme: ElevatedButtonThemeData(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF8FAFC),
                      foregroundColor: const Color(0xFF1E293B),
                      elevation: 0,
                      side: const BorderSide(color: Color(0xFFE2E8F0)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                child: ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(LucideIcons.paperclip, size: 18),
                  label: const Text('Attach Files'),
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _handlePostHomework,
                icon: const Icon(LucideIcons.send, size: 18),
                label: const Text('Post Homework'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
