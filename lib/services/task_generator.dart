import '../models/task.dart';

class TaskGenerator {
  static List<Task> generateChallenges(List<Task> tasks) {
    final daily = tasks.where((t) => t.type == 'daily').toList();
    final weekly = tasks.where((t) => t.type == 'weekly').toList();
    final deadlines =
    tasks.where((t) => t.type == 'deadline').toList();

    daily.shuffle();
    weekly.shuffle();

    // sort deadlines by closest due date
    deadlines.sort((a, b) {
      if (a.deadline == null) return 1;
      if (b.deadline == null) return -1;
      return a.deadline!.compareTo(b.deadline!);
    });

    final result = <Task>[];

    result.addAll(daily.take(4));
    result.addAll(weekly.take(3));
    result.addAll(deadlines.take(2));

    return result.take(8).toList();
  }
}