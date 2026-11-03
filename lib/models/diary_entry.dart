import 'assignment.dart';

class DiaryEntry {
  final int? id;
  final String date; // YYYY-MM-DD
  final int gradeId;
  final String schoolName;
  final String schoolAddress;
  final String welcomeMessage;
  final String footerMessage;
  final String teacherName;
  final String principalName;
  final List<Assignment> assignments;

  DiaryEntry({
    this.id,
    required this.date,
    required this.gradeId,
    required this.schoolName,
    required this.schoolAddress,
    required this.welcomeMessage,
    required this.footerMessage,
    required this.teacherName,
    required this.principalName,
    this.assignments = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date,
      'grade_id': gradeId,
      'school_name': schoolName,
      'school_address': schoolAddress,
      'welcome_message': welcomeMessage,
      'footer_message': footerMessage,
      'teacher_name': teacherName,
      'principal_name': principalName,
    };
  }

  factory DiaryEntry.fromMap(Map<String, dynamic> map, {List<Assignment> assignments = const []}) {
    return DiaryEntry(
      id: map['id'],
      date: map['date'],
      gradeId: map['grade_id'],
      schoolName: map['school_name'],
      schoolAddress: map['school_address'],
      welcomeMessage: map['welcome_message'],
      footerMessage: map['footer_message'],
      teacherName: map['teacher_name'],
      principalName: map['principal_name'],
      assignments: assignments,
    );
  }

  DiaryEntry copyWith({
    int? id,
    String? date,
    int? gradeId,
    String? schoolName,
    String? schoolAddress,
    String? welcomeMessage,
    String? footerMessage,
    String? teacherName,
    String? principalName,
    List<Assignment>? assignments,
  }) {
    return DiaryEntry(
      id: id ?? this.id,
      date: date ?? this.date,
      gradeId: gradeId ?? this.gradeId,
      schoolName: schoolName ?? this.schoolName,
      schoolAddress: schoolAddress ?? this.schoolAddress,
      welcomeMessage: welcomeMessage ?? this.welcomeMessage,
      footerMessage: footerMessage ?? this.footerMessage,
      teacherName: teacherName ?? this.teacherName,
      principalName: principalName ?? this.principalName,
      assignments: assignments ?? this.assignments,
    );
  }
}
