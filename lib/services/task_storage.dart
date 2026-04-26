import 'package:hive/hive.dart';
import '../models/task.dart';

class TaskStorage {
  static const String boxName = "tasksBox";

  static const String tasksKey = "tasks";

  // challenge selection IDs
  static const String dailyIdsKey = "daily_ids";
  static const String weeklyIdsKey = "weekly_ids";

  // this is reset tracking
  static const String dailyResetKey = "daily_reset";
  static const String weeklyResetKey = "weekly_reset";

  static Box? _box;

  static Future<Box> _getBox() async {
    if (_box != null && _box!.isOpen) return _box!;
    _box = await Hive.openBox(boxName);
    return _box!;
  }

  // tasks vvv

  static Future<void> saveTasks(List<Task> tasks) async {
    final box = await _getBox();
    final data = tasks.map((t) => t.toJson()).toList();
    await box.put(tasksKey, data);
  }

  static Future<List<Task>> loadTasks() async {
    final box = await _getBox();
    final raw = box.get(tasksKey);

    if (raw == null || raw is! List) return [];

    return raw
        .map((e) => Task.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  //ID for dailies vvv

  static Future<void> saveDailyIds(List<String> ids) async {
    final box = await _getBox();
    await box.put(dailyIdsKey, ids);
  }

  static Future<List<String>> loadDailyIds() async {
    final box = await _getBox();
    final data = box.get(dailyIdsKey, defaultValue: []);
    return List<String>.from(data);
  }

  // ID for weeklies vvv

  static Future<void> saveWeeklyIds(List<String> ids) async {
    final box = await _getBox();
    await box.put(weeklyIdsKey, ids);
  }

  static Future<List<String>> loadWeeklyIds() async {
    final box = await _getBox();
    final data = box.get(weeklyIdsKey, defaultValue: []);
    return List<String>.from(data);
  }

  // the times for resets vvv

  static Future<void> saveDailyReset(DateTime time) async {
    final box = await _getBox();
    await box.put(dailyResetKey, time.toIso8601String());
  }

  static Future<DateTime?> loadDailyReset() async {
    final box = await _getBox();
    final raw = box.get(dailyResetKey);
    if (raw == null) return null;
    return DateTime.tryParse(raw);
  }

  static Future<void> saveWeeklyReset(DateTime time) async {
    final box = await _getBox();
    await box.put(weeklyResetKey, time.toIso8601String());
  }

  static Future<DateTime?> loadWeeklyReset() async {
    final box = await _getBox();
    final raw = box.get(weeklyResetKey);
    if (raw == null) return null;
    return DateTime.tryParse(raw);
  }
}