import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../providers/water_provider.dart';

class WeeklyBarChart extends StatelessWidget {
  final List<Map<String, dynamic>> last7Days;
  final bool isDark;

  const WeeklyBarChart({
    super.key,
    required this.last7Days,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final secondary = theme.colorScheme.secondary;
    final isEn = Provider.of<WaterProvider>(context).language == 'en';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C2541) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black26 : primary.withValues(alpha: 0.04),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
        border: Border.all(
          color: isDark ? const Color(0xFF3A506B) : primary.withValues(alpha: 0.12),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isEn ? 'Past 7 Days Intake' : 'Son 7 Günlük Tüketim',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: isDark ? primary : primary,
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 140,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: last7Days.map((dayData) {
                final percentage = dayData['percentage'] as double;
                final barHeight = 90 * percentage;
                final isToday = dayData['dayLabel'] == DateFormat('E', isEn ? 'en_US' : 'tr_TR').format(DateTime.now());

                return Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        dayData['amount'] > 0 ? '${dayData['amount']}' : '',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: isToday
                              ? primary
                              : (isDark ? const Color(0xFF64748B) : Colors.grey.shade600),
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      width: 16,
                      height: barHeight.clamp(4.0, 90.0),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: isToday
                              ? [primary, secondary]
                              : (isDark
                                  ? [const Color(0xFF334155), const Color(0xFF475569)]
                                  : [primary.withValues(alpha: 0.35), primary.withValues(alpha: 0.18)]),
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    const SizedBox(height: 8),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        dayData['dayLabel'] as String,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                          color: isToday
                              ? (isDark ? const Color(0xFFF1F5F9) : primary)
                              : (isDark ? const Color(0xFF64748B) : Colors.grey),
                        ),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
