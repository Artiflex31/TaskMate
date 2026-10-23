import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'dart:convert';

// 👇 IMPORTS: Yahan humne baaki files ko bulaya
import '../widgets/task_tile.dart';
import 'task_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback onToggleTheme;
  final bool isDarkMode;
  const HomeScreen({
    super.key,
    required this.onToggleTheme,
    required this.isDarkMode,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, dynamic>> tasks = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final String? savedTasksString = prefs.getString('my_tasks');

    if (savedTasksString != null) {
      List<dynamic> decoded = jsonDecode(savedTasksString);
      setState(() {
        tasks = decoded.map((item) {
          return {
            'title': item['title'],
            'isDone': item['isDone'],
            'priority': item['priority'] ?? 'Low',
          };
        }).toList();
      });
    } else {
      setState(() {
        tasks = [
          {'title': 'Buy groceries', 'isDone': false, 'priority': 'High'},
          {'title': 'Call mom', 'isDone': true, 'priority': 'Medium'},
          {'title': 'Finish Flutter app', 'isDone': false, 'priority': 'Low'},
        ];
      });
    }
  }

  Future<void> _saveTasks() async {
    final prefs = await SharedPreferences.getInstance();
    String encodedData = jsonEncode(tasks);
    await prefs.setString('my_tasks', encodedData);
  }

  void _addTask() {
    String newTask = '';
    String selectedPriority = 'Low';

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Naya Task Add karein'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    onChanged: (value) => newTask = value,
                    decoration: const InputDecoration(
                      hintText: 'Write the task name...',
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: selectedPriority,
                    decoration: const InputDecoration(
                      labelText: 'Priority',
                      border: OutlineInputBorder(),
                    ),
                    items: ['High', 'Medium', 'Low'].map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (newValue) {
                      setDialogState(() {
                        selectedPriority = newValue!;
                      });
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (newTask.isNotEmpty) {
                      setState(() {
                        tasks.add({
                          'title': newTask,
                          'isDone': false,
                          'priority': selectedPriority,
                        });
                      });
                      _saveTasks();
                    }
                    Navigator.pop(context);
                  },
                  child: const Text('Add'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _deleteAllTasks() {
    setState(() {
      tasks.clear();
    });
    _saveTasks();
  }

  void _toggleTask(int index) {
    setState(() {
      tasks[index]['isDone'] = !tasks[index]['isDone'];
    });
    _saveTasks();
  }

  void _deleteTask(int index) {
    setState(() {
      tasks.removeAt(index);
    });
    _saveTasks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TaskMate'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(widget.isDarkMode ? Icons.light_mode : Icons.dark_mode),
            onPressed: widget.onToggleTheme,
          ),
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            onPressed: _deleteAllTasks,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Search tasks...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
              ),
              onChanged: (value) {
                setState(() {});
              },
            ),
          ),
          Expanded(
            child: Builder(
              builder: (context) {
                final String searchText = _searchController.text.toLowerCase();

                final List<Map<String, dynamic>> filteredTasks = tasks.where((
                  task,
                ) {
                  final String title = task['title'].toString().toLowerCase();
                  return title.contains(searchText);
                }).toList();

                if (filteredTasks.isEmpty && searchText.isNotEmpty) {
                  return const Center(child: Text('Koi task nahi mila!'));
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: filteredTasks.length,
                  itemBuilder: (context, index) {
                    final task = filteredTasks[index];

                    return TaskTile(
                      title: task['title'],
                      isDone: task['isDone'],
                      priority: task['priority'] ?? 'Low',
                      onToggle: () {
                        _toggleTask(tasks.indexOf(task));
                      },
                      onDelete: () {
                        _deleteTask(tasks.indexOf(task));
                      },
                      onTap: () async {
                        final updatedTitle = await Navigator.push<String>(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                TaskDetailScreen(taskTitle: task['title']),
                          ),
                        );

                        if (updatedTitle != null &&
                            updatedTitle.trim().isNotEmpty) {
                          setState(() {
                            task['title'] = updatedTitle.trim();
                          });
                          _saveTasks();
                        }
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addTask,
        child: const Icon(Icons.add),
      ),
    );
  }
}
