import 'package:flutter/material.dart';

import 'main.dart';

void main() {
  // Production environment ke liye
  runApp(
    const TaskMateApp(appName: 'TaskMate', apiUrl: 'https://api.taskmate.com'),
  );
}
