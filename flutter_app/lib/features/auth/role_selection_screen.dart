import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.school, size: 80, color: SchoolGridTheme.primary),
              const SizedBox(height: 16),
              const Text(
                'SchoolGrid Central',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: SchoolGridTheme.primary),
              ),
              const SizedBox(height: 48),
              _RoleButton(
                title: 'Teacher Portal',
                icon: Icons.person_4_outlined,
                onTap: () => context.go('/teacher-home'),
              ),
              const SizedBox(height: 16),
              _RoleButton(
                title: 'Parent Portal',
                icon: Icons.family_restroom_outlined,
                onTap: () => context.go('/parent-home'),
                isAvailable: true,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoleButton extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;
  final bool isAvailable;

  const _RoleButton({
    required this.title,
    required this.icon,
    required this.onTap,
    this.isAvailable = true,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: isAvailable ? 1.0 : 0.5,
      child: ListTile(
        onTap: isAvailable ? onTap : null,
        leading: Icon(icon, color: SchoolGridTheme.primary),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        tileColor: SchoolGridTheme.primaryLight,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      ),
    );
  }
}
