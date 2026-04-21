import 'package:hive/hive.dart';
import '../models/task.dart';

class TaskStorage {
  static const String boxName = "tasksBox";
  static const String key = "tasks";

  // 🔥 NEW KEYS FOR RESET SYSTEM
  static const String dailyKey = "lastDailyReset";
  static const String weeklyKey = "lastWeeklyReset";

  static Box? _box;

  // 🔥 OPEN BOX ONCE (FIXES WEB PERSISTENCE ISSUE)
  static Future<Box> _getBox() async {
    if (_box != null && _box!.isOpen) {
      return _box!;
    }

    _box = await Hive.openBox(boxName);
    return _box!;
  }

  // 🔥 SAVE TASKS
  static Future<void> saveTasks(List<Task> tasks) async {
    final box = await _getBox();

    final data = tasks.map((t) => t.toJson()).toList();

    await box.put(key, data);

    print("💾 SAVED TASKS: ${tasks.length}");
  }

  // 🔥 LOAD TASKS
  static Future<List<Task>> loadTasks() async {
    final box = await _getBox();

    final raw = box.get(key);

    print("📦 RAW HIVE DATA: $raw");

    if (raw == null) {
      print("⚠️ No data found in Hive");
      return [];
    }

    if (raw is! List) {
      print("⚠️ Invalid Hive format");
      return [];
    }

    final tasks = <Task>[];

    for (final item in raw) {
      try {
        if (item is Map) {
          tasks.add(Task.fromJson(
            Map<String, dynamic>.from(item),
          ));
        } else {
          print("⚠️ Skipping invalid item: $item");
        }
      } catch (e) {
        print("❌ Parse error: $e");
      }
    }

    print("📦 TASK COUNT AFTER PARSE: ${tasks.length}");
    return tasks;
  }

  // ============================
  // 🔥 DAILY RESET STORAGE
  // ============================

  static Future<void> saveDailyReset(DateTime time) async {
    final box = await _getBox();
    await box.put(dailyKey, time.toIso8601String());
  }

  static Future<DateTime?> loadDailyReset() async {
    final box = await _getBox();
    final raw = box.get(dailyKey);

    if (raw == null) return null;

    return DateTime.tryParse(raw);
  }

  // ============================
  // 🔥 WEEKLY RESET STORAGE
  // ============================

  static Future<void> saveWeeklyReset(DateTime time) async {
    final box = await _getBox();
    await box.put(weeklyKey, time.toIso8601String());
  }

  static Future<DateTime?> loadWeeklyReset() async {
    final box = await _getBox();
    final raw = box.get(weeklyKey);

    if (raw == null) return null;

    return DateTime.tryParse(raw);
  }

  // 🔥 CLEAR (FOR TESTING)
  static Future<void> clear() async {
    final box = await _getBox();
    await box.clear();
    print("🧹 ALL TASKS CLEARED");
  }
}