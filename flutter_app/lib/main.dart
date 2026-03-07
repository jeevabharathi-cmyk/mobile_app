import 'package:flutter/material.dart';
import 'core/theme.dart';
import 'core/app_router.dart';

void main() {
  runApp(const SchoolGridApp());
}

class SchoolGridApp extends StatelessWidget {
  const SchoolGridApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'SchoolGrid Central',
      theme: SchoolGridTheme.lightTheme,
      routerConfig: appRouter,
      debugShowCheckedModeBanner: false,
    );
  }
}
