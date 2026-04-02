import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme.dart';

import 'package:provider/provider.dart';
import '../../core/services/user_service.dart';

class ParentProfileOverlay extends StatelessWidget {
  const ParentProfileOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      alignment: Alignment.topRight,
      insetPadding: const EdgeInsets.only(top: 60, right: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Consumer<UserService>(
        builder: (context, userService, _) {
          final profile = userService.profile;
          final initial = profile?.fullName.isNotEmpty == true 
              ? profile!.fullName.substring(0, 1).toUpperCase() 
              : '?';

          return Container(
            width: 320,
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: SchoolGridTheme.primary,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: const Color(0x33FFFFFF),
                        child: Text(initial, style: const TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              profile?.fullName ?? 'Parent',
                              style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              profile?.email ?? 'No email provided',
                              style: const TextStyle(color: Color(0xCCFFFFFF), fontSize: 13),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0x33FFFFFF),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                profile?.role.toUpperCase() ?? 'PARENT',
                                style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
            const SizedBox(height: 24),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                InfoItem(label: 'SCHOOL', value: 'Delhi Public School'),
                InfoItem(label: 'ACADEMIC YEAR', value: '2024 - 2025'),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const InfoItem(label: 'LAST LOGIN', value: 'Today, 09:57 am'),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('STATUS', style: TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(width: 6, height: 6, decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle)),
                        const SizedBox(width: 6),
                        const Text('Active', style: TextStyle(color: Colors.green, fontWeight: FontWeight.w600, fontSize: 14)),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 8),
            _buildMenuItem(context, Icons.person_outline, 'View Profile'),
            _buildMenuItem(context, Icons.settings_outlined, 'Account Settings'),
            const SizedBox(height: 8),
            const Divider(),
            const SizedBox(height: 8),
            _buildMenuItem(context, Icons.logout, 'Logout', color: Colors.red),
          ],
        ),
      );
      }),
    );
  }

  Widget _buildMenuItem(BuildContext context, IconData icon, String label, {Color color = const Color(0xFF1E293B)}) {
    bool isLogout = label == 'Logout';
    return InkWell(
      onTap: () {
        if (isLogout) {
          context.go('/auth');
        } else if (label == 'View Profile') {
          Navigator.pop(context); // Close dialog
          context.go('/parent-profile');
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isLogout ? const Color(0xFFFEF2F2) : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 18, color: isLogout ? Colors.red : SchoolGridTheme.primary),
            ),
            const SizedBox(width: 16),
            Text(label, style: TextStyle(color: isLogout ? Colors.red : const Color(0xFF1E293B), fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}

class InfoItem extends StatelessWidget {
  final String label;
  final String value;
  const InfoItem({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(color: Color(0xFF1E293B), fontWeight: FontWeight.bold, fontSize: 14)),
      ],
    );
  }
}
