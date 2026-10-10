import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/water_provider.dart';
import 'settings_card_wrapper.dart';

class AndroidFeaturesSettingsCard extends StatelessWidget {
  const AndroidFeaturesSettingsCard({super.key});

  void _showTileSetupModal(BuildContext context, bool isDark) {
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? const Color(0xFF1C2541) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text('⚡', style: TextStyle(fontSize: 24)),
                    const SizedBox(width: 8),
                    Text(
                      'Hızlı Ayarlar Kutucuğu Kurulumu',
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
                  'Bildirim panelinizi aşağı çektiğinizde Wi-Fi ve Fener butonlarının yanına HydroSoft kutucuğunu eklemek için şu adımları izleyin:',
                  style: TextStyle(
                    fontSize: 12.5,
                    color: isDark ? const Color(0xFF94A3B8) : Colors.grey.shade700,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 16),
                _buildStepTile('1', 'Bildirim çubuğunu en yukarıdan iki kez aşağı kaydırın.', isDark),
                const SizedBox(height: 10),
                _buildStepTile('2', 'Sağ alttaki veya üstteki "Düzenle" (Kalem ✏️) simgesine dokunun.', isDark),
                const SizedBox(height: 10),
                _buildStepTile('3', 'Aşağıdaki kullanılabilir butonlardan "💧 +250 ml Su Ekle" kutucuğunu bulun.', isDark),
                const SizedBox(height: 10),
                _buildStepTile('4', 'Kutucuğu basılı tutarak yukarıya aktif kutucukların arasına sürükleyin.', isDark),
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
      backgroundColor: isDark ? const Color(0xFF1C2541) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text('💚', style: TextStyle(fontSize: 24)),
                    const SizedBox(width: 8),
                    Text(
                      'Google Health Connect',
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
                          'Bildirim çubuğunda "💧 +250 ml Su Ekle" kutucuğu hazır.',
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
                child: OutlinedButton.icon(
                  onPressed: () => _showTileSetupModal(context, isDark),
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
                      Icons.touch_app_rounded,
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
                          '🔘 İkona Basılı Tutma Kısayolları',
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.bold,
                            color: isDark ? const Color(0xFFF1F5F9) : const Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Ana ekranda HydroSoft ikonuna uzun basarak anında erişin.',
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
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildShortcutChip('🥛', '+200 ml Bardak', isDark),
                  _buildShortcutChip('🥤', '+330 ml Şişe', isDark),
                  _buildShortcutChip('🌊', '+500 ml Büyük', isDark),
                  _buildShortcutChip('📊', 'İstatistikler', isDark),
                ],
              ),
            ],
          ),
        ),

        const Divider(height: 20, thickness: 0.5),

        // 3. Google Health Connect Switch
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Row(
            children: [
              Text(
                'Google Health Connect',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isDark ? const Color(0xFFF1F5F9) : Colors.blue.shade900,
                ),
              ),
              const SizedBox(width: 6),
              const Icon(Icons.favorite_rounded, size: 15, color: Color(0xFF10B981)),
            ],
          ),
          subtitle: Text(
            'İçilen suları ve akıllı saat adımlarını Health Connect ile eşitleyin.',
            style: TextStyle(
              fontSize: 11,
              color: isDark ? const Color(0xFF94A3B8) : Colors.grey,
            ),
          ),
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
                      visualDensity: VisualDensity.compact,
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

  static Widget _buildShortcutChip(String emoji, String label, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : Colors.grey.shade300,
          width: 0.6,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 13)),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: isDark ? const Color(0xFFE2E8F0) : const Color(0xFF334155),
            ),
          ),
        ],
      ),
    );
  }
}
