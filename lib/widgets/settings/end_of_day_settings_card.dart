import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/water_provider.dart';
import 'settings_card_wrapper.dart';

class EndOfDaySettingsCard extends StatelessWidget {
  const EndOfDaySettingsCard({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<WaterProvider>(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SettingsCardWrapper(
      title: 'Gün Sonu Özet Bildirimi',
      titleTrailing: const Text('🌙', style: TextStyle(fontSize: 20)),
      children: [
        const SizedBox(height: -8),
        Text(
          'Günün belirlediğiniz saatinde o gün içtiğiniz ve hedefinize ulaşmak için kalan su miktarını bildirim olarak iletir.',
          style: TextStyle(
            fontSize: 12,
            color: isDark ? const Color(0xFF94A3B8) : Colors.grey,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 16),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(
            'Gün Sonu Özeti',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isDark ? const Color(0xFFF1F5F9) : Colors.blue.shade900,
            ),
          ),
          subtitle: Text(
            provider.isEndOfDayEnabled ? 'Her gün belirlenen saatte iletilecek' : 'Kapalı',
            style: TextStyle(fontSize: 11, color: isDark ? const Color(0xFF94A3B8) : Colors.grey),
          ),
          value: provider.isEndOfDayEnabled,
          activeColor: const Color(0xFF0288D1),
          onChanged: (val) {
            provider.updateEndOfDaySettings(
              isEnabled: val,
              hour: provider.endOfDayHour,
              minute: provider.endOfDayMinute,
            );
          },
        ),
        if (provider.isEndOfDayEnabled) ...[
          const Divider(height: 16, thickness: 0.5),
          InkWell(
            onTap: () async {
              final time = await showTimePicker(
                context: context,
                initialTime: TimeOfDay(
                  hour: provider.endOfDayHour,
                  minute: provider.endOfDayMinute,
                ),
                builder: (context, child) {
                  return MediaQuery(
                    data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
                    child: child ?? const SizedBox.shrink(),
                  );
                },
              );
              if (time != null) {
                provider.updateEndOfDaySettings(
                  isEnabled: true,
                  hour: time.hour,
                  minute: time.minute,
                );
              }
            },
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.access_time_rounded,
                        size: 20,
                        color: isDark ? const Color(0xFF38BDF8) : Colors.blue.shade700,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Bildirim Saati',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isDark ? const Color(0xFFF1F5F9) : Colors.blue.shade900,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF0B132B) : Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isDark ? const Color(0xFF3A506B) : Colors.blue.shade100,
                      ),
                    ),
                    child: Row(
                      children: [
                        Text(
                          '${provider.endOfDayHour.toString().padLeft(2, '0')}:${provider.endOfDayMinute.toString().padLeft(2, '0')}',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: isDark ? const Color(0xFF38BDF8) : Colors.blue.shade800,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          Icons.edit_outlined,
                          size: 14,
                          color: isDark ? const Color(0xFF38BDF8) : Colors.blue.shade700,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
        const Divider(height: 24, thickness: 0.5),
        InkWell(
          onTap: () {
            provider.sendSleepTipNotification();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Uyku & Su bildirimi bildirim çubuğunuza gönderildi! 🌙'),
                duration: Duration(seconds: 2),
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF0B132B) : Colors.blue.shade50.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark ? const Color(0xFF3A506B) : Colors.blue.shade100,
              ),
            ),
            child: Row(
              children: [
                const Text('💤', style: TextStyle(fontSize: 16)),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Kaliteli Uyku İpucu Bildirimi',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: isDark ? const Color(0xFFF1F5F9) : Colors.blue.shade900,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '"Uyumadan 2 saat önce su alımını tamamla!" uyarısı',
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark ? const Color(0xFF94A3B8) : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 6),
                Icon(
                  Icons.send_rounded,
                  size: 18,
                  color: isDark ? const Color(0xFF38BDF8) : Colors.blue.shade700,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
