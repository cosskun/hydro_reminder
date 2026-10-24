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
    final isEn = provider.language == 'en';
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          backgroundColor: isDark ? const Color(0xFF1C2541) : Colors.white,
          title: Text(
            isEn ? 'Delete Log?' : 'Kaydı Sil?',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isDark ? const Color(0xFFF1F5F9) : const Color(0xFF0F172A),
            ),
          ),
          content: Text(
            isEn
                ? 'Are you sure you want to delete this water intake entry?'
                : 'Bu su tüketim kaydını silmek istediğinizden emin misiniz?',
            style: TextStyle(
              color: isDark ? const Color(0xFF94A3B8) : Colors.grey.shade700,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                isEn ? 'Cancel' : 'Vazgeç',
                style: TextStyle(color: isDark ? Colors.grey.shade400 : Colors.grey.shade600),
              ),
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
              child: Text(isEn ? 'Delete' : 'Sil'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEn = provider.language == 'en';
    final parsedDate = DateTime.parse(dateKey);
    final formattedHeaderDate = DateFormat('dd MMMM yyyy, EEEE', isEn ? 'en_US' : 'tr_TR').format(parsedDate);
    final isDateToday = dateKey == DateFormat('yyyy-MM-dd').format(DateTime.now());

    final totalForDay = dayLogs.fold(0, (sum, log) => sum + log.amountMl);

    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 16.0, bottom: 8.0, left: 4.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isDateToday ? (isEn ? 'Today' : 'Bugün') : formattedHeaderDate,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: isDateToday
                      ? primary
                      : (isDark ? const Color(0xFF94A3B8) : Colors.grey.shade600),
                ),
              ),
              Text(
                isEn ? 'Total: $totalForDay ml' : 'Toplam: $totalForDay ml',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: isDark ? const Color(0xFFF1F5F9) : const Color(0xFF1E293B),
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
              color: isDark ? const Color(0xFF3A506B) : primary.withValues(alpha: 0.12),
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
                            : primary.withValues(alpha: 0.1),
                        child: Text(
                          log.beverage.icon,
                          style: const TextStyle(fontSize: 18),
                        ),
                      ),
                      title: Text(
                        '${log.amountMl} ml ${log.beverage.localizedName(provider.language)}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isDark ? const Color(0xFFF1F5F9) : const Color(0xFF1E293B),
                          fontSize: 13.5,
                        ),
                      ),
                      subtitle: Text(
                        isBeverageDifferent
                            ? (isEn
                                ? '$timeString  •  (${log.rawAmountMl} ml consumed, net hydration)'
                                : '$timeString  •  (${log.rawAmountMl} ml içildi, net hidrasyon)')
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
                        color: isDark ? const Color(0xFF3A506B).withValues(alpha: 0.5) : primary.withValues(alpha: 0.08),
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
