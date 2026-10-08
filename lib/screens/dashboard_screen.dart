import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/water_provider.dart';
import '../widgets/liquid_progress_indicator.dart';
import '../widgets/dialogs/badge_celebration_dialog.dart';
import '../widgets/dashboard/boost_action_chips.dart';
import '../widgets/dashboard/hydration_status_card.dart';
import '../widgets/dashboard/hydration_quick_add_button.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // Helper to get status emoji & message based on progress
  Map<String, String> _getHydrationStatus(double percentage) {
    if (percentage < 0.25) {
      return {
        'emoji': '🥵',
        'message': 'Çok susuz kaldın! Hemen bir bardak su al.',
        'color': 'E11D48', // rose
      };
    } else if (percentage < 0.50) {
      return {
        'emoji': '🥛',
        'message': 'Güzel başlangıç! Yavaş yavaş hedefe ilerliyorsun.',
        'color': 'F59E0B', // amber
      };
    } else if (percentage < 0.75) {
      return {
        'emoji': '💧',
        'message': 'Harika gidiyorsun! Vücudun sana teşekkür ediyor.',
        'color': '10B981', // emerald
      };
    } else if (percentage < 1.0) {
      return {
        'emoji': '😎',
        'message': 'Neredeyse tamamladın! Enerjin yerinde.',
        'color': '06B6D4', // cyan
      };
    } else {
      return {
        'emoji': '🏆',
        'message': 'Tebrikler! Günlük su hedefini tamamladın!',
        'color': '8B5CF6', // violet
      };
    }
  }



  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<WaterProvider>(context);
    final percentage = provider.todayPercentage;
    final status = _getHydrationStatus(percentage);
    final statusColor = Color(int.parse('FF${status['color']!}', radix: 16));
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Check if a badge was just unlocked and celebrate
    if (provider.newlyUnlockedBadge != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && provider.newlyUnlockedBadge != null) {
          showBadgeCelebrationDialog(context, provider.newlyUnlockedBadge!, onDismiss: () {});
        }
      });
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        // Dynamically compute the bubble size based on viewport height
        final availableHeight = constraints.maxHeight;
        final double bubbleSize = (availableHeight * 0.28).clamp(175.0, 225.0);

        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: availableHeight > 40 ? availableHeight - 20 : availableHeight,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // 1. Top Section: Greeting Header & Boost Action Chips
                Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Merhaba 👋',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: isDark ? const Color(0xFF94A3B8) : Colors.blue.shade900.withValues(alpha: 0.65),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Bugün nasılsın?',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 19,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? const Color(0xFFF1F5F9) : Colors.blue.shade900,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF1C2541) : Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isDark ? const Color(0xFF3A506B) : Colors.blue.shade100,
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.track_changes_rounded, color: Color(0xFF38BDF8), size: 16),
                              const SizedBox(width: 5),
                              Text(
                                'Hedef: ${provider.dailyGoal} ml',
                                style: TextStyle(
                                  color: isDark ? const Color(0xFFF1F5F9) : Colors.blue.shade900,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Dynamic Target Boosts (Workout / Hot Weather) Quick Action Chips
                    BoostActionChips(provider: provider, isDark: isDark),
                  ],
                ),

                // 2. Middle Section: Dynamic Liquid Bubble, Total Intake, and Status Card
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10.0),
                  child: Column(
                    children: [
                      // Waving fluid progress bubble (enlarged & proportional)
                      LiquidProgressIndicator(progress: percentage, size: bubbleSize),

                      const SizedBox(height: 12),
                      // Water stats display text
                      Text(
                        '${provider.todayTotal} / ${provider.dailyGoal} ml',
                        style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.5,
                          color: isDark ? const Color(0xFF38BDF8) : Colors.blue.shade900,
                        ),
                      ),
                      const SizedBox(height: 10),

                      HydrationStatusCard(status: status, statusColor: statusColor, isDark: isDark),
                    ],
                  ),
                ),

                // 3. Bottom Section: Enlarged Quick Add Glass / Bottles & Custom Button
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Hızlı Ekle 💧',
                          style: TextStyle(
                            fontSize: 14.5,
                            fontWeight: FontWeight.bold,
                            color: isDark ? const Color(0xFFF1F5F9) : Colors.blue.shade900,
                          ),
                        ),
                        Text(
                          'Basılı tutarak kaldırabilirsiniz',
                          style: TextStyle(
                            fontSize: 10.5,
                            color: isDark ? const Color(0xFF64748B) : Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    provider.quickPresets.length <= 4
                        ? Row(
                            children: [
                              ...provider.quickPresets.map((amount) {
                                final meta = WaterProvider.getPresetMeta(amount);
                                return Expanded(
                                  child: HydrationQuickAddButton(
                                    context: context,
                                    emoji: meta['emoji']!,
                                    label: meta['name']!,
                                    amount: amount,
                                    canDelete: provider.quickPresets.length > 1,
                                    isExpanded: true,
                                    isDark: isDark,
                                  ),
                                );
                              }),
                              Expanded(
                                child: HydrationCustomAddButton(context: context, isExpanded: true, isDark: isDark),
                              ),
                            ],
                          )
                        : SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            clipBehavior: Clip.none,
                            child: Row(
                              children: [
                                ...provider.quickPresets.map((amount) {
                                  final meta = WaterProvider.getPresetMeta(amount);
                                  return HydrationQuickAddButton(
                                    context: context,
                                    emoji: meta['emoji']!,
                                    label: meta['name']!,
                                    amount: amount,
                                    canDelete: provider.quickPresets.length > 1,
                                    isExpanded: false,
                                    isDark: isDark,
                                  );
                                }),
                                HydrationCustomAddButton(context: context, isExpanded: false, isDark: isDark),
                              ],
                            ),
                          ),
                    const SizedBox(height: 6),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }


}
