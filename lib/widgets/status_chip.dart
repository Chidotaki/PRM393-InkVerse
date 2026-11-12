import 'package:flutter/material.dart';

import '../models/novel.dart';

/// Compact visual indicator for ongoing, completed, or hiatus novel states.
class StatusChip extends StatelessWidget {
  final NovelStatus status;

  const StatusChip({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    IconData icon;

    switch (status) {
      case NovelStatus.ongoing:
        bg = const Color(0xFF064E3B);
        fg = const Color(0xFF34D399);
        icon = Icons.auto_stories;
        break;
      case NovelStatus.completed:
        bg = const Color(0xFF1E3A8A);
        fg = const Color(0xFF60A5FA);
        icon = Icons.check_circle_outline;
        break;
      case NovelStatus.hiatus:
        bg = const Color(0xFF78350F);
        fg = const Color(0xFFFBBF24);
        icon = Icons.pause_circle_outline;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: fg.withValues(alpha: 0.4), width: 0.75),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: fg),
          const SizedBox(width: 4),
          Text(
            status.label,
            style: TextStyle(
              color: fg,
              fontSize: 10,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}
