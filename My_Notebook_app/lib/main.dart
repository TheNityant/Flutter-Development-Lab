import 'package:flutter/material.dart';
import 'dart:convert'; // Import this for JSON encoding
import 'package:shared_preferences/shared_preferences.dart'; // Import this for saving
import 'package:home_widget/home_widget.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MY NOTEBOOK',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Task> myTasks = [];
  final TextEditingController _taskController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData(); // Load data when app starts
  }

  // --- SAVING & LOADING LOGIC ---
  
  // 1. Save the list to disk
  void _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> jsonList = myTasks.map((task) => jsonEncode(task.toMap())).toList();
    await prefs.setStringList('user_tasks', jsonList);

    // --- NEW WIDGET CODE ---
    // 1. Get the first task name (or "All done!" if empty)
    String nextTaskName = "All done!";
    if (myTasks.isNotEmpty) {
      // Find the first task that isn't completed
      var pending = myTasks.where((t) => !t.isCompleted);
      if (pending.isNotEmpty) {
        nextTaskName = pending.first.name;
      }
    }

    // 2. Send it to the Widget
    await HomeWidget.saveWidgetData<String>('widget_task_text', nextTaskName);
    await HomeWidget.updateWidget(
      name: 'HomeWidgetProvider', // Must match the Manifest name
      androidName: 'HomeWidgetProvider',
      iOSName: 'HomeWidgetProvider',
    );
    // -----------------------
  }

  // 2. Load the list from disk
  void _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    List<String>? jsonList = prefs.getStringList('user_tasks');
    
    if (jsonList != null) {
      setState(() {
        myTasks = jsonList.map((item) => Task.fromMap(jsonDecode(item))).toList();
      });
    }
  }

  void _addNewTask() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('New Task'),
          content: TextField(
            controller: _taskController,
            decoration: const InputDecoration(hintText: "What do you need to do?"),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _taskController.clear();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (_taskController.text.isNotEmpty) {
                  setState(() {
                    myTasks.add(Task(name: _taskController.text));
                  });
                  _saveData(); // <--- SAVE AFTER ADDING
                  Navigator.of(context).pop();
                  _taskController.clear();
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('MY NOTEBOOK')),
      body: ListView.builder(
        itemCount: myTasks.length,
        itemBuilder: (context, index) {
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: ListTile(
              leading: Checkbox(
                value: myTasks[index].isCompleted,
                onChanged: (bool? value) {
                  setState(() {
                    myTasks[index].isCompleted = value!;
                  });
                  _saveData(); // <--- SAVE AFTER CHECKING
                },
              ),
              title: Text(
                myTasks[index].name,
                style: TextStyle(
                  decoration: myTasks[index].isCompleted
                      ? TextDecoration.lineThrough
                      : TextDecoration.none,
                ),
              ),
              trailing: IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () {
                  setState(() {
                    myTasks.removeAt(index);
                  });
                  _saveData(); // <--- SAVE AFTER DELETING
                },
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addNewTask,
        tooltip: 'Add Task',
        child: const Icon(Icons.add),
      ),
    );
  }
}

// Put this at the very bottom of main.dart
class Task {
  String name;
  bool isCompleted;

  Task({required this.name, this.isCompleted = false});

  // Convert a Task object into a Map (JSON)
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'isCompleted': isCompleted,
    };
  }

  // Convert a Map (JSON) back into a Task object
  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      name: map['name'],
      isCompleted: map['isCompleted'],
    );
  }
}