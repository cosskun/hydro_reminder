import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/water_provider.dart';
import '../dialogs/custom_add_beverage_dialog.dart';
import '../dialogs/delete_preset_dialog.dart';

class HydrationQuickAddButton extends StatelessWidget {
  final BuildContext context;
  final String emoji;
  final String label;
  final int amount;
  final bool canDelete;
  final bool isExpanded;
  final bool isDark;
  final bool isCompact;

  const HydrationQuickAddButton({
    super.key,
    required this.context,
    required this.emoji,
    required this.label,
    required this.amount,
    required this.canDelete,
    this.isExpanded = false,
    this.isDark = false,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext _) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isExpanded ? 3.0 : 4.0),
      child: InkWell(
        onTap: () {
          final provider = Provider.of<WaterProvider>(context, listen: false);
          provider.addWater(amount);

          final newTotal = provider.todayTotal;
          final goal = provider.dailyGoal;
          final pct = (goal > 0) ? (newTotal / goal) : 0.0;
          final isEn = provider.language == 'en';

          String motivationalMsg;
          if (pct >= 1.0) {
            motivationalMsg = isEn ? '🏆 Awesome! You reached your daily goal!' : '🏆 Harikasın! Günlük hedefine ulaştın!';
          } else if (pct >= 0.75) {
            motivationalMsg = isEn ? '🚀 Great progress, almost at your goal!' : '🚀 Harika ilerliyorsun, hedefe çok az kaldı!';
          } else if (pct >= 0.50) {
            motivationalMsg = isEn ? '👏 Well done, you\'re halfway there!' : '👏 Harika gidiyorsun, yarıyı geçtin!';
          } else {
            motivationalMsg = isEn ? '✨ Great step! Keep it up!' : '✨ Harika bir adım! İyi ilerliyorsun!';
          }

          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Text('$emoji ', style: const TextStyle(fontSize: 18)),
                  Expanded(
                    child: Text(
                      '+$amount ml • $motivationalMsg',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5),
                    ),
                  ),
                ],
              ),
              backgroundColor: Theme.of(context).colorScheme.primary,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              duration: const Duration(seconds: 2),
            ),
          );
        },
        onLongPress: canDelete ? () => showDeletePresetDialog(context, amount) : null,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: isExpanded ? null : (isCompact ? 66 : 74),
          padding: EdgeInsets.symmetric(
            vertical: isCompact ? 7 : 12,
            horizontal: 2,
          ),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1C2541) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? const Color(0xFF3A506B) : Theme.of(context).colorScheme.primary.withValues(alpha: 0.18),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: isDark ? Colors.black26 : Theme.of(context).colorScheme.primary.withValues(alpha: 0.03),
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
                style: TextStyle(fontSize: isCompact ? 19 : 22),
              ),
              SizedBox(height: isCompact ? 2 : 4),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  '$amount ml',
                  maxLines: 1,
                  style: TextStyle(
                    fontSize: isCompact ? 11 : 12,
                    fontWeight: FontWeight.bold,
                    color: isDark ? const Color(0xFFF1F5F9) : const Color(0xFF1E293B),
                  ),
                ),
              ),
              SizedBox(height: isCompact ? 0 : 1),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  label,
                  maxLines: 1,
                  style: TextStyle(
                    fontSize: isCompact ? 9 : 10,
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

class HydrationCustomAddButton extends StatelessWidget {
  final BuildContext context;
  final bool isExpanded;
  final bool isDark;
  final bool isCompact;

  const HydrationCustomAddButton({
    super.key,
    required this.context,
    this.isExpanded = false,
    this.isDark = false,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext _) {
    final isEn = Provider.of<WaterProvider>(context).language == 'en';
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isExpanded ? 3.0 : 4.0),
      child: InkWell(
        onTap: () => showCustomAddBeverageDialog(context),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: isExpanded ? null : (isCompact ? 66 : 74),
          padding: EdgeInsets.symmetric(
            vertical: isCompact ? 7 : 12,
            horizontal: 2,
          ),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1C2541) : Theme.of(context).colorScheme.primary.withOpacity(0.08),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? Theme.of(context).colorScheme.primary.withOpacity(0.6) : Theme.of(context).colorScheme.primary.withOpacity(0.35),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: isDark ? Colors.black26 : Theme.of(context).colorScheme.primary.withValues(alpha: 0.03),
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
                size: isCompact ? 21 : 26,
                color: Theme.of(context).colorScheme.primary,
              ),
              SizedBox(height: isCompact ? 2 : 4),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  isEn ? 'Custom' : 'Özel',
                  maxLines: 1,
                  style: TextStyle(
                    fontSize: isCompact ? 11 : 12,
                    fontWeight: FontWeight.bold,
                    color: isDark ? const Color(0xFFF1F5F9) : const Color(0xFF1E293B),
                  ),
                ),
              ),
              SizedBox(height: isCompact ? 0 : 1),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  isEn ? '+ Add' : '+ Ekle',
                  maxLines: 1,
                  style: TextStyle(
                    fontSize: isCompact ? 9 : 10,
                    color: Theme.of(context).colorScheme.primary,
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
}
