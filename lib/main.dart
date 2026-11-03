import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme.dart';
import 'providers/diary_provider.dart';
import 'screens/viewer_screen.dart';

void main() async {
  // Ensure Flutter bindings are initialized for SQLite and Path Provider
  WidgetsFlutterBinding.ensureInitialized();
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => DiaryProvider()),
      ],
      child: const DigitalHomeworkDiaryApp(),
    ),
  );
}

class DigitalHomeworkDiaryApp extends StatelessWidget {
  const DigitalHomeworkDiaryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Digital Homework Diary',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      // The app starts at the Viewer Screen (Parent/Student view)
      home: const ViewerScreen(),
    );
  }
}
