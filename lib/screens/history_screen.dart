import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/water_log.dart';
import '../providers/water_provider.dart';
import '../widgets/history/weekly_bar_chart.dart';
import '../widgets/history/stat_card.dart';
import '../widgets/history/badge_card.dart';
import '../widgets/history/daily_log_group.dart';

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
          WeeklyBarChart(
            last7Days: last7Days,
            isDark: isDark,
          ),
          const SizedBox(height: 16),

          // Statistics Grid
          Row(
            children: [
              Expanded(
                child: StatCard(
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
                child: StatCard(
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
          const SizedBox(height: 12),

          // Streak Freeze / Shield Status Card
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF0FDF4),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark
                    ? const Color(0xFF10B981).withValues(alpha: 0.4)
                    : const Color(0xFF86EFAC),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Text('🛡️', style: TextStyle(fontSize: 20)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              'Seri Kalkanı',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: isDark ? const Color(0xFFF1F5F9) : const Color(0xFF065F46),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${provider.streakShields} Adet Aktif',
                            style: const TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF10B981),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Her hafta 1 ücretsiz kalkan yenilenir. Hedefinizi kaçırdığınız günlerde serinizi korur.',
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF047857),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
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
                      Expanded(
                        child: Row(
                          children: [
                            const Text('🏆', style: TextStyle(fontSize: 20)),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Başarılar & Rozetler',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? const Color(0xFFF1F5F9) : Colors.blue.shade900,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
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
                      return BadgeCard(badge: badge, isDark: isDark);
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

                return DailyLogGroup(
                  dateKey: dateKey,
                  dayLogs: dayLogs,
                  provider: provider,
                  isDark: isDark,
                );
              },
            ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

}
