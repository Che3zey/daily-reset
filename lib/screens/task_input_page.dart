import 'package:flutter/material.dart';
import '../models/task.dart';

class TaskInputPage extends StatefulWidget {
  final List<Task> tasks;
  final Function(List<Task>) onTasksUpdated;

  const TaskInputPage({
    super.key,
    required this.tasks,
    required this.onTasksUpdated,
  });

  @override
  State<TaskInputPage> createState() => _TaskInputPageState();
}

class _TaskInputPageState extends State<TaskInputPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();

  String _type = 'daily';
  DateTime? _selectedDeadline;

  late List<Task> tasks;

  @override
  void initState() {
    super.initState();
    tasks = List.from(widget.tasks);
  }

  //sync witht he parent(ChallengePage -> Hive)
  void _sync() {
    widget.onTasksUpdated(tasks);
  }

  //picking deadline
  Future<void> _pickDeadline() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        _selectedDeadline = picked;
      });
    }
  }

  //adding tasks
  void _addTask() {
    if (_formKey.currentState!.validate()) {
      if (_type == 'deadline' && _selectedDeadline == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please select a deadline date")),
        );
        return;
      }

      final task = Task(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: _titleController.text.trim(),
        type: _type,
        deadline: _type == 'deadline' ? _selectedDeadline : null,
      );

      setState(() {
        tasks.add(task);

        _titleController.clear();
        _selectedDeadline = null;

        _sync();
      });
    }
  }

  //deleting tasks
  void _deleteTask(int index) {
    setState(() {
      tasks.removeAt(index);
      _sync();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Manager'),
      ),

      body: Column(
        children: [
          //the input section
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      labelText: 'Task Title',
                    ),
                    validator: (value) =>
                    value == null || value.isEmpty
                        ? 'Enter a title'
                        : null,
                  ),

                  const SizedBox(height: 10),

                  DropdownButtonFormField<String>(
                    value: _type,
                    items: const [
                      DropdownMenuItem(value: 'daily', child: Text('Daily')),
                      DropdownMenuItem(value: 'weekly', child: Text('Weekly')),
                      DropdownMenuItem(value: 'deadline', child: Text('Deadline')),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _type = value);
                      }
                    },
                    decoration: const InputDecoration(
                      labelText: 'Task Type',
                    ),
                  ),

                  const SizedBox(height: 10),

                  //also for deadline
                  if (_type == 'deadline') ...[
                    ElevatedButton(
                      onPressed: _pickDeadline,
                      child: const Text('Pick Deadline Date'),
                    ),

                    if (_selectedDeadline != null)
                      Text(
                        "Due: ${_selectedDeadline!.toLocal().toString().split(' ')[0]}",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                  ],

                  const SizedBox(height: 10),

                  ElevatedButton(
                    onPressed: _addTask,
                    child: const Text('Add Task'),
                  ),
                ],
              ),
            ),
          ),

          const Divider(),

          //the task list
          Expanded(
            child: ListView.builder(
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                final task = tasks[index];

                return ListTile(
                  title: Text(task.title),

                  subtitle: Text(
                    task.type +
                        (task.deadline != null
                            ? " | Due: ${task.deadline!.toLocal().toString().split(' ')[0]}"
                            : ""),
                  ),

                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => _deleteTask(index),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}