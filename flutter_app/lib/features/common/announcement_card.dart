import 'package:flutter/material.dart';

class AnnouncementCard extends StatelessWidget {
  final String title;
  final String date;
  final String content;
  final String priority;

  const AnnouncementCard({
    super.key,
    required this.title,
    required this.date,
    required this.content,
    required this.priority,
  });

  @override
  Widget build(BuildContext context) {
    final bool isEmergency = priority == 'emergency';
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: isEmergency ? Colors.red.shade100 : Colors.grey.shade200),
      ),
      color: isEmergency ? Colors.red.shade50 : Colors.white,
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
                  child: Row(
                    children: [
                      if (isEmergency) 
                        const Padding(
                          padding: EdgeInsets.only(right: 8.0),
                          child: Icon(Icons.error_outline, color: Colors.red, size: 18),
                        ),
                      Expanded(
                        child: Text(
                          title,
                          style: TextStyle(
                            fontSize: 16, 
                            fontWeight: FontWeight.bold,
                            color: isEmergency ? Colors.red.shade700 : Colors.black87,
                          ),
                        ),
                      ),
                    ],
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
              style: TextStyle(color: isEmergency ? Colors.red.shade900 : const Color(0xFF64748B)),
            ),
          ],
        ),
      ),
    );
  }
}
