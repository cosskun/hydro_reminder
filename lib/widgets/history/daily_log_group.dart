import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/water_log.dart';
import '../../providers/water_provider.dart';

class DailyLogGroup extends StatelessWidget {
  final String dateKey;
  final List<WaterLog> dayLogs;
  final WaterProvider provider;
  final bool isDark;

  const DailyLogGroup({
    super.key,
    required this.dateKey,
    required this.dayLogs,
    required this.provider,
    required this.isDark,
  });

  void _confirmDeleteLog(BuildContext context, String logId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          backgroundColor: isDark ? const Color(0xFF1C2541) : Colors.white,
          title: Text(
            'Kaydı Sil?',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isDark ? const Color(0xFFF1F5F9) : const Color(0xFF0F172A),
            ),
          ),
          content: Text(
            'Bu su tüketim kaydını silmek istediğinizden emin misiniz?',
            style: TextStyle(
              color: isDark ? const Color(0xFF94A3B8) : Colors.grey.shade700,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Vazgeç', style: TextStyle(color: isDark ? Colors.grey.shade400 : Colors.grey.shade600)),
            ),
            ElevatedButton(
              onPressed: () {
                provider.deleteLog(logId);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade400,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('Sil'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final parsedDate = DateTime.parse(dateKey);
    final formattedHeaderDate = DateFormat('dd MMMM yyyy, EEEE', 'tr_TR').format(parsedDate);
    final isDateToday = dateKey == DateFormat('yyyy-MM-dd').format(DateTime.now());

    final totalForDay = dayLogs.fold(0, (sum, log) => sum + log.amountMl);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 16.0, bottom: 8.0, left: 4.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isDateToday ? 'Bugün' : formattedHeaderDate,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: isDateToday
                      ? (isDark ? const Color(0xFF38BDF8) : Colors.blue.shade800)
                      : (isDark ? const Color(0xFF94A3B8) : Colors.grey.shade600),
                ),
              ),
              Text(
                'Toplam: $totalForDay ml',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: isDark ? const Color(0xFFF1F5F9) : Colors.blue.shade900,
                ),
              ),
            ],
          ),
        ),
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: isDark ? const Color(0xFF3A506B) : Colors.blue.shade50,
            ),
          ),
          color: isDark ? const Color(0xFF1C2541) : Colors.white,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: Column(
              children: dayLogs.map((log) {
                final timeString = DateFormat('HH:mm').format(log.timestamp);
                final isBeverageDifferent = log.rawAmountMl != log.amountMl;

                return Column(
                  children: [
                    ListTile(
                      leading: CircleAvatar(
                        backgroundColor: isDark
                            ? const Color(0xFF0B132B)
                            : Colors.blue.shade50,
                        child: Text(
                          log.beverage.icon,
                          style: const TextStyle(fontSize: 18),
                        ),
                      ),
                      title: Text(
                        '${log.amountMl} ml ${log.beverage.name}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isDark ? const Color(0xFFF1F5F9) : Colors.blue.shade900,
                          fontSize: 13.5,
                        ),
                      ),
                      subtitle: Text(
                        isBeverageDifferent
                            ? '$timeString  •  (${log.rawAmountMl} ml içildi, net hidrasyon)'
                            : timeString,
                        style: TextStyle(
                          color: isDark ? const Color(0xFF94A3B8) : Colors.grey.shade500,
                          fontSize: 11,
                        ),
                      ),
                      trailing: IconButton(
                        icon: Icon(
                          Icons.delete_outline_rounded,
                          color: Colors.red.shade300,
                          size: 20,
                        ),
                        onPressed: () => _confirmDeleteLog(context, log.id),
                      ),
                    ),
                    if (log != dayLogs.last)
                      Divider(
                        height: 1,
                        color: isDark ? const Color(0xFF3A506B).withValues(alpha: 0.5) : Colors.blue.shade50,
                      ),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }
}
