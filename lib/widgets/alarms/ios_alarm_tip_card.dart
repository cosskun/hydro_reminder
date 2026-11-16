import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/water_provider.dart';
import '../../services/alarm_service.dart';
import '../../services/storage_service.dart';

class IosAlarmTipCard extends StatefulWidget {
  const IosAlarmTipCard({super.key});

  @override
  State<IosAlarmTipCard> createState() => _IosAlarmTipCardState();
}

class _IosAlarmTipCardState extends State<IosAlarmTipCard> {
  bool _isExpanded = false;
  bool _isAutoFullScreenEnabled = false;

  @override
  void initState() {
    super.initState();
    _isAutoFullScreenEnabled = StorageService().getAutoFullScreenEnabled();
  }

  Future<void> _disableAutoFullScreen(bool isEn) async {
    setState(() {
      _isAutoFullScreenEnabled = false;
    });
    await StorageService().saveAutoFullScreenEnabled(false);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isEn
              ? 'Auto full-screen wakeup turned off.'
              : 'Otomatik tam ekran uyandırma kapatıldı.',
        ),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showShortcutsPermissionDialog(BuildContext context, bool isDark, bool isEn) {
    final primary = Theme.of(context).colorScheme.primary;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: isDark ? const Color(0xFF131D31) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        final double navBarHeight = math.max(
          MediaQuery.of(ctx).viewPadding.bottom,
          MediaQuery.of(ctx).padding.bottom,
        );
        final double bottomPadding = navBarHeight > 0 ? navBarHeight + 14 : 20.0;

        return SafeArea(
          bottom: false,
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(20, 20, 20, bottomPadding),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.amber.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Text('⚡', style: TextStyle(fontSize: 22)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isEn
                                ? 'Auto Full-Screen Setup'
                                : 'Otomatik Tam Ekran Kurulumu',
                            style: TextStyle(
                              fontSize: 16.5,
                              fontWeight: FontWeight.bold,
                              color: isDark ? const Color(0xFFF1F5F9) : const Color(0xFF0F172A),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            isEn
                                ? 'Apple Shortcuts Integration'
                                : 'Apple Kestirmeler Entegrasyonu',
                            style: TextStyle(
                              fontSize: 11.5,
                              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.pop(ctx),
                      color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Apple Security Explanation Alert Box
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF0FDF4),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isDark ? const Color(0xFF334155) : const Color(0xFFBBF7D0),
                      width: 1.2,
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('🔒', style: TextStyle(fontSize: 16)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          isEn
                              ? 'Apple iOS security prevents third-party apps from creating personal automations in the background without user consent. When you tap "Allow & Open Shortcuts", iOS Shortcuts will launch immediately so you can set it up in 3 easy steps:'
                              : 'Apple iOS güvenlik ilkeleri gereği hiçbir uygulama kilit ekranı otomasyonunu arkada gizlice oluşturamaz. "İzin Ver & Kestirmeler\'i Aç" dediğinizde telefonunuzun Kestirmeler uygulaması doğrudan açılacaktır. Aşağıdaki 3 hızlı adımı bir defaya mahsus tamamlayabilirsiniz:',
                          style: TextStyle(
                            fontSize: 11.5,
                            height: 1.4,
                            color: isDark ? const Color(0xFFE2E8F0) : const Color(0xFF166534),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // 3 Step-by-step Guides
                _buildStepItem(
                  step: '1',
                  emoji: '⏰',
                  title: isEn ? 'New Automation > Time of Day' : 'Yeni Otomasyon > Günün Saati',
                  desc: isEn
                      ? 'In Shortcuts, go to "Automation" tab > tap "+" > select "Time of Day" and set your alarm hour.'
                      : 'Kestirmeler\'de "Otomasyon" sekmesine gidin > "+" butonuna basın > "Günün Saati"ni seçip alarm saatinizi belirleyin.',
                  isDark: isDark,
                  primary: primary,
                ),
                const SizedBox(height: 10),
                _buildStepItem(
                  step: '2',
                  emoji: '⚡',
                  title: isEn ? 'Select "Run Immediately"' : '"Hemen Çalıştır"ı Seçin',
                  desc: isEn
                      ? 'Select "Run Immediately" and turn off "Notify When Run" for a seamless automatic trigger.'
                      : '"Hemen Çalıştır" seçeneğini işaretleyin ve "Çalıştırıldığında Bildir"i kapatın.',
                  isDark: isDark,
                  primary: primary,
                ),
                const SizedBox(height: 10),
                _buildStepItem(
                  step: '3',
                  emoji: '💧',
                  title: isEn ? 'Add Action > "Open HydroSoft"' : 'Eylem Ekle > "HydroSoft\'u Aç"',
                  desc: isEn
                      ? 'Search for "HydroSoft" and choose "Open HydroSoft". Tap Done! iPhone will now wake directly into HydroSoft at alarm time.'
                      : 'Arama kutusuna "HydroSoft" yazıp "HydroSoft\'u Aç" eylemini seçin ve Bitti\'ye basın. Saat geldiğinde ekranınız otomatik açılır!',
                  isDark: isDark,
                  primary: primary,
                ),
                const SizedBox(height: 22),

                // Action Buttons: Reddet / Vazgeç vs İzin Ver & Kestirmeler'i Aç
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(ctx),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                          side: BorderSide(
                            color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: Text(
                          isEn ? 'Cancel' : 'Vazgeç / Reddet',
                          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      flex: 3,
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          Navigator.pop(ctx);
                          setState(() {
                            _isAutoFullScreenEnabled = true;
                          });
                          await StorageService().saveAutoFullScreenEnabled(true);
                          await AlarmService().openShortcutsApp();
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                isEn
                                    ? 'Opening Apple Shortcuts... Follow the 3 steps to finish!'
                                    : 'Apple Kestirmeler açılıyor! 3 adımı tamamlayabilirsiniz.',
                              ),
                              duration: const Duration(seconds: 4),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                        icon: const Icon(Icons.open_in_new_rounded, size: 16),
                        label: Text(
                          isEn ? 'Allow & Open' : 'İzin Ver & Aç',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          elevation: 0,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStepItem({
    required String step,
    required String emoji,
    required String title,
    required String desc,
    required bool isDark,
    required Color primary,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 24,
          height: 24,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: primary.withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
          child: Text(
            step,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: primary,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(emoji, style: const TextStyle(fontSize: 14)),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.bold,
                        color: isDark ? const Color(0xFFF1F5F9) : const Color(0xFF0F172A),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                desc,
                style: TextStyle(
                  fontSize: 11,
                  height: 1.35,
                  color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
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
                  const SizedBox(height: 12),
                  _buildTipItem(
                    emoji: '🔊',
                    title: isEn ? 'Loud Alarm Ringtone' : 'Yüksek Sesli Kesintisiz Çalma',
                    desc: isEn
                        ? 'Ensure your physical Silent/Mute switch on the side of your iPhone is turned OFF. In iOS Settings > HydroSoft, keep "Time Sensitive Notifications" enabled. We now ring with 20+ second looping alarm chimes!'
                        : 'iPhone\'unuzun yan tarafındaki Sessiz Mod (Mute Switch) anahtarının kapalı olduğundan emin olun. Ayarlar > HydroSoft bölümünden "Zaman Duyarlı Bildirimler"e izin verin. Alarmlar artık 20+ saniye boyunca kesintisiz çalar.',
                    isDark: isDark,
                  ),
                  const SizedBox(height: 4),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 26),
                      child: TextButton.icon(
                        onPressed: () => AlarmService().openNotificationSettings(),
                        icon: const Icon(Icons.settings_outlined, size: 14),
                        label: Text(
                          isEn ? 'Open iOS Notification Settings' : 'iOS Bildirim Ayarlarını Aç',
                          style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600),
                        ),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          visualDensity: VisualDensity.compact,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildTipItem(
                    emoji: '⚡',
                    title: isEn ? 'Auto Full-Screen Wakeup (Apple Shortcuts)' : 'Otomatik Tam Ekran Uyandırma (Apple Kestirmeler)',
                    desc: isEn
                        ? 'Want iPhone to wake up and open full screen without touching anything? In Apple Shortcuts > Automation > New Automation > Time of Day > Select "Run Immediately" > Add Action "Open HydroSoft". At alarm time, iOS automatically wakes the screen into HydroSoft!'
                        : 'Bildirime basmadan telefonun doğrudan uyanıp tam ekran açılmasını isterseniz: Apple Kestirmeler (Shortcuts) > Otomasyon > Yeni Otomasyon > Günün Saati > "Hemen Çalıştır"ı seçin > "HydroSoft\'u Aç" eylemini bağlayın. Saat geldiğinde iPhone ekranı otomatik uyanıp tam ekran alarmı karşınıza çıkarır!',
                    isDark: isDark,
                  ),
                  const SizedBox(height: 14),

                  // Toggle for Auto Full-Screen Wakeup
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1A263D) : Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: _isAutoFullScreenEnabled
                            ? primaryColor.withValues(alpha: 0.6)
                            : (isDark ? const Color(0xFF2A3C5A) : const Color(0xFFE2E8F0)),
                        width: 1.2,
                      ),
                      boxShadow: [
                        if (!isDark)
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(7),
                          decoration: BoxDecoration(
                            color: (_isAutoFullScreenEnabled ? Colors.amber : Colors.grey)
                                .withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            _isAutoFullScreenEnabled ? '⚡' : '💤',
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isEn
                                    ? 'Auto Full-Screen Wakeup'
                                    : 'Otomatik Tam Ekran Uyandırma',
                                style: TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? const Color(0xFFF1F5F9) : const Color(0xFF0F172A),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                _isAutoFullScreenEnabled
                                    ? (isEn
                                        ? 'Active • iPhone wakes at alarm time'
                                        : 'Açık • Alarm saatinde ekran uyanır')
                                    : (isEn
                                        ? 'Off • Tap to set up with Shortcuts'
                                        : 'Kapalı • Kestirmeler ile kurmak için açın'),
                                style: TextStyle(
                                  fontSize: 11,
                                  color: _isAutoFullScreenEnabled
                                      ? (isDark ? const Color(0xFF38BDF8) : const Color(0xFF0284C7))
                                      : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
                                  fontWeight: _isAutoFullScreenEnabled ? FontWeight.w600 : FontWeight.normal,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Switch.adaptive(
                          value: _isAutoFullScreenEnabled,
                          activeColor: primaryColor,
                          onChanged: (val) {
                            if (val) {
                              _showShortcutsPermissionDialog(context, isDark, isEn);
                            } else {
                              _disableAutoFullScreen(isEn);
                            }
                          },
                        ),
                      ],
                    ),
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
