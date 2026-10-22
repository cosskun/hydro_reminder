import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/beverage_type.dart';
import '../../providers/water_provider.dart';

void showCustomAddBeverageDialog(BuildContext context) {
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

          final theme = Theme.of(context);
          final primary = theme.colorScheme.primary;

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
                        selectedColor: primary,
                        backgroundColor: isDark
                            ? const Color(0xFF0B132B)
                            : primary.withValues(alpha: 0.08),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                          side: BorderSide(
                            color: isSelected
                                ? primary
                                : (isDark ? const Color(0xFF3A506B) : primary.withValues(alpha: 0.2)),
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
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: selectedBeverage.hydrationFactor < 1.0
                          ? (isDark ? const Color(0xFF33200B) : Colors.amber.shade50)
                          : (isDark ? const Color(0xFF0E3048) : primary.withValues(alpha: 0.08)),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: selectedBeverage.hydrationFactor < 1.0
                            ? Colors.amber.shade300
                            : (isDark ? primary : primary.withValues(alpha: 0.25)),
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
                                  color: isDark ? const Color(0xFFF1F5F9) : const Color(0xFF0F172A),
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
                  TextField(
                    controller: textController,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      color: primary,
                    ),
                    decoration: InputDecoration(
                      suffixText: 'ml',
                      suffixStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      filled: true,
                      fillColor: isDark
                          ? const Color(0xFF0B132B)
                          : primary.withValues(alpha: 0.05),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(
                          color: isDark ? const Color(0xFF3A506B) : primary.withValues(alpha: 0.2),
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
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    alignment: WrapAlignment.center,
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
                              : (isDark ? const Color(0xFFF1F5F9) : const Color(0xFF1E293B)),
                        ),
                        backgroundColor: currentAmount == amount
                            ? primary
                            : (isDark
                                ? const Color(0xFF0B132B)
                                : primary.withValues(alpha: 0.08)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: BorderSide(
                            color: currentAmount == amount
                                ? primary
                                : (isDark ? const Color(0xFF3A506B) : primary.withValues(alpha: 0.2)),
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

                        provider.addWater(currentAmount, beverageId: selectedBeverage.id);

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
                                    '+$effectiveMl ml hidrasyon kaydedildi! Harika ilerliyorsun! ✨',
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                            backgroundColor: primary,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primary,
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
