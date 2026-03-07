import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme.dart';

class TeacherProfileScreen extends StatelessWidget {
  const TeacherProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              alignment: Alignment.center,
              clipBehavior: Clip.none,
              children: [
                Container(
                  height: 140,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: SchoolGridTheme.primary,
                  ),
                  child: const SafeArea(
                    child: Padding(
                      padding: EdgeInsets.only(top: 10),
                      child: Text(
                        'Profile',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: -60,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const CircleAvatar(
                      radius: 56,
                      backgroundColor: SchoolGridTheme.primary,
                      child: Text(
                        'AS',
                        style: TextStyle(fontSize: 36, color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 70),
            const Text(
              'Mrs. Anita Sharma',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
            ),
            const Text(
              'Mathematics Teacher',
              style: TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
            ),
            const SizedBox(height: 24),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: ProfileInfoCard(),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: ContactInfoCard(),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => context.go('/auth'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: SchoolGridTheme.error,
                    side: const BorderSide(color: Color(0xFFFECACA)),
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Logout', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class ProfileInfoCard extends StatelessWidget {
  const ProfileInfoCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const InfoRow(label: 'School', value: 'Delhi Public School'),
            const Divider(),
            const InfoRow(label: 'Academic Year', value: '2024 - 2025'),
            const Divider(),
            const InfoRow(label: 'Last Login', value: 'Today, 08:51 PM'),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Status', style: TextStyle(color: Colors.grey)),
                Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: const BoxDecoration(color: SchoolGridTheme.success, shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 8),
                    const Text('Active', style: TextStyle(fontWeight: FontWeight.w600, color: SchoolGridTheme.success)),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class ContactInfoCard extends StatelessWidget {
  const ContactInfoCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: const Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            InfoRow(label: 'Phone', value: '+91 98765 43210'),
            Divider(),
            InfoRow(label: 'Email', value: 'anita@school.edu'),
            Divider(),
            InfoRow(label: 'Classes', value: '8A, 9B, 10A'),
            Divider(),
            InfoRow(label: 'Teacher ID', value: 'TCH-2024-001'),
          ],
        ),
      ),
    );
  }
}

class InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const InfoRow({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
