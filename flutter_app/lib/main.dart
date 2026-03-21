import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/services/homework_service.dart';
import 'core/theme.dart';
import 'core/app_router.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => HomeworkService()),
      ],
      child: const SchoolGridApp(),
    ),
  );
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
