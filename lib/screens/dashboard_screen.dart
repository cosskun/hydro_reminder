import 'package:confetti/confetti.dart';
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
  late ConfettiController _confettiController;
  bool _isShowingBadgeDialog = false;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 4));
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<WaterProvider>(context);
    final percentage = provider.todayPercentage;
    final status = WaterProvider.getHydrationStatus(
      percentage,
      mascotType: provider.mascotType,
      lang: provider.language,
      streakDays: provider.currentStreak,
      lastLogTime: provider.latestLogTime,
    );
    final statusColor = Color(int.parse('FF${status['color']!}', radix: 16));
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Check if daily goal was just reached and celebrate with Confetti & SnackBar
    if (provider.shouldShowGoalCelebration) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && provider.shouldShowGoalCelebration) {
          _confettiController.play();
          provider.clearGoalCelebration();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Row(
                children: [
                  Text('🎉', style: TextStyle(fontSize: 22)),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Harikasın! Bugünkü su hedefini başarıyla tamamladın! 🥳💧',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              backgroundColor: const Color(0xFF10B981),
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 4),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
          );
        }
      });
    }

    // Check if a badge was just unlocked and celebrate (guarded against duplicate dialog stacking)
    if (provider.newlyUnlockedBadge != null && !_isShowingBadgeDialog) {
      final badge = provider.newlyUnlockedBadge!;
      _isShowingBadgeDialog = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          provider.clearNewlyUnlockedBadge();
          showBadgeCelebrationDialog(
            context,
            badge,
            onDismiss: () {
              if (mounted) {
                setState(() {
                  _isShowingBadgeDialog = false;
                });
              } else {
                _isShowingBadgeDialog = false;
              }
            },
          );
        } else {
          _isShowingBadgeDialog = false;
        }
      });
    }

    return Stack(
      alignment: Alignment.topCenter,
      children: [
        LayoutBuilder(
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
                                  color: isDark ? const Color(0xFF94A3B8) : Colors.grey.shade700,
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
                                  color: isDark ? const Color(0xFFF1F5F9) : const Color(0xFF0F172A),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF1C2541) : theme.colorScheme.primary.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isDark ? const Color(0xFF3A506B) : theme.colorScheme.primary.withValues(alpha: 0.2),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.track_changes_rounded, color: theme.colorScheme.primary, size: 16),
                              const SizedBox(width: 5),
                              Text(
                                'Hedef: ${provider.dailyGoal} ml',
                                style: TextStyle(
                                  color: isDark ? const Color(0xFFF1F5F9) : const Color(0xFF1E293B),
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
                      // Streak Recovery Banner (if yesterday was missed and user has an active shield)
                      if (provider.canRecoverYesterday)
                        Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: isDark
                                  ? [const Color(0xFF1E293B), const Color(0xFF0F172A)]
                                  : [theme.colorScheme.primary.withValues(alpha: 0.08), Colors.white],
                            ),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: theme.colorScheme.primary.withValues(alpha: 0.7),
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: theme.colorScheme.primary.withValues(alpha: 0.15),
                                blurRadius: 10,
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              const Text('🛡️', style: TextStyle(fontSize: 24)),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Seri Kurtarma Kalkanı!',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                                      ),
                                    ),
                                    Text(
                                      'Dün hedefini kaçırdın. 1 kalkan kullanarak serini koru!',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: isDark ? const Color(0xFF94A3B8) : Colors.grey.shade700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              ElevatedButton(
                                onPressed: () async {
                                  await provider.useStreakShieldForYesterday();
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: const Text('🛡️ Harika! Seri kalkanı kullanıldı ve seriniz korundu!'),
                                        backgroundColor: theme.colorScheme.primary,
                                        behavior: SnackBarBehavior.floating,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                      ),
                                    );
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: theme.colorScheme.primary,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                                child: const Text('Kurtar', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                              ),
                            ],
                          ),
                        ),

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
                          color: isDark ? theme.colorScheme.primary : theme.colorScheme.primary,
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
                            color: isDark ? const Color(0xFFF1F5F9) : const Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            'Basılı tutarak kaldırabilirsiniz',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 10.5,
                              color: isDark ? const Color(0xFF64748B) : Colors.grey.shade500,
                            ),
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
    ),
    Align(
      alignment: Alignment.topCenter,
      child: ConfettiWidget(
        confettiController: _confettiController,
        blastDirectionality: BlastDirectionality.explosive,
        shouldLoop: false,
        emissionFrequency: 0.05,
        numberOfParticles: 40,
        gravity: 0.25,
        colors: const [
          Color(0xFF38BDF8),
          Color(0xFF10B981),
          Color(0xFFF59E0B),
          Color(0xFF8B5CF6),
          Colors.white,
        ],
      ),
    ),
  ],
);
  }


}
