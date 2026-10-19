import 'package:flutter/material.dart';
import 'settings_card_wrapper.dart';

class LegalPrivacySettingsCard extends StatelessWidget {
  const LegalPrivacySettingsCard({super.key});

  void _showLegalModal(
    BuildContext context, {
    required bool isDark,
    required String emoji,
    required String title,
    required List<Map<String, String>> sections,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? const Color(0xFF1C2541) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: DraggableScrollableSheet(
            expand: false,
            initialChildSize: 0.72,
            minChildSize: 0.45,
            maxChildSize: 0.92,
            builder: (_, scrollController) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 48,
                        height: 5,
                        decoration: BoxDecoration(
                          color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Text(emoji, style: const TextStyle(fontSize: 24)),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            title,
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
                    Expanded(
                      child: ListView.separated(
                        controller: scrollController,
                        itemCount: sections.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (_, idx) {
                          final item = sections[idx];
                          return Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF0B132B) : const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: isDark ? const Color(0xFF3A506B) : Colors.blue.shade100,
                                width: 0.8,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item['heading'] ?? '',
                                  style: TextStyle(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.bold,
                                    color: isDark ? const Color(0xFF38BDF8) : const Color(0xFF0288D1),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  item['body'] ?? '',
                                  style: TextStyle(
                                    fontSize: 12,
                                    height: 1.45,
                                    color: isDark ? const Color(0xFFCBD5E1) : Colors.grey.shade800,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 14),
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
                        child: const Text(
                          'Okudum, Anladım',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SettingsCardWrapper(
      title: 'Yasal Bilgiler, KVKK ve Gizlilik 🔒',
      titleTrailing: const Icon(Icons.verified_user_outlined, color: Color(0xFF38BDF8)),
      children: [
        Text(
          'HydroSoft verilerinizi hiçbir dış sunucuya aktarmaz; tüm bilgileriniz %100 cihazınızda saklanır.',
          style: TextStyle(
            fontSize: 11.5,
            color: isDark ? const Color(0xFF94A3B8) : Colors.grey.shade600,
            height: 1.35,
          ),
        ),
        const SizedBox(height: 14),
        _buildLegalTile(
          context,
          isDark: isDark,
          icon: Icons.privacy_tip_outlined,
          title: 'Gizlilik Politikası & KVKK Aydınlatma Metni',
          subtitle: 'Veri işleme, yerel depolama, sağlık izinleri ve silme haklarınız.',
          onTap: () => _showLegalModal(
            context,
            isDark: isDark,
            emoji: '🔒',
            title: 'Gizlilik Politikası & KVKK',
            sections: const [
              {
                'heading': '1. %100 Cihaz İçi Veri Saklama (Sunucusuz Mimari)',
                'body':
                    'HydroSoft uygulamasında girdiğiniz yaş, kilo, cinsiyet, günlük su hedefleri ve içecek kayıtları yalnızca kendi telefonunuzun güvenli yerel hafızasında saklanır. Hiçbir kişisel veriniz uzak sunuculara gönderilmez, satılmaz veya üçüncü taraflarla paylaşılmaz.',
              },
              {
                'heading': '2. Bildirim ve Alarm İzinleri',
                'body':
                    'Bildirim izni yalnızca belirlediğiniz saatlerde su içme hatırlatıcısı, canlı ilerleme çubuğu ve gün sonu özeti göstermek için kullanılır. Bildirim iznini reddetmeniz veya kapatmanız halinde uygulama içi bildirim anahtarları otomatik olarak kapanır ve hiçbir bildirim gönderilmez.',
              },
              {
                'heading': '3. Apple Sağlık (HealthKit) & Google Health Connect',
                'body':
                    'Sağlık senkronizasyonu varsayılan olarak kapalıdır. Yalnızca siz Ayarlar ekranından açıkça izin verdiğinizde içtiğiniz su miktarı (Dietary Water / Hydration) sağlık uygulamasına yazılır ve günlük adım sayınız okunur. Bu veriler reklam veya veri madenciliği amacıyla asla kullanılmaz.',
              },
              {
                'heading': '4. KVKK Kapsamında Unutulma ve Veri Silme Hakkı',
                'body':
                    'Ayarlar > Tehlikeli Bölge altındaki "Tüm Verileri Sıfırla" butonunu kullanarak veya uygulamayı cihazınızdan kaldırarak tüm geçmiş kayıtlarınızı kalıcı ve geri döndürülemez biçimde silebilirsiniz.',
              },
            ],
          ),
        ),
        const Divider(height: 16, thickness: 0.5),
        _buildLegalTile(
          context,
          isDark: isDark,
          icon: Icons.medical_information_outlined,
          title: 'Tıbbi Sorumluluk Reddi & Bilimsel Kaynaklar',
          subtitle: 'Hidrasyon hesaplama formülü ve sağlık uyarısı (Medical Disclaimer).',
          onTap: () => _showLegalModal(
            context,
            isDark: isDark,
            emoji: '⚕️',
            title: 'Tıbbi Sorumluluk Reddi',
            sections: const [
              {
                'heading': '1. Tıbbi Tavsiye Değildir (Medical Disclaimer)',
                'body':
                    'HydroSoft yalnızca genel sağlıklı yaşam alışkanlığı kazandırma ve su içmeyi hatırlatma amacıyla geliştirilmiştir. Uygulama içerisindeki hiçbir hesaplama, bildirim veya ipucu tıbbi teşhis, tedavi veya hekim tavsiyesi yerine geçmez.',
              },
              {
                'heading': '2. Özel Sağlık Durumları',
                'body':
                    'Böbrek yetmezliği, kalp rahatsızlığı, gebelik, emzirme veya doktor tarafından sıvı kısıtlaması/artırımı önerilen özel bir tıbbi durumunuz varsa, uygulamanın önerdiği hedefler yerine mutlaka uzman doktorunuzun belirttiği günlük sıvı miktarını esas alınız.',
              },
              {
                'heading': '3. Bilimsel Referanslar (EFSA & WHO)',
                'body':
                    'Uygulamadaki otomatik günlük su hedefi hesaplaması; Avrupa Gıda Güvenliği Otoritesi (EFSA - European Food Safety Authority) ve Dünya Sağlık Örgütü (WHO) yetişkin referans hidrasyon kılavuzlarındaki vücut ağırlığı başına ortalama 31–35 ml/kg standart formülüne dayanmaktadır.',
              },
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLegalTile(
    BuildContext context, {
    required bool isDark,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF0288D1).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: const Color(0xFF0288D1), size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                      color: isDark ? const Color(0xFFF1F5F9) : Colors.blue.shade900,
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
            Icon(
              Icons.chevron_right_rounded,
              color: isDark ? Colors.grey.shade500 : Colors.grey.shade400,
            ),
          ],
        ),
      ),
    );
  }
}
