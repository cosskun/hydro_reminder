import 'package:flutter/material.dart';

class EmptyAlarmsView extends StatelessWidget {
  const EmptyAlarmsView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C2541) : Colors.blue.shade50.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? const Color(0xFF3A506B) : Colors.blue.shade50,
        ),
      ),
      child: Column(
        children: [
          const Text('🔔', style: TextStyle(fontSize: 40)),
          const SizedBox(height: 12),
          Text(
            'Kayıtlı alarm bulunmuyor.',
            style: TextStyle(
              fontSize: 14,
              color: isDark ? const Color(0xFFF1F5F9) : Colors.blue.shade900.withValues(alpha: 0.5),
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Sağ üstteki "+" butonuna basarak ekleyin.',
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
