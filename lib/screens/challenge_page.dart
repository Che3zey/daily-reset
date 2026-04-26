import 'dart:async';
import 'package:flutter/material.dart';
import '../models/task.dart';
import '../services/task_storage.dart';
import 'task_input_page.dart';
import 'settings_page.dart';
import '../services/theme_controller.dart';

class ChallengePage extends StatefulWidget {
  final ThemeController themeController;

  const ChallengePage({
    super.key,
    required this.themeController,
  });

  @override
  State<ChallengePage> createState() => _ChallengePageState();
}

class _ChallengePageState extends State<ChallengePage> {
  List<Task> tasks = [];

  List<String> dailyIds = [];
  List<String> weeklyIds = [];

  DateTime? lastDailyReset;
  DateTime? lastWeeklyReset;

  Timer? _timer;

  Duration dailyCountdown = Duration.zero;
  Duration weeklyCountdown = Duration.zero;
  Duration deadlineCountdown = Duration.zero;

  @override
  void initState() {
    super.initState();
    _init();

    _timer = Timer.periodic(const Duration(seconds: 1), (_) async {
      final beforeDaily = lastDailyReset;
      final beforeWeekly = lastWeeklyReset;

      await _handleResets();
      _updateCountdowns();

      final changed =
          beforeDaily != lastDailyReset ||
              beforeWeekly != lastWeeklyReset;

      if (changed) {
        setState(() {});
      } else {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _init() async {
    tasks = await TaskStorage.loadTasks();

    dailyIds = await TaskStorage.loadDailyIds();
    weeklyIds = await TaskStorage.loadWeeklyIds();

    lastDailyReset = await TaskStorage.loadDailyReset();
    lastWeeklyReset = await TaskStorage.loadWeeklyReset();

    await _handleResets();
    _updateCountdowns();

    setState(() {});
  }

  void _updateCountdowns() {
    final now = DateTime.now();

    final nextDaily = DateTime(now.year, now.month, now.day + 1);

    DateTime nextSunday =
    DateTime(now.year, now.month, now.day + (7 - now.weekday));

    if (now.weekday == DateTime.sunday) {
      nextSunday = nextSunday.add(const Duration(days: 7));
    }

    dailyCountdown = nextDaily.difference(now);
    weeklyCountdown = nextSunday.difference(now);

    final deadlines = tasks
        .where((t) => t.type == 'deadline' && !t.isCompleted)
        .toList()
      ..sort((a, b) => a.deadline!.compareTo(b.deadline!));

    if (deadlines.isNotEmpty) {
      deadlineCountdown =
          deadlines.first.deadline!.difference(now);
    } else {
      deadlineCountdown = Duration.zero;
    }
  }

  Future<void> _handleResets() async {
    final now = DateTime.now();

    final bool dailyReset = lastDailyReset == null ||
        now.year != lastDailyReset!.year ||
        now.month != lastDailyReset!.month ||
        now.day != lastDailyReset!.day;

    if (dailyReset) {
      final dailyPool =
      tasks.where((t) => t.type == 'daily').toList()..shuffle();

      dailyIds = dailyPool.take(4).map((t) => t.id).toList();

      for (var i = 0; i < tasks.length; i++) {
        if (dailyIds.contains(tasks[i].id)) {
          tasks[i] = tasks[i].copyWith(
            isCompleted: false,
            completedAt: null,
          );
        }
      }

      lastDailyReset = now;
      await TaskStorage.saveDailyIds(dailyIds);
      await TaskStorage.saveDailyReset(now);
    }

    final bool isSunday = now.weekday == DateTime.sunday;

    final bool weeklyReset = lastWeeklyReset == null ||
        (isSunday &&
            (lastWeeklyReset!.year != now.year ||
                lastWeeklyReset!.month != now.month ||
                lastWeeklyReset!.day != now.day));

    if (weeklyReset) {
      final weeklyPool =
      tasks.where((t) => t.type == 'weekly').toList()..shuffle();

      weeklyIds = weeklyPool.take(3).map((t) => t.id).toList();

      for (var i = 0; i < tasks.length; i++) {
        if (weeklyIds.contains(tasks[i].id)) {
          tasks[i] = tasks[i].copyWith(
            isCompleted: false,
            completedAt: null,
          );
        }
      }

      lastWeeklyReset = now;
      await TaskStorage.saveWeeklyIds(weeklyIds);
      await TaskStorage.saveWeeklyReset(now);
    }

    await TaskStorage.saveTasks(tasks);
  }

  Future<void> _forceReset() async {
    final dailyPool =
    tasks.where((t) => t.type == 'daily').toList()..shuffle();

    dailyIds = dailyPool.take(4).map((t) => t.id).toList();

    final weeklyPool =
    tasks.where((t) => t.type == 'weekly').toList()..shuffle();

    weeklyIds = weeklyPool.take(3).map((t) => t.id).toList();

    for (var i = 0; i < tasks.length; i++) {
      if (dailyIds.contains(tasks[i].id) ||
          weeklyIds.contains(tasks[i].id)) {
        tasks[i] = tasks[i].copyWith(
          isCompleted: false,
          completedAt: null,
        );
      }
    }

    await TaskStorage.saveDailyIds(dailyIds);
    await TaskStorage.saveWeeklyIds(weeklyIds);
    await TaskStorage.saveTasks(tasks);

    setState(() {});
  }

  List<Task> _getChallenges() {
    final daily = tasks.where((t) => dailyIds.contains(t.id)).toList();
    final weekly = tasks.where((t) => weeklyIds.contains(t.id)).toList();

    final deadlines = tasks
        .where((t) => t.type == 'deadline' && !t.isCompleted)
        .toList()
      ..sort((a, b) => a.deadline!.compareTo(b.deadline!));

    return [
      ...daily,
      ...weekly,
      if (deadlines.isNotEmpty) deadlines.first,
    ];
  }

  void _completeTask(Task task) {
    setState(() {
      final index = tasks.indexWhere((t) => t.id == task.id);
      if (index == -1) return;

      tasks[index] = tasks[index].copyWith(
        isCompleted: true,
        completedAt: DateTime.now(),
      );

      if (tasks[index].type == 'deadline') {
        tasks.removeAt(index);
      }
    });

    TaskStorage.saveTasks(tasks);
  }

  Future<void> _updateTasks(List<Task> updatedTasks) async {
    tasks = updatedTasks;
    await TaskStorage.saveTasks(tasks);
    setState(() {});
  }

  String _formatDaily(Duration d) =>
      "${d.inHours}h ${d.inMinutes.remainder(60)}m ${d.inSeconds.remainder(60)}s";

  String _formatWeekly(Duration d) =>
      "${d.inDays}d ${d.inHours.remainder(24)}h "
          "${d.inMinutes.remainder(60)}m ${d.inSeconds.remainder(60)}s";

  String _formatDeadline(Duration d) {
    if (d.isNegative) return "Overdue";
    return "${d.inDays}d ${d.inHours.remainder(24)}h "
        "${d.inMinutes.remainder(60)}m ${d.inSeconds.remainder(60)}s";
  }

  @override
  Widget build(BuildContext context) {
    final challenges = _getChallenges();

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,

        leading: IconButton(
          icon: const Icon(Icons.settings),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => SettingsPage(
                  themeController: widget.themeController,
                ),
              ),
            );
          },
        ),

        title: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Weeklies reset in ${_formatWeekly(weeklyCountdown)}",
              style: const TextStyle(fontSize: 12),
            ),
            Text(
              "Dailies reset in ${_formatDaily(dailyCountdown)}",
              style: const TextStyle(fontSize: 12),
            ),
            Text(
              "Deadline in ${_formatDeadline(deadlineCountdown)}",
              style: const TextStyle(fontSize: 12, color: Colors.orange),
            ),
          ],
        ),

        centerTitle: true,

        actions: [
          IconButton(
            icon: const Icon(Icons.add),
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

              await _init();
            },
          ),
        ],
      ),

      body: ListView.builder(
        itemCount: challenges.length,
        itemBuilder: (context, index) {
          final task = challenges[index];

          return ListTile(
            title: Text(
              task.title,
              style: TextStyle(
                decoration:
                task.isCompleted ? TextDecoration.lineThrough : null,
                color: task.isCompleted ? Colors.grey : null,
              ),
            ),
            subtitle: Text(
              task.isCompleted
                  ? "Completed at ${task.completedAt?.toLocal().toString().split('.')[0]}"
                  : task.type,
            ),
            trailing: IconButton(
              icon: Icon(
                task.isCompleted
                    ? Icons.check_circle
                    : Icons.check,
                color: task.isCompleted ? Colors.green : null,
              ),
              onPressed:
              task.isCompleted ? null : () => _completeTask(task),
            ),
          );
        },
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: _forceReset,
        child: const Icon(Icons.refresh),
      ),
    );
  }
}