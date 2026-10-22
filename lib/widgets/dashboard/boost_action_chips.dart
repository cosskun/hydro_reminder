import 'package:flutter/material.dart';
import '../../providers/water_provider.dart';

class BoostActionChips extends StatelessWidget {
  final WaterProvider provider;
  final bool isDark;

  const BoostActionChips({
    super.key,
    required this.provider,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEn = provider.language == 'en';
    final workoutLabel = isEn ? 'Workout (+500ml)' : 'Spor (+500ml)';
    final hotWeatherLabel = isEn ? 'Hot Weather (+300ml)' : 'Sıcak Hava (+300ml)';

    return Row(
      children: [
        // Workout Boost Chip (+500 ml)
        Expanded(
          child: InkWell(
            onTap: () => provider.toggleWorkoutBoost(),
            borderRadius: BorderRadius.circular(20),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
              decoration: BoxDecoration(
                color: provider.isWorkoutBoostActive
                    ? (isDark ? theme.colorScheme.primary.withOpacity(0.5) : theme.colorScheme.primary)
                    : (isDark ? const Color(0xFF1C2541) : Colors.white),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: provider.isWorkoutBoostActive
                      ? theme.colorScheme.primary
                      : (isDark ? const Color(0xFF3A506B) : theme.colorScheme.primary.withValues(alpha: 0.25)),
                  width: 1.2,
                ),
                boxShadow: provider.isWorkoutBoostActive
                    ? [
                        BoxShadow(
                          color: theme.colorScheme.primary.withOpacity(0.25),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        )
                      ]
                    : null,
              ),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('🏃‍♂️', style: TextStyle(fontSize: 14)),
                    const SizedBox(width: 5),
                    Text(
                      workoutLabel,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: provider.isWorkoutBoostActive
                            ? Colors.white
                            : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF0F172A)),
                      ),
                    ),
                    if (provider.isWorkoutBoostActive) ...[
                      const SizedBox(width: 4),
                      const Icon(Icons.check_circle_rounded, size: 14, color: Colors.white),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),

        // Hot Weather Boost Chip (+300 ml)
        Expanded(
          child: InkWell(
            onTap: () => provider.toggleHotWeatherBoost(),
            borderRadius: BorderRadius.circular(20),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
              decoration: BoxDecoration(
                color: provider.isHotWeatherBoostActive
                    ? (isDark ? const Color(0xFFC2410C) : Colors.orange.shade600)
                    : (isDark ? const Color(0xFF1C2541) : Colors.white),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: provider.isHotWeatherBoostActive
                      ? Colors.orangeAccent
                      : (isDark ? const Color(0xFF3A506B) : Colors.orange.shade100),
                  width: 1.2,
                ),
                boxShadow: provider.isHotWeatherBoostActive
                    ? [
                        BoxShadow(
                          color: Colors.orange.withOpacity(0.25),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        )
                      ]
                    : null,
              ),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('☀️', style: TextStyle(fontSize: 14)),
                    const SizedBox(width: 5),
                    Text(
                      hotWeatherLabel,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: provider.isHotWeatherBoostActive
                            ? Colors.white
                            : (isDark ? const Color(0xFF94A3B8) : Colors.orange.shade900),
                      ),
                    ),
                    if (provider.isHotWeatherBoostActive) ...[
                      const SizedBox(width: 4),
                      const Icon(Icons.check_circle_rounded, size: 14, color: Colors.white),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
