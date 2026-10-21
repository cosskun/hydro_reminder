import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/water_provider.dart';
import 'settings_card_wrapper.dart';

class IosShortcutsSettingsCard extends StatelessWidget {
  const IosShortcutsSettingsCard({super.key});

  void _showSiriCommandsModal(BuildContext context, bool isDark) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: isDark ? const Color(0xFF1C2541) : Colors.white,
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
                Row(
                  children: [
                    const Text('🎙️', style: TextStyle(fontSize: 24)),
                    const SizedBox(width: 8),
                    Text(
                      'Siri Sesli Komutları',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDark ? const Color(0xFFF1F5F9) : Colors.blue.shade900,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  'iPhone\'unuzda Siri\'yi etkinleştirip aşağıdaki örnek cümleleri söyleyerek uygulamayı açmadan su kaydedebilirsiniz:',
                  style: TextStyle(
                    fontSize: 12.5,
                    color: isDark ? const Color(0xFF94A3B8) : Colors.grey.shade700,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 16),
                _buildCommandTile(
                  '💧',
                  '"Hey Siri, HydroSoft ile 250 ml su içtim"',
                  'Belirttiğiniz miktarı gününüze ekler ve kalan hedefi seslendirir.',
                  isDark,
                ),
                const SizedBox(height: 10),
                _buildCommandTile(
                  '🥛',
                  '"Hey Siri, HydroSoft ile bir bardak su ekle"',
                  'Varsayılan bardak miktarını (+200 ml) kaydeder.',
                  isDark,
                ),
                const SizedBox(height: 10),
                _buildCommandTile(
                  '📊',
                  '"Hey Siri, HydroSoft bugün ne kadar su içtim?"',
                  'Bugünkü toplam tüketiminizi ve kalan ihtiyacınızı sesli yanıtlar.',
                  isDark,
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(ctx),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0288D1),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('Anladım', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showBackTapGuideModal(BuildContext context, bool isDark) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: isDark ? const Color(0xFF1C2541) : Colors.white,
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
                Row(
                  children: [
                    const Text('📲', style: TextStyle(fontSize: 24)),
                    const SizedBox(width: 8),
                    Text(
                      'Arkaya Dokunma & Eylem Düğmesi',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDark ? const Color(0xFFF1F5F9) : Colors.blue.shade900,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  'iPhone\'unuzun arkasına 2 kez dokunduğunuzda ekranın üstünden şeffaf bir bildirim menüsü açılır (🥛 Bardak, 🥤 Küçük Şişe, 🫙 Şişe/Matara). Buradan tek tıkla içtiğiniz suyu seçip kaydedebilirsiniz.\n\nKurulum için:',
                  style: TextStyle(
                    fontSize: 12.5,
                    color: isDark ? const Color(0xFF94A3B8) : Colors.grey.shade700,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 16),
                _buildStepTile('1', 'iPhone Ayarları > Erişilebilirlik > Dokunma menüsüne gidin.', isDark),
                const SizedBox(height: 10),
                _buildStepTile('2', 'En alttaki "Arkaya Dokun" seçeneğine girip "Çift Dokunma"yı seçin.', isDark),
                const SizedBox(height: 10),
                _buildStepTile('3', 'Kestirmeler bölümünden "Hızlı Su Seçimi" (HydroSoft) eylemini atayın.', isDark),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(ctx),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0288D1),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('Tamam', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  static Widget _buildCommandTile(String emoji, String title, String subtitle, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0B132B) : const Color(0xFFF4F9FD),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? const Color(0xFF3A506B) : Colors.blue.shade100,
          width: 0.8,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 18)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.bold,
                    color: isDark ? const Color(0xFF38BDF8) : const Color(0xFF0288D1),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? const Color(0xFF94A3B8) : Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildStepTile(String step, String text, bool isDark) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 22,
          height: 22,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: const Color(0xFF0288D1),
            borderRadius: BorderRadius.circular(11),
          ),
          child: Text(
            step,
            style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 12.5,
              color: isDark ? const Color(0xFFF1F5F9) : const Color(0xFF1E293B),
              height: 1.3,
            ),
          ),
        ),
      ],
    );
  }

