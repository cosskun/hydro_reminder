import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/badge_item.dart';
import '../models/water_log.dart';
import '../providers/water_provider.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  bool _isBadgesExpanded = true;

  // Groups water logs by calendar day
  Map<String, List<WaterLog>> _groupLogsByDay(List<WaterLog> logs) {
    final Map<String, List<WaterLog>> grouped = {};
    final dateFormat = DateFormat('yyyy-MM-dd');
    for (final log in logs) {
      final dateKey = dateFormat.format(log.timestamp);
      if (grouped.containsKey(dateKey)) {
        grouped[dateKey]!.add(log);
      } else {
        grouped[dateKey] = [log];
      }
    }
    return grouped;
  }

  // Calculate past 7 days statistics for custom chart
  List<Map<String, dynamic>> _getLast7DaysStats(List<WaterLog> logs, int dailyGoal) {
    final List<Map<String, dynamic>> stats = [];
    final now = DateTime.now();
    final dayFormat = DateFormat('E', 'tr_TR'); // E.g., Pzt, Sal, Çar...
    final fullDateFormat = DateFormat('dd MMM', 'tr_TR');

    for (int i = 6; i >= 0; i--) {
      final targetDate = now.subtract(Duration(days: i));

      final dayTotal = logs
          .where((log) =>
              log.timestamp.year == targetDate.year &&
              log.timestamp.month == targetDate.month &&
              log.timestamp.day == targetDate.day)
          .fold(0, (sum, log) => sum + log.amountMl);

      final percentage = dailyGoal > 0 ? (dayTotal / dailyGoal).clamp(0.0, 1.2) : 0.0;

      stats.add({
        'dayLabel': dayFormat.format(targetDate),
        'dateLabel': fullDateFormat.format(targetDate),
        'amount': dayTotal,
        'percentage': percentage,
      });
    }
    return stats;
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<WaterProvider>(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final sortedLogs = List<WaterLog>.from(provider.logs)
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp)); // Newest first

    final groupedLogs = _groupLogsByDay(sortedLogs);
    final last7Days = _getLast7DaysStats(provider.logs, provider.dailyGoal);
    final badges = provider.badges;
    final unlockedCount = badges.where((b) => b.isUnlocked).length;

    // Calculate Analytics
    final uniqueDays = groupedLogs.keys.length;
    final averageIntake = uniqueDays > 0
        ? (provider.logs.fold(0, (sum, log) => sum + log.amountMl) / uniqueDays).round()
        : 0;
    final streak = provider.currentStreak;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Özet & Analiz 📊',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: isDark ? const Color(0xFFF1F5F9) : Colors.blue.shade900,
            ),
          ),
          const SizedBox(height: 16),

          // Custom 7-Day Bar Chart
          Container(
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
          ),
          const SizedBox(height: 16),

          // Statistics Grid
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  title: 'Günlük Ortalama',
                  value: '$averageIntake ml',
                  subtitle: 'aktif günlerde',
                  icon: Icons.analytics_rounded,
                  color: const Color(0xFF38BDF8),
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  title: 'Mevcut Seri',
                  value: '$streak Gün',
                  subtitle: 'hedefe ulaşma',
                  icon: Icons.local_fire_department_rounded,
                  color: Colors.orangeAccent,
                  isDark: isDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // 🏆 Badges & Achievements Section
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1C2541) : Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: isDark ? const Color(0xFF3A506B) : Colors.amber.shade100,
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: isDark ? Colors.black26 : Colors.amber.shade900.withValues(alpha: 0.03),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InkWell(
                  onTap: () {
                    setState(() {
                      _isBadgesExpanded = !_isBadgesExpanded;
                    });
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Text('🏆', style: TextStyle(fontSize: 20)),
                          const SizedBox(width: 8),
                          Text(
                            'Başarılar & Rozetler',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isDark ? const Color(0xFFF1F5F9) : Colors.blue.shade900,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF0B132B) : Colors.amber.shade50,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: isDark ? Colors.amber.shade600 : Colors.amber.shade300,
                              ),
                            ),
                            child: Text(
                              '$unlockedCount/${badges.length}',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.amber.shade300 : Colors.amber.shade900,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Icon(
                            _isBadgesExpanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                            color: isDark ? const Color(0xFF94A3B8) : Colors.grey,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (_isBadgesExpanded) ...[
                  const SizedBox(height: 6),
                  Text(
                    'Su içtikçe ve serilerini korudukça yeni rozetler kazanırsın.',
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark ? const Color(0xFF94A3B8) : Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 14),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                      childAspectRatio: 0.82,
                    ),
                    itemCount: badges.length,
                    itemBuilder: (context, index) {
                      final badge = badges[index];
                      return _buildBadgeCard(badge, isDark);
                    },
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Hydration Logs History Title
          Text(
            'Tüketim Günlüğü 📅',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? const Color(0xFFF1F5F9) : Colors.blue.shade900,
            ),
          ),
          const SizedBox(height: 12),

          // Logs List grouped by day
          if (groupedLogs.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1C2541) : Colors.blue.shade50.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isDark ? const Color(0xFF3A506B) : Colors.blue.shade50,
                ),
              ),
              child: Column(
                children: [
                  const Text('📭', style: TextStyle(fontSize: 48)),
                  const SizedBox(height: 12),
                  Text(
                    'Henüz su içme kaydı bulunmuyor.',
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? const Color(0xFF94A3B8) : Colors.blue.shade900.withValues(alpha: 0.5),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: groupedLogs.length,
              itemBuilder: (context, index) {
                final dateKey = groupedLogs.keys.elementAt(index);
                final dayLogs = groupedLogs[dateKey]!;

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
                                    onPressed: () => _confirmDeleteLog(context, log.id, provider, isDark),
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
              },
            ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildBadgeCard(BadgeItem badge, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
      decoration: BoxDecoration(
        color: badge.isUnlocked
            ? (isDark ? const Color(0xFF0F2644) : Colors.amber.shade50.withValues(alpha: 0.4))
            : (isDark ? const Color(0xFF0B132B) : Colors.grey.shade50),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: badge.isUnlocked
              ? (isDark ? const Color(0xFF38BDF8) : Colors.amber.shade300)
              : (isDark ? const Color(0xFF3A506B).withValues(alpha: 0.4) : Colors.grey.shade200),
          width: badge.isUnlocked ? 1.4 : 1.0,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            badge.icon,
            style: TextStyle(
              fontSize: 26,
              color: badge.isUnlocked ? null : Colors.grey,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            badge.title,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.bold,
              color: badge.isUnlocked
                  ? (isDark ? const Color(0xFFF1F5F9) : Colors.blue.shade900)
                  : (isDark ? const Color(0xFF64748B) : Colors.grey),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            badge.isUnlocked ? 'Kazanıldı' : badge.progressLabel,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 9,
              fontWeight: badge.isUnlocked ? FontWeight.bold : FontWeight.w500,
              color: badge.isUnlocked
                  ? (isDark ? Colors.amber.shade300 : Colors.amber.shade800)
                  : (isDark ? const Color(0xFF94A3B8) : Colors.grey.shade600),
            ),
          ),
          if (!badge.isUnlocked) ...[
            const SizedBox(height: 4),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: badge.currentProgress,
                minHeight: 3,
                backgroundColor: isDark ? const Color(0xFF3A506B) : Colors.grey.shade200,
                valueColor: AlwaysStoppedAnimation<Color>(
                  isDark ? const Color(0xFF38BDF8) : Colors.blue.shade400,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _confirmDeleteLog(BuildContext context, String logId, WaterProvider provider, bool isDark) {
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

  Widget _buildStatCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C2541) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? const Color(0xFF3A506B) : Colors.blue.shade50,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black26 : Colors.blue.shade900.withValues(alpha: 0.01),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: isDark ? const Color(0xFF94A3B8) : Colors.grey,
                ),
              ),
              Icon(icon, color: color, size: 20),
            ],
          ),
          const SizedBox(height: 12),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: isDark ? const Color(0xFFF1F5F9) : Colors.blue.shade900,
              ),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 10,
              color: isDark ? const Color(0xFF64748B) : Colors.grey.shade400,
            ),
          ),
        ],
      ),
    );
  }
}
