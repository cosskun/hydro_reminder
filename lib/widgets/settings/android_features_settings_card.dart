import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_routes.dart';
import '../../providers/water_provider.dart';
import '../../services/widget_service.dart';
import 'settings_card_wrapper.dart';

class AndroidFeaturesSettingsCard extends StatelessWidget {
  const AndroidFeaturesSettingsCard({super.key});

  static Future<void> _handleAutoAddTile(BuildContext context, bool isDark, int presetAmount) async {
    final res = await WidgetService().requestAddQuickTile();
    if (!context.mounted) return;

    final supported = res['supported'] == true;
    final success = res['success'] == true;
    final alreadyAdded = res['alreadyAdded'] == true;

    if (alreadyAdded) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('⚡ "HydroSoft Su Ekle" kutucuğu zaten bildirim panelinizde ekli!'),
          backgroundColor: Color(0xFF10B981),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('🎉 +$presetAmount ml Su Ekleme kutucuğu Hızlı Ayarlar paneline başarıyla eklendi!'),
          backgroundColor: const Color(0xFF10B981),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else if (!supported) {
      final p1Meta = WaterProvider.getPresetMeta(presetAmount);
      final p1Emoji = p1Meta['emoji'] ?? '💧';
      _showTileSetupModal(context, isDark, presetAmount, p1Emoji);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Hızlı Ayarlar kutucuğu ekleme işlemi iptal edildi.'),
          backgroundColor: Colors.blueGrey,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  static void _showTileSetupModal(BuildContext context, bool isDark, int presetAmount, String presetEmoji) {
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
                    const Text('⚡', style: TextStyle(fontSize: 24)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Hızlı Ayarlar Kutucuğu Kurulumu',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isDark ? const Color(0xFFF1F5F9) : Colors.blue.shade900,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  'Bildirim panelinizi aşağı çektiğinizde Wi-Fi ve Fener butonlarının yanına "$presetEmoji +$presetAmount ml Su Ekle" kutucuğunu ekleyin:',
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(ctx);
                      _handleAutoAddTile(context, isDark, presetAmount);
                    },
                    icon: const Icon(Icons.flash_on_rounded, size: 17),
                    label: const Text(
                      '⚡ Tek Dokunuşla Otomatik Ekle (Önerilen)',
                      style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10B981),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 11),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Veya Elle Eklemek İçin Adımlar:',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: isDark ? const Color(0xFFE2E8F0) : const Color(0xFF334155),
                  ),
                ),
                const SizedBox(height: 16),
                _buildStepTile('1', 'Bildirim çubuğunu en yukarıdan iki kez aşağı kaydırın.', isDark),
                const SizedBox(height: 10),
                _buildStepTile('2', 'Sağ üstteki "Düzenle" (Kalem ✏️) simgesine dokunun. Samsung Galaxy cihazlarda "Tam" panelini veya "Kontrol Ekle / Düğmeleri Düzenle" (+) butonuna dokunun.', isDark),
                const SizedBox(height: 10),
                _buildStepTile('3', 'Eklenebilir butonlar arasından "$presetEmoji HydroSoft Su Ekle" kutucuğunu bulun.', isDark),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF451A03) : const Color(0xFFFEF3C7),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isDark ? const Color(0xFF78350F) : const Color(0xFFFDE68A),
                      width: 0.8,
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('⚠️', style: TextStyle(fontSize: 14)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Önemli (Samsung): Kutucuğa tek dokunursanız (tıklarsanız) Android uygulamayı açar ve panel kapanır! Tıklamak yerine kutucuğa parmağınızı BASILI TUTUN.',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: isDark ? const Color(0xFFFDE68A) : const Color(0xFF92400E),
                            height: 1.35,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                _buildStepTile('4', 'Kutucuğu BASILI TUTARAK yukarıya aktif kutucukların arasına sürükleyip bırakın ve "Bitti"ye dokunun.', isDark),
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
                    child: const Text('Anladım, Harika!', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showHealthConnectModal(BuildContext context, bool isDark) {
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
                    const Text('💚', style: TextStyle(fontSize: 24)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Google Health Connect',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isDark ? const Color(0xFFF1F5F9) : Colors.blue.shade900,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  'Health Connect sayesinde HydroSoft tüm Android sağlık ekosisteminizle çift yönlü konuşur:',
                  style: TextStyle(
                    fontSize: 12.5,
                    color: isDark ? const Color(0xFF94A3B8) : Colors.grey.shade700,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 16),
                _buildFeatureRow(
                  '💧',
                  'Su Tüketimini Eşitleme',
                  'Eklediğiniz tüm sular Google Health Connect üzerinden Samsung Health, Google Fit ve MyFitnessPal ile paylaşılır.',
                  isDark,
                ),
                const SizedBox(height: 10),
                _buildFeatureRow(
                  '⌚',
                  'Akıllı Saat & Bileklik Uyumu',
                  'Galaxy Watch, Xiaomi Mi Fitness, Huawei Health veya Fitbit adımlarınız otomatik okunur ve hidrasyon ihtiyacınız dengelenir.',
                  isDark,
                ),
                const SizedBox(height: 10),
                _buildFeatureRow(
                  '🔒',
                  'Uçtan Uca Gizlilik',
                  'Verileriniz Google Health Connect güvenlik standartlarıyla korunur ve sadece cihazınızda işlenir.',
                  isDark,
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(ctx),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10B981),
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

  static Widget _buildFeatureRow(String emoji, String title, String subtitle, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0B132B) : const Color(0xFFF0FDF4),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? const Color(0xFF3A506B) : const Color(0xFFBBF7D0),
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
                    color: isDark ? const Color(0xFF34D399) : const Color(0xFF047857),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? const Color(0xFF94A3B8) : Colors.grey.shade700,
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

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<WaterProvider>(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final p1Meta = WaterProvider.getPresetMeta(provider.preset1);
    final p1Emoji = p1Meta['emoji'] ?? '💧';

    return SettingsCardWrapper(
      title: 'Android Hızlı Kontroller 🤖',
      titleTrailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: const Color(0xFF10B981).withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Text(
          'Android Özel',
          style: TextStyle(
            fontSize: 10.5,
            fontWeight: FontWeight.bold,
            color: Color(0xFF10B981),
          ),
        ),
      ),
      children: [
        Text(
          'Android bildirim panelinizden, Hızlı Ayarlar menüsünden ve Health Connect servisinden en yüksek verimi alın.',
          style: TextStyle(
            fontSize: 11.5,
            color: isDark ? const Color(0xFF94A3B8) : Colors.grey.shade600,
            height: 1.3,
          ),
        ),
        const SizedBox(height: 16),

        // 1. Quick Settings Tile Banner
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF0B132B) : const Color(0xFFF0FDF4),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isDark ? const Color(0xFF3A506B) : const Color(0xFFBBF7D0),
              width: 0.8,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.tune_rounded,
                      color: Color(0xFF10B981),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '⚡ Hızlı Ayarlar Kutucuğu',
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.bold,
                            color: isDark ? const Color(0xFFF1F5F9) : const Color(0xFF065F46),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Bildirim çubuğunda "$p1Emoji +${provider.preset1} ml Su Ekle" kutucuğu hazır.',
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
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _handleAutoAddTile(context, isDark, provider.preset1),
                  icon: const Icon(Icons.flash_on_rounded, size: 16),
                  label: const Text(
                    '⚡ Hızlı Ayarlara Otomatik Ekle (1 Dokunuş)',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _showTileSetupModal(context, isDark, provider.preset1, p1Emoji),
                  icon: const Icon(Icons.help_outline_rounded, size: 15),
                  label: const Text('Nasıl Eklenir? (Adım Adım Kılavuz)', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF10B981),
                    side: const BorderSide(color: Color(0xFF10B981), width: 0.8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 14),
        const Divider(height: 20, thickness: 0.5),

        // 2. App Shortcuts (Long Press on App Icon)
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF0B132B) : const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isDark ? const Color(0xFF3A506B) : Colors.grey.shade300,
              width: 0.8,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0288D1).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.app_shortcut_rounded,
                      color: Color(0xFF0288D1),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'İkona Basılı Tutma Kısayolları',
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.bold,
                            color: isDark ? const Color(0xFFF1F5F9) : const Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Telefonunuzun ana ekranında HydroSoft uygulama simgesine parmağınızı basılı tuttuğunuzda açılan hazır kısayollar:',
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark ? const Color(0xFF94A3B8) : Colors.grey.shade600,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _buildShortcutChip(
                          context,
                          emoji: '🥛',
                          label: '+200 ml Bardak',
                          isDark: isDark,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildShortcutChip(
                          context,
                          emoji: '🥤',
                          label: '+330 ml Şişe',
                          isDark: isDark,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: _buildShortcutChip(
                          context,
                          emoji: '🫙',
                          label: '+500 ml Büyük',
                          isDark: isDark,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildShortcutChip(
                          context,
                          emoji: '📊',
                          label: 'İstatistikler',
                          isDark: isDark,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline_rounded, size: 14, color: Color(0xFF0288D1)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '💡 Bilgi: Bu kısayollar telefonunuzun ana ekranında çalışır. Ana ekranda HydroSoft simgesine 1 saniye basılı tuttuğunuzda açılan menüden doğrudan işlem yapabilirsiniz.',
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark ? const Color(0xFF94A3B8) : Colors.grey.shade700,
                          height: 1.35,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const Divider(height: 20, thickness: 0.5),

        // 3. Home Screen & Lock Screen Widgets (3 Designs + 1-Click Pin)
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF0B132B) : const Color(0xFFF0F9FF),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isDark ? const Color(0xFF3A506B) : Colors.blue.shade100,
              width: 0.8,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0288D1).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.widgets_rounded,
                      color: Color(0xFF0288D1),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '📱 Ana Ekran & Kilit Ekranı Widget\'ları',
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.bold,
                            color: isDark ? const Color(0xFFF1F5F9) : const Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '3 farklı boyuttaki widget\'ı tek tıkla ana ekranınıza sabitleyin veya ana ekrana basılı tutup Widget\'lar menüsünden ekleyin.',
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
              const SizedBox(height: 12),
              _buildWidgetPinRow(
                context,
                emoji: '💧',
                title: 'Geniş İlerleme & Hızlı Ekle (4x2)',
                subtitle: 'Günlük doluluk çubuğu + 3 hızlı su ekleme butonu',
                providerName: WidgetService.androidProgressWidget,
                isDark: isDark,
              ),
              const SizedBox(height: 8),
              _buildWidgetPinRow(
                context,
                emoji: '⚡',
                title: 'Hızlı Su Ekleme Çubuğu (4x1)',
                subtitle: 'Kompakt yatay bar ve tek tıkla su ekleme',
                providerName: WidgetService.androidQuickLogWidget,
                isDark: isDark,
              ),
              const SizedBox(height: 8),
              _buildWidgetPinRow(
                context,
                emoji: '🎯',
                title: 'Mini Su Yüzdesi (2x2)',
                subtitle: 'Kare mini yüzde ve kalan su göstergesi',
                providerName: WidgetService.androidMiniWidget,
                isDark: isDark,
              ),
            ],
          ),
        ),

        const Divider(height: 20, thickness: 0.5),

        // 4. Google Health Connect Switch
        InkWell(
          onTap: () async {
            final newVal = !provider.isAppleHealthSyncEnabled;
            final success = await provider.updateAppleHealthSettings(isEnabled: newVal);
            if (!success && newVal && context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Health Connect izni verilmedi veya iptal edildi.'),
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
                              'Google Health Connect',
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
                          const Icon(Icons.favorite_rounded, size: 15, color: Color(0xFF10B981)),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'İçilen suları ve akıllı saat adımlarını Health Connect ile eşitleyin.',
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
                  activeThumbColor: const Color(0xFF10B981),
                  onChanged: (val) async {
                    final success = await provider.updateAppleHealthSettings(isEnabled: val);
                    if (!success && val && context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Health Connect izni verilmedi veya iptal edildi.'),
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
                    onPressed: () => _showHealthConnectModal(context, isDark),
                    icon: const Icon(Icons.info_outline_rounded, size: 16),
                    label: const Text('Sağlık Bilgisi', style: TextStyle(fontSize: 11.5)),
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFF10B981),
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
                          content: Text('$synced adet su kaydı Health Connect ile senkronize edildi.'),
                          backgroundColor: const Color(0xFF10B981),
                        ),
                      );
                    }
                  },
                  icon: const Icon(Icons.sync_rounded, size: 14),
                  label: const Text('Bugünü Senkronize Et', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDark ? const Color(0xFF064E3B) : const Color(0xFFD1FAE5),
                    foregroundColor: isDark ? Colors.white : const Color(0xFF047857),
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
                    'Bugünkü Adım: ${provider.todayHealthSteps} adım (Health Connect)',
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: isDark ? const Color(0xFF34D399) : const Color(0xFF059669),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ],
    );
  }

  static Widget _buildShortcutChip(
    BuildContext context, {
    required String emoji,
    required String label,
    required bool isDark,
  }) {
    return Material(
      color: isDark ? const Color(0xFF1E293B) : Colors.white,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '💡 "$label" kısayolunu kullanmak için telefonunuzun ana ekranında HydroSoft simgesine parmağınızı basılı tutun.',
              ),
              backgroundColor: const Color(0xFF0288D1),
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 3),
            ),
          );
        },
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 11),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isDark ? const Color(0xFF38BDF8).withValues(alpha: 0.4) : Colors.blue.shade200,
              width: 0.9,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(emoji, style: const TextStyle(fontSize: 14)),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: isDark ? const Color(0xFFE2E8F0) : const Color(0xFF0288D1),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _buildWidgetPinRow(
    BuildContext context, {
    required String emoji,
    required String title,
    required String subtitle,
    required String providerName,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : Colors.grey.shade200,
          width: 0.7,
        ),
      ),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: isDark ? const Color(0xFFF1F5F9) : const Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 10.5,
                    color: isDark ? const Color(0xFF94A3B8) : Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          ElevatedButton.icon(
            onPressed: () async {
              final pinned = await WidgetService().pinAndroidWidget(providerName);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      pinned
                          ? '📌 "$title" için ana ekrana ekleme penceresi açıldı!'
                          : 'Telefonunuzun ana ekranında boş bir yere basılı tutup "Widget\'lar > HydroSoft" menüsünden ekleyebilirsiniz.',
                    ),
                    backgroundColor: pinned ? const Color(0xFF10B981) : const Color(0xFF0288D1),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            icon: const Icon(Icons.add_to_home_screen_rounded, size: 13),
            label: const Text('Ekle', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF10B981),
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ],
      ),
    );
  }
}

