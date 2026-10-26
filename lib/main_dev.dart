import 'package:flutter/material.dart';

import 'main.dart';

void main() {
  // Dev environment ke liye
  runApp(
    const TaskMateApp(
      appName: 'TaskMate Dev',
      apiUrl: 'https://dev.api.taskmate.com',
    ),
  );
}
