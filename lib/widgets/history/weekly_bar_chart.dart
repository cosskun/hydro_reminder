import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C2541) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black26 : Colors.blue.shade900.withValues(alpha: 0.02),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
        border: Border.all(
          color: isDark ? const Color(0xFF3A506B) : Colors.blue.shade50,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Son 7 Günlük Tüketim',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: isDark ? const Color(0xFF38BDF8) : Colors.blue.shade900.withValues(alpha: 0.8),
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
                final isToday = dayData['dayLabel'] == DateFormat('E', 'tr_TR').format(DateTime.now());

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
                              ? (isDark ? const Color(0xFF38BDF8) : Colors.blue.shade800)
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
                              ? [const Color(0xFF0288D1), const Color(0xFF38BDF8)]
                              : (isDark
                                  ? [const Color(0xFF334155), const Color(0xFF475569)]
                                  : [Colors.blue.shade200, Colors.blue.shade100]),
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
                              ? (isDark ? const Color(0xFFF1F5F9) : Colors.blue.shade900)
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
