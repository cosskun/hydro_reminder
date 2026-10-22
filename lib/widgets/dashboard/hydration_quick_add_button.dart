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

  const HydrationQuickAddButton({
    super.key,
    required this.context,
    required this.emoji,
    required this.label,
    required this.amount,
    required this.canDelete,
    this.isExpanded = false,
    this.isDark = false,
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

          String motivationalMsg;
          if (pct >= 1.0) {
            motivationalMsg = '🏆 Harikasın! Günlük hedefine ulaştın!';
          } else if (pct >= 0.75) {
            motivationalMsg = '🚀 Harika ilerliyorsun, hedefe çok az kaldı!';
          } else if (pct >= 0.50) {
            motivationalMsg = '👏 Harika gidiyorsun, yarıyı geçtin!';
          } else {
            motivationalMsg = '✨ Harika bir adım! İyi ilerliyorsun!';
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
          width: isExpanded ? null : 74,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 2),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1C2541) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? const Color(0xFF3A506B) : Colors.blue.shade100.withOpacity(0.6),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: isDark ? Colors.black26 : Colors.blue.shade900.withOpacity(0.03),
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

class HydrationCustomAddButton extends StatelessWidget {
  final BuildContext context;
  final bool isExpanded;
  final bool isDark;

  const HydrationCustomAddButton({
    super.key,
    required this.context,
    this.isExpanded = false,
    this.isDark = false,
  });

  @override
  Widget build(BuildContext _) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isExpanded ? 3.0 : 4.0),
      child: InkWell(
        onTap: () => showCustomAddBeverageDialog(context),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: isExpanded ? null : 74,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 2),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1C2541) : Theme.of(context).colorScheme.primary.withOpacity(0.08),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? Theme.of(context).colorScheme.primary.withOpacity(0.6) : Theme.of(context).colorScheme.primary.withOpacity(0.35),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: isDark ? Colors.black26 : Colors.blue.shade900.withOpacity(0.02),
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
                color: Theme.of(context).colorScheme.primary,
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
