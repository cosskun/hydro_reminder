import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/water_provider.dart';

class EmptyAlarmsView extends StatelessWidget {
  const EmptyAlarmsView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primary = theme.colorScheme.primary;
    final isEn = Provider.of<WaterProvider>(context).language == 'en';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C2541) : primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? const Color(0xFF3A506B) : primary.withValues(alpha: 0.12),
        ),
      ),
      child: Column(
        children: [
          const Text('🔔', style: TextStyle(fontSize: 40)),
          const SizedBox(height: 12),
          Text(
            isEn ? 'No scheduled alarms yet.' : 'Kayıtlı alarm bulunmuyor.',
            style: TextStyle(
              fontSize: 14,
              color: isDark ? const Color(0xFFF1F5F9) : const Color(0xFF64748B),
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            isEn ? 'Tap the "+" button above to add an alarm.' : 'Sağ üstteki "+" butonuna basarak ekleyin.',
            style: TextStyle(
              fontSize: 12,
              color: isDark ? const Color(0xFF94A3B8) : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}
