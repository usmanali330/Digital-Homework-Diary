import 'package:flutter/material.dart';
import '../models/assignment.dart';
import '../models/subject.dart';
import 'subject_badge.dart';
import '../core/theme.dart';

class AssignmentRow extends StatelessWidget {
  final Assignment assignment;
  final Subject? subject;

  const AssignmentRow({
    super.key,
    required this.assignment,
    this.subject,
  });

  @override
  Widget build(BuildContext context) {
    final bool isNil = assignment.taskDescription.toLowerCase() == 'nil' ||
        assignment.taskDescription.isEmpty;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: SubjectBadge(
              name: assignment.subjectName,
              color: subject?.color ?? AppTheme.darkBlue,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              isNil ? 'Nil' : assignment.taskDescription,
              style: TextStyle(
                fontSize: 15,
                color: isNil ? Colors.grey : Colors.black87,
                fontStyle: isNil ? FontStyle.italic : FontStyle.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
