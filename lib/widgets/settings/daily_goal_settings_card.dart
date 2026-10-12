import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/water_provider.dart';
import 'settings_card_wrapper.dart';

class DailyGoalSettingsCard extends StatefulWidget {
  final TextEditingController dailyGoalController;
  final VoidCallback onAutoCalculate;
  final VoidCallback onSave;

  const DailyGoalSettingsCard({
    super.key,
    required this.dailyGoalController,
    required this.onAutoCalculate,
    required this.onSave,
  });

  @override
  State<DailyGoalSettingsCard> createState() => _DailyGoalSettingsCardState();
}

class _DailyGoalSettingsCardState extends State<DailyGoalSettingsCard> {
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<WaterProvider>(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SettingsCardWrapper(
      title: 'Günlük Su Hedefi 🎯',
      titleTrailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF0B132B) : Colors.blue.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark ? const Color(0xFF3A506B) : Colors.blue.shade100,
          ),
        ),
        child: Text(
          '${provider.dailyGoal} ml',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: isDark ? const Color(0xFF38BDF8) : Colors.blue.shade800,
          ),
        ),
      ),
      children: [
        Text(
          'İstediğiniz günlük hedef miktarını serbestçe belirleyin veya otomatik hesaplama seçeneğini kullanın.',
          style: TextStyle(
            fontSize: 12,
            color: isDark ? const Color(0xFF94A3B8) : Colors.grey,
            height: 1.3,
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: widget.dailyGoalController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: 'Günlük Hedef Miktarı',
            suffixText: 'ml',
            filled: true,
            fillColor: isDark ? const Color(0xFF0B132B) : Colors.blue.shade50.withValues(alpha: 0.2),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: isDark ? const Color(0xFF3A506B) : Colors.blue.shade100,
              ),
            ),
            prefixIcon: const Icon(Icons.water_drop, color: Color(0xFF0288D1)),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [2000, 2500, 3000].map((amount) {
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: ActionChip(
                  label: Center(
                    child: Text(
                      '$amount ml',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: isDark ? const Color(0xFFF1F5F9) : Colors.blue.shade900,
                      ),
                    ),
                  ),
                  backgroundColor: isDark
                      ? const Color(0xFF0B132B)
                      : Colors.blue.shade50.withValues(alpha: 0.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: BorderSide(
                      color: isDark ? const Color(0xFF3A506B) : Colors.blue.shade100,
                    ),
                  ),
                  onPressed: () {
                    setState(() {
                      widget.dailyGoalController.text = amount.toString();
                    });
                  },
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: widget.onAutoCalculate,
          icon: const Icon(Icons.auto_awesome, size: 16),
          label: const FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              'Hedefi Otomatik Hesapla',
              maxLines: 1,
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ),
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFF0288D1),
            side: BorderSide(
              color: isDark ? const Color(0xFF38BDF8) : Colors.blue.shade200,
            ),
            minimumSize: const Size(double.infinity, 40),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        const SizedBox(height: 12),
        ElevatedButton(
          onPressed: widget.onSave,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF0288D1),
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 44),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 0,
          ),
          child: const Text(
            'Günlük Hedefi Kaydet',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          ),
        ),
      ],
    );
  }
}
