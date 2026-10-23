import 'dart:io';
import 'package:flutter/foundation.dart';
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
      titleTrailing: Icon(Icons.notifications_active_outlined, color: Theme.of(context).colorScheme.primary),
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
                    foregroundColor: Theme.of(context).colorScheme.primary,
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
        InkWell(
          onTap: () async {
            final targetVal = !provider.isNotificationsEnabled;
            final granted = await provider.updateNotificationSettings(
              isEnabled: targetVal,
              sound: provider.isSoundEnabled,
              vibration: provider.isVibrationEnabled,
            );
            onRequestPermission();
            if (targetVal && !granted && context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Bildirimleri açmak için telefon ayarlarından bildirim iznini onaylamanız gerekmektedir.',
                  ),
                  backgroundColor: Colors.orange,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Su Hatırlatıcı Bildirimleri',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isDark ? const Color(0xFFF1F5F9) : const Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Gün içindeki tüm hatırlatıcıları açar/kapatır.',
                        style: TextStyle(fontSize: 11, color: isDark ? const Color(0xFF94A3B8) : Colors.grey),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Switch(
                  value: provider.isNotificationsEnabled && hasNotificationPermission,
                  activeThumbColor: theme.colorScheme.primary,
                  onChanged: (val) async {
                    final granted = await provider.updateNotificationSettings(
                      isEnabled: val,
                      sound: provider.isSoundEnabled,
                      vibration: provider.isVibrationEnabled,
                    );
                    onRequestPermission();
                    if (val && !granted && context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Bildirimleri açmak için telefon ayarlarından bildirim iznini onaylamanız gerekmektedir.',
                          ),
                          backgroundColor: Colors.orange,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ),
        const Divider(height: 16, thickness: 0.5),
        InkWell(
          onTap: provider.isNotificationsEnabled
              ? () {
                  provider.updateNotificationSettings(
                    isEnabled: provider.isNotificationsEnabled,
                    sound: !provider.isSoundEnabled,
                    vibration: provider.isVibrationEnabled,
                  );
                }
              : null,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Sesli Uyarı',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isDark ? const Color(0xFFF1F5F9) : const Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Alarm çaldığında zil sesi çalar.',
                        style: TextStyle(fontSize: 11, color: isDark ? const Color(0xFF94A3B8) : Colors.grey),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Switch(
                  value: provider.isSoundEnabled,
                  activeThumbColor: theme.colorScheme.primary,
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
              ],
            ),
          ),
        ),
        const Divider(height: 16, thickness: 0.5),
        InkWell(
          onTap: provider.isNotificationsEnabled
              ? () {
                  provider.updateNotificationSettings(
                    isEnabled: provider.isNotificationsEnabled,
                    sound: provider.isSoundEnabled,
                    vibration: !provider.isVibrationEnabled,
                  );
                }
              : null,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Titreşim',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isDark ? const Color(0xFFF1F5F9) : const Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Telefon sessiz moddayken bile güçlü ritmik titreşimle uyarır.',
                        style: TextStyle(fontSize: 11, color: isDark ? const Color(0xFF94A3B8) : Colors.grey),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Switch(
                  value: provider.isVibrationEnabled,
                  activeThumbColor: theme.colorScheme.primary,
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
            ),
          ),
        ),
        const Divider(height: 16, thickness: 0.5),
        Builder(
          builder: (context) {
            final isIOS = !kIsWeb && Platform.isIOS;
            return InkWell(
              onTap: () async {
                final targetVal = !provider.isOngoingNotificationEnabled;
                final granted = await provider.updateOngoingNotificationSetting(targetVal);
                onRequestPermission();
                if (targetVal && !granted && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        isIOS
                            ? 'Canlı etkinliği (Live Activity) kullanabilmek için telefon ayarlarından izin vermeniz gerekmektedir.'
                            : 'Canlı ilerleme bildirimini açmak için telefon ayarlarından bildirim iznini onaylamanız gerekmektedir.',
                      ),
                      backgroundColor: Colors.orange,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  isIOS
                                      ? 'Canlı Etkinlik & Kilit Ekranı'
                                      : 'Canlı İlerleme Bildirimi',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: isDark ? const Color(0xFFF1F5F9) : const Color(0xFF0F172A),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primary.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  isIOS ? 'Live Activity' : 'Sabit Panel',
                                  style: TextStyle(
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.bold,
                                    color: theme.colorScheme.primary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            isIOS
                                ? 'Kilit ekranında ve Dynamic Island\'da maskotunuzla canlı su doluluğunu, seri alevini ve ilerleme çubuğunu göster (iOS 16.1+).'
                                : 'Bildirim çekmecesinde gün boyu su doluluk çubuğunu ve hızlı ekleme butonlarını (+200, +330, +500) göster.',
                            style: TextStyle(fontSize: 11, color: isDark ? const Color(0xFF94A3B8) : Colors.grey),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Switch(
                      value: provider.isOngoingNotificationEnabled && (isIOS || hasNotificationPermission),
                      activeThumbColor: theme.colorScheme.primary,
                      onChanged: (val) async {
                        final granted = await provider.updateOngoingNotificationSetting(val);
                        onRequestPermission();
                        if (val && !granted && context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                isIOS
                                    ? 'Canlı etkinliği (Live Activity) kullanabilmek için telefon ayarlarından izin vermeniz gerekmektedir.'
                                    : 'Canlı ilerleme bildirimini açmak için telefon ayarlarından bildirim iznini onaylamanız gerekmektedir.',
                              ),
                              backgroundColor: Colors.orange,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 10),
        InkWell(
          onTap: () async {
            await provider.toggleSmartPacing(!provider.isSmartPacingEnabled);
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 6.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text('🧠', style: TextStyle(fontSize: 18)),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              'Akıllı Tempo Hatırlatıcıları',
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w600,
                                color: isDark ? const Color(0xFFF1F5F9) : const Color(0xFF1E293B),
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFF10B981).withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'Adaptif',
                              style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold, color: Color(0xFF10B981)),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Gün ortası (14:00) ve akşamüstü (18:30) tüketim hızınızı analiz eder; geride kalırsanız motive edici akıllı uyarı gönderir.',
                        style: TextStyle(fontSize: 11, color: isDark ? const Color(0xFF94A3B8) : Colors.grey),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Switch(
                  value: provider.isSmartPacingEnabled && hasNotificationPermission,
                  activeThumbColor: const Color(0xFF10B981),
                  onChanged: (val) async {
                    await provider.toggleSmartPacing(val);
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
