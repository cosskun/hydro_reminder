import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/water_provider.dart';

class IosAlarmTipCard extends StatefulWidget {
  const IosAlarmTipCard({super.key});

  @override
  State<IosAlarmTipCard> createState() => _IosAlarmTipCardState();
}

class _IosAlarmTipCardState extends State<IosAlarmTipCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    // Only show on iOS platforms or web/preview when testing
    final theme = Theme.of(context);
    final isIosPlatform = !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;
    
    // We display this guide primarily on iOS, but also keep it accessible as a helpful guide
    final isDark = theme.brightness == Brightness.dark;
    final isEn = Provider.of<WaterProvider>(context).language == 'en';

    final primaryColor = theme.colorScheme.primary;

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF131D31) : const Color(0xFFF0F7FF),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? const Color(0xFF203354) : const Color(0xFFBAE6FD),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withValues(alpha: isDark ? 0.08 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () {
            setState(() {
              _isExpanded = !_isExpanded;
            });
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: primaryColor.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Text('🍎', style: TextStyle(fontSize: 18)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isEn ? 'iPhone (iOS) Alarm Guide' : 'iPhone (iOS) Alarm Kılavuzu',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: isDark ? const Color(0xFFF1F5F9) : const Color(0xFF0F172A),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            isEn
                                ? 'Tap to view full screen & loud sound tips'
                                : 'Tam ekran ve yüksek ses ipuçları için dokunun',
                            style: TextStyle(
                              fontSize: 11.5,
                              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      _isExpanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                      color: primaryColor,
                    ),
                  ],
                ),
                if (_isExpanded) ...[
                  const SizedBox(height: 14),
                  const Divider(height: 1),
                  const SizedBox(height: 14),
                  _buildTipItem(
                    emoji: '📱',
                    title: isEn ? 'How to open Full Screen?' : 'Tam Ekran Nasıl Açılır?',
                    desc: isEn
                        ? 'Apple security prevents 3rd-party apps from popping up over lock screens automatically. When the alarm fires, simply tap the notification banner or select "🚨 Open Full Screen Alarm" to launch the unclosable hydration screen.'
                        : 'Apple güvenlik ilkeleri gereği hiçbir 3. parti uygulama kilit ekranını kendi kendine tam ekranla açamaz. Alarm saati geldiğinde bildirime dokunarak veya "🚨 Tam Ekran Alarmı Aç" butonuna basarak kapatılamayan tam ekran alarmı anında başlatabilirsiniz.',
                    isDark: isDark,
                  ),
                  const SizedBox(height: 10),
                  _buildTipItem(
                    emoji: '🔊',
                    title: isEn ? 'Loud Alarm Ringtone' : 'Yüksek Sesli Kesintisiz Çalma',
                    desc: isEn
                        ? 'Ensure your physical Silent/Mute switch on the side of your iPhone is turned OFF. In iOS Settings > HydroSoft, keep "Time Sensitive Notifications" enabled. We now ring with 20+ second looping alarm chimes!'
                        : 'iPhone\'unuzun yan tarafındaki Sessiz Mod (Mute Switch) anahtarının kapalı olduğundan emin olun. Ayarlar > HydroSoft bölümünden "Zaman Duyarlı Bildirimler"e izin verin. Alarmlar artık 20+ saniye boyunca kesintisiz çalar.',
                    isDark: isDark,
                  ),
                  const SizedBox(height: 10),
                  _buildTipItem(
                    emoji: '⚡',
                    title: isEn ? 'Auto Full-Screen Wakeup (Apple Shortcuts)' : 'Otomatik Tam Ekran Uyandırma (Apple Kestirmeler)',
                    desc: isEn
                        ? 'Want iPhone to wake up and open full screen without touching anything? In Apple Shortcuts > Automation > New Automation > Time of Day > Select "Run Immediately" > Add Action "Open HydroSoft". At alarm time, iOS automatically wakes the screen into HydroSoft!'
                        : 'Bildirime basmadan telefonun doğrudan uyanıp tam ekran açılmasını isterseniz: Apple Kestirmeler (Shortcuts) > Otomasyon > Yeni Otomasyon > Günün Saati > "Hemen Çalıştır"ı seçin > "HydroSoft\'u Aç" eylemini bağlayın. Saat geldiğinde iPhone ekranı otomatik uyanıp tam ekran alarmı karşınıza çıkarır!',
                    isDark: isDark,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTipItem({
    required String emoji,
    required String title,
    required String desc,
    required bool isDark,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(emoji, style: const TextStyle(fontSize: 16)),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: isDark ? const Color(0xFFF1F5F9) : const Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                desc,
                style: TextStyle(
                  fontSize: 11.5,
                  height: 1.4,
                  color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
