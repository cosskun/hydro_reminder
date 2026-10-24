import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/water_provider.dart';
import 'settings_card_wrapper.dart';

class IosShortcutsSettingsCard extends StatelessWidget {
  const IosShortcutsSettingsCard({super.key});

  void _showSiriCommandsModal(BuildContext context, bool isDark) {
    final primary = Theme.of(context).colorScheme.primary;
    final isEn = Provider.of<WaterProvider>(context, listen: false).language == 'en';
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
                      isEn ? 'Siri Voice Commands' : 'Siri Sesli Komutları',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDark ? const Color(0xFFF1F5F9) : const Color(0xFF0F172A),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  isEn
                      ? 'Enable Siri on your iPhone and say the phrases below to log water without opening the app:'
                      : 'iPhone\'unuzda Siri\'yi etkinleştirip aşağıdaki örnek cümleleri söyleyerek uygulamayı açmadan su kaydedebilirsiniz:',
                  style: TextStyle(
                    fontSize: 12.5,
                    color: isDark ? const Color(0xFF94A3B8) : Colors.grey.shade700,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 16),
                _buildCommandTile(
                  '💧',
                  isEn ? '"Hey Siri, I drank 250 ml water with HydroSoft"' : '"Hey Siri, HydroSoft ile 250 ml su içtim"',
                  isEn ? 'Adds specified amount to your day and speaks remaining goal.' : 'Belirttiğiniz miktarı gününüze ekler ve kalan hedefi seslendirir.',
                  isDark,
                  primary,
                ),
                const SizedBox(height: 10),
                _buildCommandTile(
                  '🥛',
                  isEn ? '"Hey Siri, add a glass of water with HydroSoft"' : '"Hey Siri, HydroSoft ile bir bardak su ekle"',
                  isEn ? 'Logs default glass amount (+200 ml).' : 'Varsayılan bardak miktarını (+200 ml) kaydeder.',
                  isDark,
                  primary,
                ),
                const SizedBox(height: 10),
                _buildCommandTile(
                  '📊',
                  isEn ? '"Hey Siri, how much water did I drink today with HydroSoft?"' : '"Hey Siri, HydroSoft bugün ne kadar su içtim?"',
                  isEn ? 'Answers with your total intake today and remaining hydration need.' : 'Bugünkü toplam tüketiminizi ve kalan ihtiyacınızı sesli yanıtlar.',
                  isDark,
                  primary,
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(ctx),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text(isEn ? 'Understood' : 'Anladım', style: const TextStyle(fontWeight: FontWeight.bold)),
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
    final primary = Theme.of(context).colorScheme.primary;
    final isEn = Provider.of<WaterProvider>(context, listen: false).language == 'en';
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
                      isEn ? 'Back Tap & Action Button' : 'Arkaya Dokunma & Eylem Düğmesi',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDark ? const Color(0xFFF1F5F9) : const Color(0xFF0F172A),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  isEn
                      ? 'When you double-tap the back of your iPhone, a transparent menu pops up from top (🥛 Glass, 🥤 Small Bottle, 🫙 Bottle/Flask). Select and log water with one tap.\n\nTo set up:'
                      : 'iPhone\'unuzun arkasına 2 kez dokunduğunuzda ekranın üstünden şeffaf bir bildirim menüsü açılır (🥛 Bardak, 🥤 Küçük Şişe, 🫙 Şişe/Matara). Buradan tek tıkla içtiğiniz suyu seçip kaydedebilirsiniz.\n\nKurulum için:',
                  style: TextStyle(
                    fontSize: 12.5,
                    color: isDark ? const Color(0xFF94A3B8) : Colors.grey.shade700,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 16),
                _buildStepTile(
                  '1',
                  isEn ? 'Go to iPhone Settings > Accessibility > Touch.' : 'iPhone Ayarları > Erişilebilirlik > Dokunma menüsüne gidin.',
                  isDark,
                  primary,
                ),
                const SizedBox(height: 10),
                _buildStepTile(
                  '2',
                  isEn ? 'Scroll down to "Back Tap" and select "Double Tap".' : 'En alttaki "Arkaya Dokun" seçeneğine girip "Çift Dokunma"yı seçin.',
                  isDark,
                  primary,
                ),
                const SizedBox(height: 10),
                _buildStepTile(
                  '3',
                  isEn ? 'Under Shortcuts, assign "Quick Water Selector" (HydroSoft).' : 'Kestirmeler bölümünden "Hızlı Su Seçimi" (HydroSoft) eylemini atayın.',
                  isDark,
                  primary,
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(ctx),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text(isEn ? 'Done' : 'Tamam', style: const TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  static Widget _buildCommandTile(String emoji, String title, String subtitle, bool isDark, [Color? primaryColor]) {
    final primary = primaryColor ?? (isDark ? const Color(0xFF38BDF8) : const Color(0xFF0288D1));
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0B132B) : const Color(0xFFF4F9FD),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? const Color(0xFF3A506B) : primary.withValues(alpha: 0.2),
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
                    color: primary,
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

  static Widget _buildStepTile(String step, String text, bool isDark, [Color? color]) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 22,
          height: 22,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: color ?? (isDark ? const Color(0xFF38BDF8) : const Color(0xFF0288D1)),
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
    final isEn = Provider.of<WaterProvider>(context, listen: false).language == 'en';
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
                      isEn ? 'Apple Health (HealthKit)' : 'Apple Sağlık (HealthKit)',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDark ? const Color(0xFFF1F5F9) : const Color(0xFF0F172A),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  isEn
                      ? 'HydroSoft offers seamless two-way integration with Apple Health:'
                      : 'HydroSoft, Apple Sağlık uygulaması ile çift yönlü tam entegrasyon sunar:',
                  style: TextStyle(
                    fontSize: 12.5,
                    color: isDark ? const Color(0xFF94A3B8) : Colors.grey.shade700,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 16),
                _buildCommandTile(
                  '💧',
                  isEn ? 'Automatic Water Logging' : 'Otomatik Su Yazma',
                  isEn
                      ? 'All water entries logged via HydroSoft or Siri are immediately written to Apple Health "Nutrition > Water".'
                      : 'HydroSoft veya Siri üzerinden eklediğiniz tüm su kayıtları Apple Sağlık "Beslenme > Su" kategorisine anında yazılır.',
                  isDark,
                ),
                const SizedBox(height: 10),
                _buildCommandTile(
                  '⌚',
                  isEn ? 'Apple Watch & Activity Sync' : 'Apple Watch & Aktivite Uyumu',
                  isEn
                      ? 'Steps and active calories recorded by Apple Watch or iPhone are factored into your daily hydration balance.'
                      : 'Apple Watch veya iPhone\'unuzun kaydettiği adım ve aktif kalori verileri ile günlük su dengeniz kusursuz hesaplanır.',
                  isDark,
                ),
                const SizedBox(height: 10),
                _buildCommandTile(
                  '🔒',
                  isEn ? 'Privacy & Security' : 'Gizlilik & Güvenlik',
                  isEn
                      ? 'Your health data stays strictly on your device and is never shared with third parties.'
                      : 'Sağlık verileriniz sadece cihazınızda kalır ve asla üçüncü şahıslarla paylaşılmaz.',
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
                    child: Text(isEn ? 'Understood' : 'Anladım', style: const TextStyle(fontWeight: FontWeight.bold)),
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
    final primary = theme.colorScheme.primary;
    final isEn = provider.language == 'en';

    return SettingsCardWrapper(
      title: isEn ? 'iOS & Apple Features 🍏' : 'iOS & Apple Özellikleri 🍏',
      titleTrailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: primary.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          isEn ? 'iPhone Only' : 'iPhone Özel',
          style: TextStyle(
            fontSize: 10.5,
            fontWeight: FontWeight.bold,
            color: primary,
          ),
        ),
      ),
      children: [
        Text(
          isEn
              ? 'Effortlessly track water hands-free using your iPhone\'s advanced hardware, voice assistant, and Apple Health features.'
              : 'iPhone\'unuzun gelişmiş donanım, sesli asistan ve Apple Sağlık özellikleriyle ellerinizi kullanmadan hızlı ve akıllı su takibi yapın.',
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
                        isEn ? 'Siri Voice Commands' : 'Siri ile Sesli Komut',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isDark ? const Color(0xFFF1F5F9) : const Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        isEn
                            ? 'Add water hands-free by saying "Hey Siri, I drank 250 ml water".'
                            : '"Hey Siri, 250 ml su içtim" diyerek eller serbest su ekleyin.',
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
                  activeThumbColor: Theme.of(context).colorScheme.primary,
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
                label: Text(
                  isEn ? 'View Voice Commands & Phrases' : 'Sesli Komutları & Cümleleri Gör',
                  style: const TextStyle(fontSize: 11.5),
                ),
                style: TextButton.styleFrom(
                  foregroundColor: primary,
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
                        isEn ? 'Back Tap & Action Button' : 'Arkaya Dokunma & Eylem Düğmesi',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isDark ? const Color(0xFFF1F5F9) : const Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        isEn
                            ? 'Open quick water menu by double-tapping the back of your phone or pressing the Action Button.'
                            : 'Telefonun arkasına çift vurarak veya Eylem Düğmesine basarak hızlı su menüsünü açın.',
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
                  activeThumbColor: Theme.of(context).colorScheme.primary,
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
                label: Text(
                  isEn ? 'Back Tap Setup Guide' : 'Arkaya Dokunma Kurulum Kılavuzu',
                  style: const TextStyle(fontSize: 11.5),
                ),
                style: TextButton.styleFrom(
                  foregroundColor: primary,
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
                SnackBar(
                  content: Text(
                    isEn
                        ? 'Apple Health access permission was not granted or was cancelled.'
                        : 'Apple Sağlık erişim izni verilmedi veya iptal edildi.',
                  ),
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
                                color: isDark ? const Color(0xFFF1F5F9) : const Color(0xFF0F172A),
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Icon(Icons.favorite_rounded, size: 15, color: Color(0xFFE11D48)),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        isEn
                            ? 'Automatically sync your water intake to Apple Health app (Dietary Water).'
                            : 'İçtiğiniz suları Apple Sağlık uygulamasına (Dietary Water) otomatik senkronize edin.',
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
                        SnackBar(
                          content: Text(
                            isEn
                                ? 'Apple Health access permission was not granted or was cancelled.'
                                : 'Apple Sağlık erişim izni verilmedi veya iptal edildi.',
                          ),
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
                    label: Text(
                      isEn ? 'Health Info' : 'Sağlık Bilgisi',
                      style: const TextStyle(fontSize: 11.5),
                    ),
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
                          content: Text(
                            isEn
                                ? '$synced water entries synced with Apple Health.'
                                : '$synced adet su kaydı Apple Sağlık ile senkronize edildi.',
                          ),
                          backgroundColor: const Color(0xFF10B981),
                        ),
                      );
                    }
                  },
                  icon: const Icon(Icons.sync_rounded, size: 14),
                  label: Text(
                    isEn ? 'Sync Today' : 'Bugünü Senkronize Et',
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                  ),
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
                    isEn
                        ? 'Today\'s Steps: ${provider.todayHealthSteps} steps'
                        : 'Bugünkü Adım: ${provider.todayHealthSteps} adım',
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: primary,
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
              color: isDark ? const Color(0xFF1E3A8A) : primary.withValues(alpha: 0.25),
              width: 0.9,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.widgets_rounded, size: 18, color: primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      isEn
                          ? 'Home & Lock Screen Widgets (3 Designs)'
                          : 'Ana Ekran & Kilit Ekranı Widget\'ları (3 Tasarım)',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: primary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                isEn
                    ? 'With iOS 17+ Interactive Widgets (AppIntents), log water directly from iPhone Home Screen or Lock Screen with one tap:'
                    : 'iOS 17+ Etkileşimli Widget (AppIntents) teknolojisiyle uygulamayı açmadan iPhone Ana Ekranından veya Kilit Ekranından tek dokunuşla su ekleyebilirsiniz:',
                style: TextStyle(
                  fontSize: 11,
                  color: isDark ? const Color(0xFF94A3B8) : Colors.grey.shade700,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 10),
              _buildCommandTile(
                '💧',
                isEn
                    ? '1. Large Progress & Quick Add (Medium - 4x2 / Small - 2x2)'
                    : '1. Geniş İlerleme & Hızlı Ekle (Orta - 4x2 / Küçük - 2x2)',
                isEn
                    ? 'Daily ml progress, percentage ring, and 3 interactive buttons (+200/+330/+500 ml) without opening app.'
                    : 'Günlük ml ilerlemesi, yüzde halkası ve uygulamayı açmadan su ekleyen 3 adet etkileşimli (+200/+330/+500 ml) buton.',
                isDark,
              ),
              const SizedBox(height: 8),
              _buildCommandTile(
                '⚡',
                isEn
                    ? '2. Quick Water Bar (Home Screen Compact)'
                    : '2. Hızlı Su Ekleme Barı (Ana Ekran Kompakt)',
                isEn
                    ? 'Minimalist design for instant access to glass, bottle, and flask shortcuts.'
                    : 'Minimalist tasarım ile bardak, şişe ve matara kısayollarına anında erişim.',
                isDark,
              ),
              const SizedBox(height: 8),
              _buildCommandTile(
                '🔒',
                isEn
                    ? '3. iPhone Lock Screen & StandBy Widgets'
                    : '3. iPhone Kilit Ekranı & StandBy Widget\'ları',
                isEn
                    ? 'Circular water ring below clock, detailed rectangular progress bar, and inline top summary on lock screen.'
                    : 'Kilit ekranında saatin hemen altında dairesel su halkası (Circular), detaylı su çubuğu (Rectangular) ve üst satır özeti (Inline).',
                isDark,
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _showIosWidgetGuideModal(context, isDark),
                  icon: const Icon(Icons.help_outline_rounded, size: 15),
                  label: Text(
                    isEn
                        ? 'How to Add to iPhone Home & Lock Screen?'
                        : 'iPhone Ana Ekran & Kilit Ekranına Nasıl Eklenir?',
                    style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: primary,
                    side: BorderSide(color: primary, width: 1),
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
    final primary = Theme.of(context).colorScheme.primary;
    final isEn = Provider.of<WaterProvider>(context, listen: false).language == 'en';
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
                        isEn ? 'iPhone Widget Setup Guide' : 'iPhone Widget Kurulum Kılavuzu',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: isDark ? const Color(0xFFF1F5F9) : const Color(0xFF0F172A),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  isEn ? 'Adding to Home Screen:' : 'Ana Ekrana Ekleme:',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: primary,
                  ),
                ),
                const SizedBox(height: 8),
                _buildStepTile(
                  '1',
                  isEn
                      ? 'Touch and hold an empty area on your iPhone Home Screen until icons jiggle.'
                      : 'iPhone Ana Ekranında boş bir alana simgeler titreyene kadar basılı tutun.',
                  isDark,
                  primary,
                ),
                const SizedBox(height: 8),
                _buildStepTile(
                  '2',
                  isEn
                      ? 'Tap the "+" button in top left (Edit > Add Widget).'
                      : 'Sol üst köşedeki "+" (Düzenle > Araç Takımı Ekle) butonuna dokunun.',
                  isDark,
                  primary,
                ),
                const SizedBox(height: 8),
                _buildStepTile(
                  '3',
                  isEn
                      ? 'Select "HydroSoft" from the list and add Small or Medium interactive widget.'
                      : 'Listeden "HydroSoft"u seçip Küçük veya Orta boy etkileşimli widget\'ı ekleyin.',
                  isDark,
                  primary,
                ),
                const SizedBox(height: 14),
                Text(
                  isEn ? 'Adding to Lock Screen:' : 'Kilit Ekranına Ekleme:',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: primary,
                  ),
                ),
                const SizedBox(height: 8),
                _buildStepTile(
                  '1',
                  isEn
                      ? 'Touch and hold Lock Screen, then tap "Customize > Lock Screen" below.'
                      : 'Kilit Ekranına basılı tutup alttaki "Özelleştir > Kilit Ekranı" seçeneğine dokunun.',
                  isDark,
                  primary,
                ),
                const SizedBox(height: 8),
                _buildStepTile(
                  '2',
                  isEn
                      ? 'Tap "Add Widgets" box under the clock and select HydroSoft water ring.'
                      : 'Saatin altındaki "Araç Takımı Ekle" kutusuna dokunup "HydroSoft" su halkasını seçin.',
                  isDark,
                  primary,
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(ctx),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text(isEn ? 'Done' : 'Tamam', style: const TextStyle(fontWeight: FontWeight.bold)),
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

