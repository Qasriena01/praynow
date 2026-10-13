class DhikrGoal {
  final int? id;
  final String dhikrName;
  final int targetCount;
  final int currentCount;
  final DateTime startDate;
  final DateTime? completionDate;
  final bool isCompleted;

  DhikrGoal({
    this.id,
    required this.dhikrName,
    required this.targetCount,
    required this.currentCount,
    required this.startDate,
    this.completionDate,
    required this.isCompleted,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'dhikrName': dhikrName,
      'targetCount': targetCount,
      'currentCount': currentCount,
      'startDate': startDate.toIso8601String(),
      'completionDate': completionDate?.toIso8601String(),
      'isCompleted': isCompleted ? 1 : 0,
    };
  }

  factory DhikrGoal.fromMap(Map<String, dynamic> map) {
    return DhikrGoal(
      id: map['id'],
      dhikrName: map['dhikrName'],
      targetCount: map['targetCount'],
      currentCount: map['currentCount'],
      startDate: DateTime.parse(map['startDate']),
      completionDate: map['completionDate'] != null 
          ? DateTime.parse(map['completionDate']) 
          : null,
      isCompleted: map['isCompleted'] == 1,
    );
  }

  // FIXED: Proper copyWith that can handle null values
  DhikrGoal copyWith({
    int? id,
    String? dhikrName,
    int? targetCount,
    int? currentCount,
    DateTime? startDate,
    DateTime? completionDate,
    bool? isCompleted,
    bool clearCompletionDate = false, // Add this flag
  }) {
    return DhikrGoal(
      id: id ?? this.id,
      dhikrName: dhikrName ?? this.dhikrName,
      targetCount: targetCount ?? this.targetCount,
      currentCount: currentCount ?? this.currentCount,
      startDate: startDate ?? this.startDate,
      completionDate: clearCompletionDate ? null : (completionDate ?? this.completionDate),
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  double get progressPercentage => (currentCount / targetCount * 100).clamp(0, 100);
}