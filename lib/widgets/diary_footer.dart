import 'package:flutter/material.dart';
import '../core/theme.dart';

class DiaryFooter extends StatelessWidget {
  final String footerMessage;
  final String teacherName;
  final String principalName;

  const DiaryFooter({
    super.key,
    required this.footerMessage,
    required this.teacherName,
    required this.principalName,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(height: 32),
        Text(
          footerMessage,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.black54,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildSignatureLine('Checked by Teacher', teacherName),
            _buildSignatureLine('Principal Signature', principalName),
          ],
        ),
      ],
    );
  }

  Widget _buildSignatureLine(String label, String name) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          name,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: AppTheme.darkBlue,
          ),
        ),
        Container(
          width: 120,
          height: 1,
          color: Colors.black26,
          margin: const EdgeInsets.symmetric(vertical: 4),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 10, color: Colors.black54),
        ),
      ],
    );
  }
}
