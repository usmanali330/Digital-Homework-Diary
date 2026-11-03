import 'package:flutter/material.dart';
import '../core/theme.dart';

class GreetingBanner extends StatelessWidget {
  final String message;

  const GreetingBanner({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppTheme.softPink,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            const Icon(Icons.wb_sunny, color: AppTheme.accentOrange),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.darkBlue,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
