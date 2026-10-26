import 'package:flutter/material.dart';

import 'screens/home_screen.dart';

class TaskMateApp extends StatefulWidget {
  // 👇 Yeh 2 lines miss ho gayi hain aapke code mein
  final String appName;
  final String apiUrl;

  // 👇 Constructor update karna hai
  const TaskMateApp({super.key, required this.appName, required this.apiUrl});

  @override
  State<TaskMateApp> createState() => _TaskMateAppState();
}

class _TaskMateAppState extends State<TaskMateApp> {
  bool _isDarkMode = false;

  void _toggleTheme() {
    setState(() {
      _isDarkMode = !_isDarkMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: widget.appName, // 👈 Yahan widget.appName use kiya
      debugShowCheckedModeBanner: false,
      themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.indigo,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: HomeScreen(onToggleTheme: _toggleTheme, isDarkMode: _isDarkMode),
    );
  }
}
