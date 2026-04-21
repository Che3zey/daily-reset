class Task {
  final String id;
  final String title;
  final String type; // daily, weekly, deadline
  final DateTime? deadline;

  bool isCompleted;
  DateTime? completedAt;

  Task({
    required this.id,
    required this.title,
    required this.type,
    this.deadline,
    this.isCompleted = false,
    this.completedAt,
  });

  // 🔥 Convert Task → JSON (for Hive storage)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'type': type,
      'deadline': deadline?.toIso8601String(),
      'isCompleted': isCompleted,
      'completedAt': completedAt?.toIso8601String(),
    };
  }

  // 🔥 Convert JSON → Task (for loading from Hive)
  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      title: json['title'],
      type: json['type'],
      deadline: json['deadline'] != null
          ? DateTime.parse(json['deadline'])
          : null,
      isCompleted: json['isCompleted'] ?? false,
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'])
          : null,
    );
  }

  // 🔥 helper: checks if task is expired
  bool get isExpired {
    if (type != 'deadline' || deadline == null) return false;
    return DateTime.now().isAfter(deadline!);
  }

  // 🔥 helper: days remaining
  int? get daysLeft {
    if (deadline == null) return null;
    return deadline!.difference(DateTime.now()).inDays;
  }

  // 🔥 copyWith (state safety)
  Task copyWith({
    String? id,
    String? title,
    String? type,
    DateTime? deadline,
    bool? isCompleted,
    DateTime? completedAt,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      type: type ?? this.type,
      deadline: deadline ?? this.deadline,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: completedAt ?? this.completedAt,
    );
  }
}