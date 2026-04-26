class Task {
  final String id;
  final String title;
  final String type; // daily weekly and deadline
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

  // to json
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

  // from json
  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      title: json['title'],
      type: json['type'],
      deadline: json['deadline'] != null
          ? DateTime.tryParse(json['deadline'])
          : null,
      isCompleted: json['isCompleted'] ?? false,
      completedAt: json['completedAt'] != null
          ? DateTime.tryParse(json['completedAt'])
          : null,
    );
  }

  // hospice employee (helpers)
  bool get isExpired {
    if (type != 'deadline' || deadline == null) return false;
    return DateTime.now().isAfter(deadline!);
  }

  int? get daysLeft {
    if (deadline == null) return null;
    return deadline!.difference(DateTime.now()).inDays;
  }

  // copy with
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