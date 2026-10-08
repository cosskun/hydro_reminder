import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/water_provider.dart';
import 'settings_card_wrapper.dart';

class NotificationSettingsCard extends StatelessWidget {
  final bool hasNotificationPermission;
  final VoidCallback onRequestPermission;

  const NotificationSettingsCard({
    super.key,
    required this.hasNotificationPermission,
    required this.onRequestPermission,
  });

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<WaterProvider>(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SettingsCardWrapper(
      title: 'Bildirim ve Alarm Ayarları',
      titleTrailing: const Icon(Icons.notifications_active_outlined, color: Color(0xFF38BDF8)),
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: hasNotificationPermission
                ? (isDark ? const Color(0xFF064E3B) : Colors.green.shade50.withValues(alpha: 0.4))
                : (isDark ? const Color(0xFF7C2D12) : Colors.orange.shade50.withValues(alpha: 0.4)),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: hasNotificationPermission
                  ? (isDark ? Colors.green.shade700 : Colors.green.shade100)
                  : (isDark ? Colors.orange.shade700 : Colors.orange.shade200),
            ),
          ),
          child: Row(
            children: [
              Icon(
                hasNotificationPermission ? Icons.check_circle_outline : Icons.warning_amber_rounded,
                color: hasNotificationPermission ? Colors.greenAccent : Colors.orangeAccent,
                size: 18,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  hasNotificationPermission
                      ? 'Telefon bildirim izinleri aktif.'
                      : 'Telefon bildirim izinleri kapalı! Alarmlar çalmayabilir.',
                  style: TextStyle(
                    fontSize: 12,
                    color: hasNotificationPermission
                        ? (isDark ? const Color(0xFFF1F5F9) : Colors.green.shade900)
                        : (isDark ? const Color(0xFFF1F5F9) : Colors.orange.shade900),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              if (!hasNotificationPermission)
                TextButton(
                  onPressed: onRequestPermission,
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    foregroundColor: const Color(0xFF38BDF8),
                  ),
                  child: const Text(
                    'İzin İste',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(
            'Su Hatırlatıcı Bildirimleri',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isDark ? const Color(0xFFF1F5F9) : Colors.blue.shade900,
            ),
          ),
          subtitle: Text(
            'Gün içindeki tüm hatırlatıcıları açar/kapatır.',
            style: TextStyle(fontSize: 11, color: isDark ? const Color(0xFF94A3B8) : Colors.grey),
          ),
          value: provider.isNotificationsEnabled,
          activeColor: const Color(0xFF0288D1),
          onChanged: (val) {
            provider.updateNotificationSettings(
              isEnabled: val,
              sound: provider.isSoundEnabled,
              vibration: provider.isVibrationEnabled,
            );
          },
        ),
        const Divider(height: 16, thickness: 0.5),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(
            'Sesli Uyarı',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isDark ? const Color(0xFFF1F5F9) : Colors.blue.shade900,
            ),
          ),
          subtitle: Text(
            'Alarm çaldığında zil sesi çalar.',
            style: TextStyle(fontSize: 11, color: isDark ? const Color(0xFF94A3B8) : Colors.grey),
          ),
          value: provider.isSoundEnabled,
          activeColor: const Color(0xFF0288D1),
          onChanged: provider.isNotificationsEnabled
              ? (val) {
                  provider.updateNotificationSettings(
                    isEnabled: provider.isNotificationsEnabled,
                    sound: val,
                    vibration: provider.isVibrationEnabled,
                  );
                }
              : null,
        ),
        const Divider(height: 16, thickness: 0.5),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(
            'Titreşim',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isDark ? const Color(0xFFF1F5F9) : Colors.blue.shade900,
            ),
          ),
          subtitle: Text(
            'Alarm çaldığında telefon titrer.',
            style: TextStyle(fontSize: 11, color: isDark ? const Color(0xFF94A3B8) : Colors.grey),
          ),
          value: provider.isVibrationEnabled,
          activeColor: const Color(0xFF0288D1),
          onChanged: provider.isNotificationsEnabled
              ? (val) {
                  provider.updateNotificationSettings(
                    isEnabled: provider.isNotificationsEnabled,
                    sound: provider.isSoundEnabled,
                    vibration: val,
                  );
                }
              : null,
        ),
      ],
    );
  }
}
