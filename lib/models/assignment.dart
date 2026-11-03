class Assignment {
  final int? id;
  final int? diaryId;
  final String subjectName;
  final String taskDescription;

  Assignment({
    this.id,
    this.diaryId,
    required this.subjectName,
    required this.taskDescription,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'diary_id': diaryId,
      'subject_name': subjectName,
      'task_description': taskDescription,
    };
  }

  factory Assignment.fromMap(Map<String, dynamic> map) {
    return Assignment(
      id: map['id'],
      diaryId: map['diary_id'],
      subjectName: map['subject_name'],
      taskDescription: map['task_description'],
    );
  }

  Assignment copyWith({
    int? id,
    int? diaryId,
    String? subjectName,
    String? taskDescription,
  }) {
    return Assignment(
      id: id ?? this.id,
      diaryId: diaryId ?? this.diaryId,
      subjectName: subjectName ?? this.subjectName,
      taskDescription: taskDescription ?? this.taskDescription,
    );
  }
}
