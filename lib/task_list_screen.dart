import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'task.dart';

class TaskListScreen extends StatefulWidget {
  @override
  _TaskListScreenState createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _taskController = TextEditingController();

  Future<void> _addTask() async {
    if (_taskController.text.trim().isEmpty) return;

    await _firestore.collection('tasks').add({
      'name': _taskController.text.trim(),
      'isCompleted': false,
    });
    _taskController.clear();
  }

  Future<void> _toggleCompletion(Task task) async {
    await _firestore.collection('tasks').doc(task.id).update({
      'isCompleted': !task.isCompleted,
    });
  }

  Future<void> _deleteTask(Task task) async {
    await _firestore.collection('tasks').doc(task.id).delete();
  }

  void _signOut() async {
    await FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Task Manager"),
        actions: [
          IconButton(icon: Icon(Icons.logout), onPressed: _signOut),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _taskController,
              decoration: InputDecoration(labelText: 'Enter task name'),
            ),
          ),
          ElevatedButton(onPressed: _addTask, child: Text('Add Task')),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore.collection('tasks').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return CircularProgressIndicator();

                final tasks = snapshot.data!.docs.map((doc) {
                  return Task.fromMap(doc.data() as Map<String, dynamic>, doc.id);
                }).toList();

                return ListView.builder(
                  itemCount: tasks.length,
                  itemBuilder: (context, index) {
                    final task = tasks[index];
                    return ListTile(
                      title: Text(task.name),
                      leading: Checkbox(
                        value: task.isCompleted,
                        onChanged: (_) => _toggleCompletion(task),
                      ),
                      trailing: IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () => _deleteTask(task),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
