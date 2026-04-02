import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme.dart';
import 'package:provider/provider.dart';
import '../../core/services/user_service.dart';

class ParentProfileScreen extends StatelessWidget {
  const ParentProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      body: Consumer<UserService>(
        builder: (context, userService, _) {
          final profile = userService.profile;
          final initial = profile?.fullName.isNotEmpty == true 
              ? profile!.fullName.substring(0, 1).toUpperCase() 
              : '?';

          final childrenStr = userService.children.isEmpty 
              ? 'No children linked' 
              : userService.children.map((c) => '${c.fullName} (${c.className}${c.sectionName})').join(', ');

          return SingleChildScrollView(
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
                    child: CircleAvatar(
                      radius: 56,
                      backgroundColor: SchoolGridTheme.primary,
                      child: Text(
                        initial,
                        style: const TextStyle(fontSize: 36, color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 70),
            Text(
              profile?.fullName ?? 'Parent Name',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
            ),
            Text(
              profile?.role.toUpperCase() ?? 'PARENT',
              style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
            ),
            const SizedBox(height: 24),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: _ParentInfoCard(),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _ParentContactCard(
                phone: profile?.phone ?? 'Not provided',
                email: profile?.email ?? 'Not provided',
                childrenStr: childrenStr,
                parentId: profile?.id.substring(0, 8).toUpperCase() ?? 'N/A',
              ),
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
      );
      }),
    );
  }
}

class _ParentInfoCard extends StatelessWidget {
  const _ParentInfoCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const _InfoRow(label: 'School', value: 'Delhi Public School'),
            const Divider(),
            const _InfoRow(label: 'Academic Year', value: '2024 - 2025'),
            const Divider(),
            const _InfoRow(label: 'Last Login', value: 'Today, 09:57 AM'),
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

class _ParentContactCard extends StatelessWidget {
  final String phone;
  final String email;
  final String childrenStr;
  final String parentId;

  const _ParentContactCard({
    required this.phone,
    required this.email,
    required this.childrenStr,
    required this.parentId,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _InfoRow(label: 'Phone', value: phone),
            const Divider(),
            _InfoRow(label: 'Email', value: email),
            const Divider(),
            _InfoRow(label: 'Children', value: childrenStr),
            const Divider(),
            _InfoRow(label: 'Parent ID', value: parentId),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow({required this.label, required this.value});

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
