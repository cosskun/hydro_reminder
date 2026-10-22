import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/badge_item.dart';
import '../../providers/water_provider.dart';

void showBadgeCelebrationDialog(BuildContext context, BadgeItem badge, {VoidCallback? onDismiss}) {
  final isDark = Theme.of(context).brightness == Brightness.dark;

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) {
      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: isDark ? const Color(0xFF1C2541) : Colors.white,
        title: Center(
          child: Column(
            children: [
              const Text('🎉 🏆 🎉', style: TextStyle(fontSize: 32)),
              const SizedBox(height: 8),
              Text(
                'Yeni Rozet Kazanıldı!',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDark ? const Color(0xFF0B132B) : Colors.amber.shade50,
                border: Border.all(color: Colors.amber.shade400, width: 2),
              ),
              child: Text(badge.icon, style: const TextStyle(fontSize: 48)),
            ),
            const SizedBox(height: 14),
            Text(
              badge.title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: isDark ? const Color(0xFFF1F5F9) : const Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              badge.description,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: isDark ? const Color(0xFF94A3B8) : Colors.grey.shade600,
                height: 1.3,
              ),
            ),
          ],
        ),
        actionsPadding: const EdgeInsets.only(bottom: 20, left: 20, right: 20),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Provider.of<WaterProvider>(context, listen: false).clearNewlyUnlockedBadge();
                Navigator.pop(dialogContext);
                if (onDismiss != null) onDismiss();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text(
                'Harika! 🥳',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      );
    },
  );
}
