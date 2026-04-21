import 'package:flutter/material.dart';
import '../models/task.dart';
import '../services/task_generator.dart';
import '../services/task_storage.dart';
import 'task_input_page.dart';

class ChallengePage extends StatefulWidget {
  const ChallengePage({super.key});

  @override
  State<ChallengePage> createState() => _ChallengePageState();
}

class _ChallengePageState extends State<ChallengePage> {
  List<Task> tasks = [];
  List<Task> challenges = [];

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  // 🔥 LOAD FROM HIVE (FIXED)
  void _loadTasks() async {
    final loaded = await TaskStorage.loadTasks();

    setState(() {
      tasks = loaded;
      _refreshChallenges();
    });
  }

  // 🔥 SAVE TO HIVE
  Future<void> _saveTasks() async {
    await TaskStorage.saveTasks(tasks);
    print("💾 SAVING TASKS: ${tasks.length}");
  }

  // 🔥 GENERATE CHALLENGES
  void _refreshChallenges() {
    challenges = TaskGenerator.generateChallenges(tasks);
  }

  // 🔥 COMPLETE TASK
  void _completeTask(Task task) {
    setState(() {
      final index = tasks.indexWhere((t) => t.id == task.id);

      if (index != -1) {
        tasks[index] = tasks[index].copyWith(
          isCompleted: true,
          completedAt: DateTime.now(),
        );

        // 🔥 RULE: deadline tasks removed after completion
        if (tasks[index].type == 'deadline') {
          tasks.removeAt(index);
        }
      }

      _refreshChallenges();
    });

    _saveTasks();
  }

  // 🔥 UPDATE FROM INPUT PAGE
  void _updateTasks(List<Task> updatedTasks) {
    setState(() {
      tasks = updatedTasks;
      _refreshChallenges();
    });

    _saveTasks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Today's Challenges"),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => TaskInputPage(
                    tasks: tasks,
                    onTasksUpdated: _updateTasks,
                  ),
                ),
              );
            },
          ),
        ],
      ),

      body: ListView.builder(
        itemCount: challenges.length,
        itemBuilder: (context, index) {
          final task = challenges[index];
          final isDone = task.isCompleted;

          return ListTile(
            title: Text(
              task.title,
              style: TextStyle(
                decoration:
                isDone ? TextDecoration.lineThrough : null,
                color: isDone ? Colors.grey : null,
              ),
            ),

            subtitle: Text(
              isDone
                  ? "Completed at ${task.completedAt?.toLocal().toString().split('.')[0]}"
                  : task.type,
            ),

            trailing: IconButton(
              icon: Icon(
                isDone ? Icons.check_circle : Icons.check,
                color: isDone ? Colors.green : null,
              ),
              onPressed: isDone ? null : () => _completeTask(task),
            ),
          );
        },
      ),
    );
  }
}