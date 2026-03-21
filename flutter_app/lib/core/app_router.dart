import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../features/auth/role_selection_screen.dart';
import '../features/auth/login_screen.dart';
import '../features/auth/signup_screen.dart';
import '../features/teacher/teacher_home_screen.dart';
import '../features/teacher/teacher_history_screen.dart';
import '../features/teacher/teacher_profile_screen.dart';
import '../features/teacher/help_center_screen.dart';
import '../features/parent/parent_home_screen.dart';
import '../features/parent/parent_history_screen.dart';
import '../features/parent/announcements_screen.dart';
import '../features/parent/parent_profile_screen.dart';

class TeacherMainLayout extends StatefulWidget {
  final Widget child;
  const TeacherMainLayout({super.key, required this.child});

  @override
  State<TeacherMainLayout> createState() => _TeacherMainLayoutState();
}

class _TeacherMainLayoutState extends State<TeacherMainLayout> {
  int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).uri.path;
    if (location.startsWith('/teacher-home')) return 0;
    if (location.startsWith('/teacher-history')) return 1;
    if (location.startsWith('/teacher-profile')) return 2;
    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go('/teacher-home');
        break;
      case 1:
        context.go('/teacher-history');
        break;
      case 2:
        context.go('/teacher-profile');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _calculateSelectedIndex(context),
        onTap: (index) => _onItemTapped(index, context),
        selectedItemColor: const Color(0xFF2563EB),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Home', activeIcon: Icon(Icons.home)),
          BottomNavigationBarItem(icon: Icon(Icons.history_outlined), label: 'History', activeIcon: Icon(Icons.history)),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profile', activeIcon: Icon(Icons.person)),
        ],
      ),
    );
  }
}

class ParentMainLayout extends StatefulWidget {
  final Widget child;
  const ParentMainLayout({super.key, required this.child});

  @override
  State<ParentMainLayout> createState() => _ParentMainLayoutState();
}

class _ParentMainLayoutState extends State<ParentMainLayout> {
  int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).uri.path;
    if (location.startsWith('/parent-home')) return 0;
    if (location.startsWith('/parent-news')) return 1;
    if (location.startsWith('/parent-history')) return 2;
    if (location.startsWith('/parent-profile')) return 3;
    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go('/parent-home');
        break;
      case 1:
        context.go('/parent-news');
        break;
      case 2:
        context.go('/parent-history');
        break;
      case 3:
        context.go('/parent-profile');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _calculateSelectedIndex(context),
        onTap: (index) => _onItemTapped(index, context),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF2563EB),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Home', activeIcon: Icon(Icons.home)),
          BottomNavigationBarItem(icon: Icon(Icons.notifications_none), label: 'News', activeIcon: Icon(Icons.notifications)),
          BottomNavigationBarItem(icon: Icon(Icons.history_outlined), label: 'History', activeIcon: Icon(Icons.history)),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profile', activeIcon: Icon(Icons.person)),
        ],
      ),
    );
  }
}

final GoRouter appRouter = GoRouter(
  initialLocation: '/auth',
  routes: [
    GoRoute(
      path: '/auth',
      builder: (context, state) => const RoleSelectionScreen(),
    ),
    GoRoute(
      path: '/teacher-login',
      builder: (context, state) => const LoginScreen(role: 'teacher'),
    ),
    GoRoute(
      path: '/teacher-signup',
      builder: (context, state) => const SignUpScreen(role: 'teacher'),
    ),
    GoRoute(
      path: '/parent-login',
      builder: (context, state) => const LoginScreen(role: 'parent'),
    ),
    GoRoute(
      path: '/parent-signup',
      builder: (context, state) => const SignUpScreen(role: 'parent'),
    ),
    ShellRoute(
      builder: (context, state, child) {
        return TeacherMainLayout(child: child);
      },
      routes: [
        GoRoute(
          path: '/teacher-home',
          builder: (context, state) => const TeacherHomeScreen(),
        ),
        GoRoute(
          path: '/teacher-history',
          builder: (context, state) => const TeacherHistoryScreen(),
        ),
        GoRoute(
          path: '/teacher-profile',
          builder: (context, state) => const TeacherProfileScreen(),
        ),
        GoRoute(
          path: '/teacher-help-center',
          builder: (context, state) => const HelpCenterScreen(),
        ),
      ],
    ),
    ShellRoute(
      builder: (context, state, child) {
        return ParentMainLayout(child: child);
      },
      routes: [
        GoRoute(
          path: '/parent-home',
          builder: (context, state) => const ParentHomeScreen(),
        ),
        GoRoute(
          path: '/parent-news',
          builder: (context, state) => const ParentNewsScreen(),
        ),
        GoRoute(
          path: '/parent-history',
          builder: (context, state) => const ParentHistoryScreen(),
        ),
        GoRoute(
          path: '/parent-profile',
          builder: (context, state) => const ParentProfileScreen(),
        ),
      ],
    ),
  ],
);
