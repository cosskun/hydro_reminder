import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/badge_item.dart';
import '../models/beverage_type.dart';
import '../providers/water_provider.dart';
import '../widgets/liquid_progress_indicator.dart';

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

  void _showBadgeCelebrationDialog(BuildContext context, BadgeItem badge) {
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
                    color: isDark ? const Color(0xFF38BDF8) : const Color(0xFF0288D1),
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
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0288D1),
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

  void _showCustomAddDialog(BuildContext context) {
    int currentAmount = 200;
    final textController = TextEditingController(text: '200');
    bool saveAsQuickButton = false;
    BeverageType selectedBeverage = BeverageType.all.first;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            final effectiveMl = (currentAmount * selectedBeverage.hydrationFactor).round();

            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              backgroundColor: isDark ? const Color(0xFF1C2541) : Colors.white,
              title: Center(
                child: Text(
                  'İçecek & Miktar Ekle 💧',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: isDark ? const Color(0xFFF1F5F9) : const Color(0xFF0F172A),
                  ),
                ),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Beverage Selector Section
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'İçecek Türü:',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isDark ? const Color(0xFF94A3B8) : Colors.grey.shade700,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: BeverageType.all.map((bev) {
                        final isSelected = selectedBeverage.id == bev.id;
                        return ChoiceChip(
                          avatar: Text(bev.icon, style: const TextStyle(fontSize: 14)),
                          label: Text(
                            bev.name,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                              color: isSelected
                                  ? (isDark ? const Color(0xFF0B132B) : Colors.white)
                                  : (isDark ? const Color(0xFFF1F5F9) : const Color(0xFF0F172A)),
                            ),
                          ),
                          selected: isSelected,
                          selectedColor: const Color(0xFF0288D1),
                          backgroundColor: isDark
                              ? const Color(0xFF0B132B)
                              : Colors.blue.shade50.withValues(alpha: 0.5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                            side: BorderSide(
                              color: isSelected
                                  ? const Color(0xFF0288D1)
                                  : (isDark ? const Color(0xFF3A506B) : Colors.blue.shade100),
                            ),
                          ),
                          onSelected: (selected) {
                            if (selected) {
                              setState(() {
                                selectedBeverage = bev;
                              });
                            }
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 12),

                    // Net Effective Hydration Info Banner
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: selectedBeverage.hydrationFactor < 1.0
                            ? (isDark ? const Color(0xFF33200B) : Colors.amber.shade50)
                            : (isDark ? const Color(0xFF0E3048) : Colors.blue.shade50),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: selectedBeverage.hydrationFactor < 1.0
                              ? Colors.amber.shade300
                              : (isDark ? const Color(0xFF0288D1) : Colors.blue.shade200),
                        ),
                      ),
                      child: Row(
                        children: [
                          Text(
                            selectedBeverage.hydrationFactor < 1.0 ? '⚡' : '💧',
                            style: const TextStyle(fontSize: 16),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Net Hidrasyon: $effectiveMl ml',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: isDark ? const Color(0xFFF1F5F9) : Colors.blue.shade900,
                                  ),
                                ),
                                Text(
                                  'Emilim katsayısı: %${(selectedBeverage.hydrationFactor * 100).toInt()}',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: isDark ? const Color(0xFF94A3B8) : Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Amount Text Input with ml
                    TextField(
                      controller: textController,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        color: isDark ? const Color(0xFF38BDF8) : Colors.blue.shade800,
                      ),
                      decoration: InputDecoration(
                        suffixText: 'ml',
                        suffixStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        filled: true,
                        fillColor: isDark
                            ? const Color(0xFF0B132B)
                            : Colors.blue.shade50.withValues(alpha: 0.2),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(
                            color: isDark ? const Color(0xFF3A506B) : Colors.blue.shade100,
                          ),
                        ),
                      ),
                      onChanged: (val) {
                        final parsed = int.tryParse(val);
                        if (parsed != null && parsed > 0) {
                          setState(() {
                            currentAmount = parsed;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 10),

                    // Quick Increment/Decrement Buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        OutlinedButton(
                          onPressed: () {
                            if (currentAmount > 50) {
                              setState(() {
                                currentAmount -= 50;
                                textController.text = currentAmount.toString();
                              });
                            }
                          },
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          child: const Text('-50 ml', style: TextStyle(fontSize: 12)),
                        ),
                        const SizedBox(width: 6),
                        OutlinedButton(
                          onPressed: () {
                            setState(() {
                              currentAmount += 50;
                              textController.text = currentAmount.toString();
                            });
                          },
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          child: const Text('+50 ml', style: TextStyle(fontSize: 12)),
                        ),
                        const SizedBox(width: 6),
                        OutlinedButton(
                          onPressed: () {
                            setState(() {
                              currentAmount += 100;
                              textController.text = currentAmount.toString();
                            });
                          },
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          child: const Text('+100 ml', style: TextStyle(fontSize: 12)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Preset Quick Chips
                    Wrap(
                      spacing: 5,
                      runSpacing: 5,
                      alignment: WrapAlignment.center,
                      children: [50, 100, 150, 200, 250, 330, 500].map((amount) {
                        return ActionChip(
                          label: Text('$amount ml'),
                          labelStyle: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w600,
                            color: currentAmount == amount
                                ? (isDark ? const Color(0xFF0B132B) : Colors.white)
                                : (isDark ? const Color(0xFFF1F5F9) : Colors.blue.shade900),
                          ),
                          backgroundColor: currentAmount == amount
                              ? const Color(0xFF0288D1)
                              : (isDark
                                  ? const Color(0xFF0B132B)
                                  : Colors.blue.shade50.withValues(alpha: 0.4)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                            side: BorderSide(
                              color: currentAmount == amount
                                  ? const Color(0xFF0288D1)
                                  : (isDark ? const Color(0xFF3A506B) : Colors.blue.shade100),
                            ),
                          ),
                          onPressed: () {
                            setState(() {
                              currentAmount = amount;
                              textController.text = amount.toString();
                            });
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 10),

                    // Checkbox to save as quick add button on home screen
                    CheckboxListTile(
                      value: saveAsQuickButton,
                      onChanged: (val) {
                        setState(() {
                          saveAsQuickButton = val ?? false;
                        });
                      },
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      controlAffinity: ListTileControlAffinity.leading,
                      title: Text(
                        'Anasayfaya hızlı ekle butonu olarak ekle',
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w500,
                          color: isDark ? const Color(0xFFF1F5F9) : const Color(0xFF0F172A),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actionsPadding: const EdgeInsets.only(bottom: 16, right: 16, left: 16),
              actions: [
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(dialogContext),
                        style: TextButton.styleFrom(
                          foregroundColor: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                        ),
                        child: const Text('İptal'),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: () {
                          if (currentAmount <= 0) return;
                          final provider = Provider.of<WaterProvider>(context, listen: false);

                          // Add water/beverage intake
                          provider.addWater(currentAmount, beverageId: selectedBeverage.id);

                          // Optionally add to home screen quick presets
                          if (saveAsQuickButton) {
                            provider.addQuickPreset(currentAmount);
                          }

                          Navigator.pop(dialogContext);

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Row(
                                children: [
                                  Text('${selectedBeverage.icon} ', style: const TextStyle(fontSize: 18)),
                                  Expanded(
                                    child: Text(
                                      '$currentAmount ml ${selectedBeverage.name} kaydedildi (+$effectiveMl ml net hidrasyon)${saveAsQuickButton ? ' ve anasayfaya eklendi!' : '!'}',
                                      style: const TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ],
                              ),
                              backgroundColor: const Color(0xFF0288D1),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0288D1),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text('${selectedBeverage.icon} Ekle ($currentAmount ml)'),
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showDeletePresetDialog(BuildContext context, int amount) {
    final meta = WaterProvider.getPresetMeta(amount);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text('${meta['emoji']} Butonu Kaldır?'),
          content: Text('$amount ml (${meta['name']}) hızlı su ekleme butonunu anasayfadan kaldırmak istiyor musunuz?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Vazgeç'),
            ),
            ElevatedButton(
              onPressed: () {
                Provider.of<WaterProvider>(context, listen: false).removeQuickPreset(amount);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('$amount ml butonu kaldırıldı.'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade600,
                foregroundColor: Colors.white,
              ),
              child: const Text('Kaldır'),
            ),
          ],
        );
      },
    );
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
          _showBadgeCelebrationDialog(context, provider.newlyUnlockedBadge!);
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
                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 8,
                      runSpacing: 6,
                      children: [
                        // Workout Boost Chip (+500 ml)
                        InkWell(
                          onTap: () => provider.toggleWorkoutBoost(),
                          borderRadius: BorderRadius.circular(20),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: provider.isWorkoutBoostActive
                                  ? (isDark ? const Color(0xFF0369A1) : Colors.blue.shade600)
                                  : (isDark ? const Color(0xFF1C2541) : Colors.white),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: provider.isWorkoutBoostActive
                                    ? const Color(0xFF38BDF8)
                                    : (isDark ? const Color(0xFF3A506B) : Colors.blue.shade100),
                                width: 1.2,
                              ),
                              boxShadow: provider.isWorkoutBoostActive
                                  ? [
                                      BoxShadow(
                                        color: Colors.blue.withValues(alpha: 0.25),
                                        blurRadius: 6,
                                        offset: const Offset(0, 2),
                                      )
                                    ]
                                  : null,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text('🏃‍♂️', style: TextStyle(fontSize: 14)),
                                const SizedBox(width: 5),
                                Text(
                                  'Spor (+500ml)',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: provider.isWorkoutBoostActive
                                        ? Colors.white
                                        : (isDark ? const Color(0xFF94A3B8) : Colors.blue.shade900),
                                  ),
                                ),
                                if (provider.isWorkoutBoostActive) ...[
                                  const SizedBox(width: 4),
                                  const Icon(Icons.check_circle_rounded, size: 13, color: Colors.white),
                                ],
                              ],
                            ),
                          ),
                        ),

                        // Hot Weather Boost Chip (+300 ml)
                        InkWell(
                          onTap: () => provider.toggleHotWeatherBoost(),
                          borderRadius: BorderRadius.circular(20),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
                                        color: Colors.orange.withValues(alpha: 0.25),
                                        blurRadius: 6,
                                        offset: const Offset(0, 2),
                                      )
                                    ]
                                  : null,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text('☀️', style: TextStyle(fontSize: 14)),
                                const SizedBox(width: 5),
                                Text(
                                  'Sıcak Hava (+300ml)',
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
                                  const Icon(Icons.check_circle_rounded, size: 13, color: Colors.white),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
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

                      // Status Notification Card
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF1C2541) : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: statusColor.withValues(alpha: 0.35),
                            width: 1.2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: isDark ? Colors.black26 : Colors.blue.shade900.withValues(alpha: 0.03),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Text(
                              status['emoji']!,
                              style: const TextStyle(fontSize: 26),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Durumunuz',
                                    style: TextStyle(
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.bold,
                                      color: statusColor,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    status['message']!,
                                    style: TextStyle(
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w600,
                                      color: isDark ? const Color(0xFFF1F5F9) : Colors.blue.shade900,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
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

                    // Dynamic Quick Add Items (Adaptive Row up to 4 items or Horizontal Scroll)
                    provider.quickPresets.length <= 4
                        ? Row(
                            children: [
                              ...provider.quickPresets.map((amount) {
                                final meta = WaterProvider.getPresetMeta(amount);
                                return Expanded(
                                  child: _buildQuickAddButton(
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
                                child: _buildCustomAddButton(context, isExpanded: true, isDark: isDark),
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
                                  return _buildQuickAddButton(
                                    context: context,
                                    emoji: meta['emoji']!,
                                    label: meta['name']!,
                                    amount: amount,
                                    canDelete: provider.quickPresets.length > 1,
                                    isExpanded: false,
                                    isDark: isDark,
                                  );
                                }),
                                _buildCustomAddButton(context, isExpanded: false, isDark: isDark),
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

  Widget _buildCustomAddButton(BuildContext context, {bool isExpanded = false, bool isDark = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isExpanded ? 3.0 : 4.0),
      child: InkWell(
        onTap: () => _showCustomAddDialog(context),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: isExpanded ? null : 74,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 2),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1C2541) : const Color(0xFFEFF6FF),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? const Color(0xFF38BDF8).withValues(alpha: 0.6) : Colors.blue.shade200,
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: isDark ? Colors.black26 : Colors.blue.shade900.withValues(alpha: 0.02),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.add_circle_outline_rounded,
                size: 26,
                color: isDark ? const Color(0xFF38BDF8) : Colors.blue.shade700,
              ),
              const SizedBox(height: 4),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  'Özel',
                  maxLines: 1,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: isDark ? const Color(0xFFF1F5F9) : Colors.blue.shade900,
                  ),
                ),
              ),
              const SizedBox(height: 1),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  '+ Ekle',
                  maxLines: 1,
                  style: TextStyle(
                    fontSize: 10,
                    color: isDark ? const Color(0xFF38BDF8) : Colors.blue.shade600,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickAddButton({
    required BuildContext context,
    required String emoji,
    required String label,
    required int amount,
    required bool canDelete,
    bool isExpanded = false,
    bool isDark = false,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isExpanded ? 3.0 : 4.0),
      child: InkWell(
        onTap: () {
          Provider.of<WaterProvider>(context, listen: false).addWater(amount);
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Text('$emoji ', style: const TextStyle(fontSize: 18)),
                  Expanded(
                    child: Text(
                      '+$amount ml su kaydedildi!',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              backgroundColor: const Color(0xFF0288D1),
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 2),
            ),
          );
        },
        onLongPress: canDelete ? () => _showDeletePresetDialog(context, amount) : null,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: isExpanded ? null : 74,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 2),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1C2541) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? const Color(0xFF3A506B) : Colors.blue.shade100.withValues(alpha: 0.6),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: isDark ? Colors.black26 : Colors.blue.shade900.withValues(alpha: 0.03),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                emoji,
                style: const TextStyle(fontSize: 22),
              ),
              const SizedBox(height: 4),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  '$amount ml',
                  maxLines: 1,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: isDark ? const Color(0xFFF1F5F9) : Colors.blue.shade900,
                  ),
                ),
              ),
              const SizedBox(height: 1),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  label,
                  maxLines: 1,
                  style: TextStyle(
                    fontSize: 10,
                    color: isDark ? const Color(0xFF64748B) : Colors.grey.shade500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