  void _showHealthKitInfoModal(BuildContext context, bool isDark) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: isDark ? const Color(0xFF1C2541) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        final bottomInset = MediaQuery.of(ctx).viewPadding.bottom;
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.fromLTRB(20, 24, 20, 24 + bottomInset),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text('❤️', style: TextStyle(fontSize: 24)),
                    const SizedBox(width: 8),
                    Text(
                      'Apple Sağlık (HealthKit)',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDark ? const Color(0xFFF1F5F9) : Colors.blue.shade900,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  'HydroSoft, Apple Sağlık uygulaması ile çift yönlü tam entegrasyon sunar:',
                  style: TextStyle(
                    fontSize: 12.5,
                    color: isDark ? const Color(0xFF94A3B8) : Colors.grey.shade700,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 16),
                _buildCommandTile(
                  '💧',
                  'Otomatik Su Yazma',
                  'HydroSoft veya Siri üzerinden eklediğiniz tüm su kayıtları Apple Sağlık "Beslenme > Su" kategorisine anında yazılır.',
                  isDark,
                ),
                const SizedBox(height: 10),
                _buildCommandTile(
                  '⌚',
                  'Apple Watch & Aktivite Uyumu',
                  'Apple Watch veya iPhone\'unuzun kaydettiği adım ve aktif kalori verileri ile günlük su dengeniz kusursuz hesaplanır.',
                  isDark,
                ),
                const SizedBox(height: 10),
                _buildCommandTile(
                  '🔒',
                  'Gizlilik & Güvenlik',
                  'Sağlık verileriniz sadece cihazınızda kalır ve asla üçüncü şahıslarla paylaşılmaz.',
                  isDark,
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(ctx),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE11D48),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('Anladım', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<WaterProvider>(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SettingsCardWrapper(
      title: 'iOS & Apple Özellikleri 🍏',
      titleTrailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: const Color(0xFF0288D1).withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Text(
          'iPhone Özel',
          style: TextStyle(
            fontSize: 10.5,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0288D1),
          ),
        ),
      ),
      children: [
        Text(
          'iPhone\'unuzun gelişmiş donanım, sesli asistan ve Apple Sağlık özellikleriyle ellerinizi kullanmadan hızlı ve akıllı su takibi yapın.',
          style: TextStyle(
            fontSize: 11.5,
            color: isDark ? const Color(0xFF94A3B8) : Colors.grey.shade600,
            height: 1.3,
          ),
        ),
        const SizedBox(height: 16),

        // 1. Siri Voice Assistant Switch
        InkWell(
          onTap: () {
            provider.updateIosShortcutsSettings(isSiriEnabled: !provider.isSiriShortcutsEnabled);
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
                        'Siri ile Sesli Komut',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isDark ? const Color(0xFFF1F5F9) : Colors.blue.shade900,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '"Hey Siri, 250 ml su içtim" diyerek eller serbest su ekleyin.',
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark ? const Color(0xFF94A3B8) : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Switch(
                  value: provider.isSiriShortcutsEnabled,
                  activeThumbColor: const Color(0xFF0288D1),
                  onChanged: (val) {
                    provider.updateIosShortcutsSettings(isSiriEnabled: val);
                  },
                ),
              ],
            ),
          ),
        ),
        if (provider.isSiriShortcutsEnabled)
          Padding(
            padding: const EdgeInsets.only(top: 4, bottom: 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: () => _showSiriCommandsModal(context, isDark),
                icon: const Icon(Icons.mic_none_rounded, size: 16),
                label: const Text('Sesli Komutları & Cümleleri Gör', style: TextStyle(fontSize: 11.5)),
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF0288D1),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                ),
              ),
            ),
          ),

        const Divider(height: 16, thickness: 0.5),

        // 2. Back Tap & Action Button Switch
        InkWell(
          onTap: () {
            provider.updateIosShortcutsSettings(isBackTapEnabled: !provider.isBackTapEnabled);
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
                        'Arkaya Dokunma & Eylem Düğmesi',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isDark ? const Color(0xFFF1F5F9) : Colors.blue.shade900,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Telefonun arkasına çift vurarak veya Eylem Düğmesine basarak hızlı su menüsünü açın.',
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark ? const Color(0xFF94A3B8) : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Switch(
                  value: provider.isBackTapEnabled,
                  activeThumbColor: const Color(0xFF0288D1),
                  onChanged: (val) {
                    provider.updateIosShortcutsSettings(isBackTapEnabled: val);
                  },
                ),
              ],
            ),
          ),
        ),
        if (provider.isBackTapEnabled)
          Padding(
            padding: const EdgeInsets.only(top: 4, bottom: 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: () => _showBackTapGuideModal(context, isDark),
                icon: const Icon(Icons.touch_app_outlined, size: 16),
                label: const Text('Arkaya Dokunma Kurulum Kılavuzu', style: TextStyle(fontSize: 11.5)),
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF0288D1),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                ),
              ),
            ),
          ),

        const Divider(height: 16, thickness: 0.5),

        // 3. Apple Health (HealthKit) Switch
        InkWell(
          onTap: () async {
            final newVal = !provider.isAppleHealthSyncEnabled;
            final success = await provider.updateAppleHealthSettings(isEnabled: newVal);
            if (!success && newVal && context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Apple Sağlık erişim izni verilmedi veya iptal edildi.'),
                  backgroundColor: Colors.redAccent,
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
                              'Apple Sağlık (HealthKit)',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: isDark ? const Color(0xFFF1F5F9) : Colors.blue.shade900,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Icon(Icons.favorite_rounded, size: 15, color: Color(0xFFE11D48)),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'İçtiğiniz suları Apple Sağlık uygulamasına (Dietary Water) otomatik senkronize edin.',
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark ? const Color(0xFF94A3B8) : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Switch(
                  value: provider.isAppleHealthSyncEnabled,
                  activeThumbColor: const Color(0xFFE11D48),
                  onChanged: (val) async {
                    final success = await provider.updateAppleHealthSettings(isEnabled: val);
                    if (!success && val && context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Apple Sağlık erişim izni verilmedi veya iptal edildi.'),
                          backgroundColor: Colors.redAccent,
                        ),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ),
        if (provider.isAppleHealthSyncEnabled) ...[
          Padding(
            padding: const EdgeInsets.only(top: 6, bottom: 4),
            child: Row(
              children: [
                Expanded(
                  child: TextButton.icon(
                    onPressed: () => _showHealthKitInfoModal(context, isDark),
                    icon: const Icon(Icons.info_outline_rounded, size: 16),
                    label: const Text('Sağlık Bilgisi', style: TextStyle(fontSize: 11.5)),
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFFE11D48),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    ),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () async {
                    final synced = await provider.syncTodayLogsToAppleHealth();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('$synced adet su kaydı Apple Sağlık ile senkronize edildi.'),
                          backgroundColor: const Color(0xFF10B981),
                        ),
                      );
                    }
                  },
                  icon: const Icon(Icons.sync_rounded, size: 14),
                  label: const Text('Bugünü Senkronize Et', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDark ? const Color(0xFF881337) : const Color(0xFFFFE4E6),
                    foregroundColor: isDark ? Colors.white : const Color(0xFFBE123C),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ],
            ),
          ),
          if (provider.todayHealthSteps > 0)
            Container(
              margin: const EdgeInsets.only(top: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF0B132B) : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const Text('👟', style: TextStyle(fontSize: 16)),
                  const SizedBox(width: 8),
                  Text(
                    'Bugünkü Adım: ${provider.todayHealthSteps} adım',
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: isDark ? const Color(0xFF38BDF8) : const Color(0xFF0288D1),
                    ),
                  ),
                ],
              ),
            ),
        ],

        const Divider(height: 20, thickness: 0.5),

        // 4. iOS Home Screen & Lock Screen Interactive Widgets (3 Widget Designs)
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF0B132B) : const Color(0xFFF0F9FF),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isDark ? const Color(0xFF1E3A8A) : Colors.lightBlue.shade200,
              width: 0.9,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.widgets_rounded, size: 18, color: Color(0xFF0288D1)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Ana Ekran & Kilit Ekranı Widget\'ları (3 Tasarım)',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: isDark ? const Color(0xFF38BDF8) : const Color(0xFF0369A1),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                'iOS 17+ Etkileşimli Widget (AppIntents) teknolojisiyle uygulamayı açmadan iPhone Ana Ekranından veya Kilit Ekranından tek dokunuşla su ekleyebilirsiniz:',
                style: TextStyle(
                  fontSize: 11,
                  color: isDark ? const Color(0xFF94A3B8) : Colors.grey.shade700,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 10),
              _buildCommandTile(
                '💧',
                '1. Geniş İlerleme & Hızlı Ekle (Orta - 4x2 / Küçük - 2x2)',
                'Günlük ml ilerlemesi, yüzde halkası ve uygulamayı açmadan su ekleyen 3 adet etkileşimli (+200/+330/+500 ml) buton.',
                isDark,
              ),
              const SizedBox(height: 8),
              _buildCommandTile(
                '⚡',
                '2. Hızlı Su Ekleme Barı (Ana Ekran Kompakt)',
                'Minimalist tasarım ile bardak, şişe ve matara kısayollarına anında erişim.',
                isDark,
              ),
              const SizedBox(height: 8),
              _buildCommandTile(
                '🔒',
                '3. iPhone Kilit Ekranı & StandBy Widget\'ları',
                'Kilit ekranında saatin hemen altında dairesel su halkası (Circular), detaylı su çubuğu (Rectangular) ve üst satır özeti (Inline).',
                isDark,
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _showIosWidgetGuideModal(context, isDark),
                  icon: const Icon(Icons.help_outline_rounded, size: 15),
                  label: const Text(
                    'iPhone Ana Ekran & Kilit Ekranına Nasıl Eklenir?',
                    style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF0288D1),
                    side: const BorderSide(color: Color(0xFF0288D1), width: 1),
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showIosWidgetGuideModal(BuildContext context, bool isDark) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: isDark ? const Color(0xFF1C2541) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        final bottomInset = MediaQuery.of(ctx).viewPadding.bottom;
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.fromLTRB(20, 24, 20, 24 + bottomInset),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text('📱', style: TextStyle(fontSize: 24)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'iPhone Widget Kurulum Kılavuzu',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: isDark ? const Color(0xFFF1F5F9) : Colors.blue.shade900,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  'Ana Ekrana Ekleme:',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: isDark ? const Color(0xFF38BDF8) : const Color(0xFF0288D1),
                  ),
                ),
                const SizedBox(height: 8),
                _buildStepTile('1', 'iPhone Ana Ekranında boş bir alana simgeler titreyene kadar basılı tutun.', isDark),
                const SizedBox(height: 8),
                _buildStepTile('2', 'Sol üst köşedeki "+" (Düzenle > Araç Takımı Ekle) butonuna dokunun.', isDark),
                const SizedBox(height: 8),
                _buildStepTile('3', 'Listeden "HydroSoft"u seçip Küçük veya Orta boy etkileşimli widget\'ı ekleyin.', isDark),
                const SizedBox(height: 14),
                Text(
                  'Kilit Ekranına Ekleme:',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: isDark ? const Color(0xFF38BDF8) : const Color(0xFF0288D1),
                  ),
                ),
                const SizedBox(height: 8),
                _buildStepTile('1', 'Kilit Ekranına basılı tutup alttaki "Özelleştir > Kilit Ekranı" seçeneğine dokunun.', isDark),
                const SizedBox(height: 8),
                _buildStepTile('2', 'Saatin altındaki "Araç Takımı Ekle" kutusuna dokunup "HydroSoft" su halkasını seçin.', isDark),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(ctx),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0288D1),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('Tamam', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

