import 'package:flutter/material.dart';
import '../../models/mascot_model.dart';

/// Shows an interactive preview of all 10 daily states & dialogues for a chosen mascot
void showMascotStatePreviewDialog(BuildContext context, MascotCharacter mascot, {String lang = 'tr'}) {
  final isEn = lang == 'en';
  final theme = Theme.of(context);
  final isDark = theme.brightness == Brightness.dark;

  // Generate the 10 states
  final states = MascotState.values.map((state) {
    // Mock conditions for dialogue resolution
    double pct = 0.5;
    int streak = 1;
    DateTime? now;

    switch (state) {
      case MascotState.morning:
        now = DateTime(2026, 1, 1, 8, 0);
        pct = 0.15;
        break;
      case MascotState.workFocus:
        now = DateTime(2026, 1, 1, 10, 30);
        pct = 0.35;
        break;
      case MascotState.lunch:
        now = DateTime(2026, 1, 1, 12, 30);
        pct = 0.50;
        break;
      case MascotState.afternoonSlump:
        now = DateTime(2026, 1, 1, 15, 0);
        pct = 0.60;
        break;
      case MascotState.workout:
        now = DateTime(2026, 1, 1, 17, 30);
        pct = 0.75;
        break;
      case MascotState.evening:
        now = DateTime(2026, 1, 1, 20, 0);
        pct = 0.90;
        break;
      case MascotState.bedtime:
        now = DateTime(2026, 1, 1, 22, 30);
        pct = 0.95;
        break;
      case MascotState.goalReached:
        pct = 1.0;
        break;
      case MascotState.thirsty:
        pct = 0.0;
        break;
      case MascotState.streakFire:
        pct = 0.8;
        streak = 5;
        break;
    }

    return MascotResolver.resolveDialogue(
      mascotType: mascot.id,
      percentage: pct,
      streakDays: streak,
      lang: lang,
      now: now,
    );
  }).toList();

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: isDark ? const Color(0xFF0F172A) : Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (ctx) {
      return DraggableScrollableSheet(
        initialChildSize: 0.85,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Modal Drag Handle
                Center(
                  child: Container(
                    width: 44,
                    height: 5,
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF334155) : Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                // Header with Mascot Avatar & Title
                Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF0284C7), Color(0xFF38BDF8)],
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.asset(
                          mascot.defaultImageAsset,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Center(
                            child: Text(mascot.emoji, style: const TextStyle(fontSize: 28)),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isEn ? mascot.nameEn : mascot.nameTr,
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : Colors.blue.shade900,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            isEn
                                ? '10 Daily Expressions & Smart Reminders'
                                : '10 Farklı Gün İçi Durum & Akıllı Uyarılar',
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? const Color(0xFF94A3B8) : Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const Divider(height: 20, thickness: 0.5),

                // List of 10 States
                Expanded(
                  child: ListView.separated(
                    controller: scrollController,
                    physics: const BouncingScrollPhysics(),
                    itemCount: states.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final item = states[index];
                      final stateColor = Color(int.parse('FF${item.hexColor}', radix: 16));

                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF1E293B) : Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: stateColor.withOpacity(0.35),
                            width: 1.2,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: stateColor.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.asset(
                                  item.imageAsset,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Center(
                                    child: Text(item.emoji, style: const TextStyle(fontSize: 24)),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: stateColor.withOpacity(0.2),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          item.title,
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                            color: stateColor,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    item.message,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: isDark ? const Color(0xFFF1F5F9) : const Color(0xFF1E293B),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      );
    },
  );
}
