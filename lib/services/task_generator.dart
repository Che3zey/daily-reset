import '../models/task.dart';

class TaskGenerator {

  //MAIN CHALLENGE BUILDER THIS IS F#$KING IMPORTANT

  static List<Task> generateChallenges(List<Task> tasks) {
    final daily = tasks
        .where((t) => t.type == 'daily')
        .toList();

    final weekly = tasks
        .where((t) => t.type == 'weekly')
        .toList();

    final deadlines = tasks
        .where((t) => t.type == 'deadline' && !t.isCompleted)
        .toList();

    daily.shuffle();
    weekly.shuffle();

    deadlines.sort((a, b) {
      final aTime = a.deadline ?? DateTime(9999);
      final bTime = b.deadline ?? DateTime(9999);
      return aTime.compareTo(bTime);
    });

    final result = <Task>[];

    result.addAll(daily.take(4));
    result.addAll(weekly.take(3));
    result.addAll(deadlines.take(2));

    return result;
  }


  //DEADLINE REPLACEMENT LOGIC

  static List<Task> getTopDeadlines(List<Task> tasks, int count) {
    final deadlines = tasks
        .where((t) => t.type == 'deadline' && !t.isCompleted && t.deadline != null)
        .toList();

    deadlines.sort((a, b) => a.deadline!.compareTo(b.deadline!));

    return deadlines.take(count).toList();
  }


  //LIVE UPDATE VERSION (used after the completion)

  static List<Task> updateChallengesAfterCompletion(
      List<Task> tasks,
      List<Task> currentChallenges,
      ) {
    final updated = List<Task>.from(currentChallenges);

    //remove the completed deadlines from view
    updated.removeWhere((t) =>
    t.type == 'deadline' &&
        t.isCompleted);

    //refill the missing deadline slots
    final needed = 2 - updated.where((t) => t.type == 'deadline').length;

    if (needed > 0) {
      final replacements = getTopDeadlines(tasks, needed);
      updated.addAll(replacements);
    }

    return updated;
  }
}