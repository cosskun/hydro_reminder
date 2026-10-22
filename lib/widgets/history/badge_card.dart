import 'package:flutter/material.dart';
import '../../models/badge_item.dart';

class BadgeCard extends StatelessWidget {
  final BadgeItem badge;
  final bool isDark;

  const BadgeCard({
    super.key,
    required this.badge,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
      decoration: BoxDecoration(
        color: badge.isUnlocked
            ? (isDark ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.15) : Colors.amber.shade50.withValues(alpha: 0.4))
            : (isDark ? const Color(0xFF0B132B) : Colors.grey.shade50),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: badge.isUnlocked
              ? (isDark ? Theme.of(context).colorScheme.primary : Colors.amber.shade300)
              : (isDark ? const Color(0xFF3A506B).withValues(alpha: 0.4) : Colors.grey.shade200),
          width: badge.isUnlocked ? 1.4 : 1.0,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            badge.icon,
            style: TextStyle(
              fontSize: 26,
              color: badge.isUnlocked ? null : Colors.grey,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            badge.title,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.bold,
              color: badge.isUnlocked
                  ? (isDark ? const Color(0xFFF1F5F9) : const Color(0xFF0F172A))
                  : (isDark ? const Color(0xFF64748B) : Colors.grey),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            badge.isUnlocked ? 'Kazanıldı' : badge.progressLabel,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 9,
              fontWeight: badge.isUnlocked ? FontWeight.bold : FontWeight.w500,
              color: badge.isUnlocked
                  ? (isDark ? Colors.amber.shade300 : Colors.amber.shade800)
                  : (isDark ? const Color(0xFF94A3B8) : Colors.grey.shade600),
            ),
          ),
          if (!badge.isUnlocked) ...[
            const SizedBox(height: 4),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: badge.currentProgress,
                minHeight: 3,
                backgroundColor: isDark ? const Color(0xFF3A506B) : Colors.grey.shade200,
                valueColor: AlwaysStoppedAnimation<Color>(
                  Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
