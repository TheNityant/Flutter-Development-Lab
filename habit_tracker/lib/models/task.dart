class Task {
  final String id;
  final String title;
  final bool isCompleted;
  final String priority;
  final String category;

  Task({
    required this.id,
    required this.title,
    this.isCompleted = false,
    this.priority = 'Medium',
    this.category = 'Other',
  });

  // --- NEW: The CopyWith Helper ---
  // This lets us create a new version of the task with updated values
  Task copyWith({
    String? id,
    String? title,
    bool? isCompleted,
    String? priority,
    String? category,
  }) {
    return Task(
      id: id ?? this.id, // If new ID provided, use it. If not, keep old one.
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
      priority: priority ?? this.priority,
      category: category ?? this.category,
    );
  }

  // Database Helpers
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'isCompleted': isCompleted ? 1 : 0,
      'priority': priority,
      'category': category,
    };
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'],
      title: map['title'],
      isCompleted: map['isCompleted'] == 1,
      priority: map['priority'] ?? 'Medium',
      category: map['category'] ?? 'Other',
    );
  }
}