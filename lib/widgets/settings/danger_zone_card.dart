import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/water_provider.dart';
import 'settings_card_wrapper.dart';

class DangerZoneCard extends StatelessWidget {
  final VoidCallback onReset;

  const DangerZoneCard({
    super.key,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isEn = Provider.of<WaterProvider>(context).language == 'en';

    return SettingsCardWrapper(
      title: isEn ? 'Reset' : 'Sıfırlama',
      isDangerZone: true,
      children: [
        Text(
          isEn
              ? 'Permanently delete all records and settings in the app and return to the fresh setup page.'
              : 'Uygulamadaki tüm kayıtları ve ayarları kalıcı olarak silip temiz kurulum sayfasına geri dönebilirsiniz.',
          style: TextStyle(
            fontSize: 11,
            color: isDark ? const Color(0xFFFCA5A5) : Colors.grey,
          ),
        ),
        const SizedBox(height: 16),
        OutlinedButton(
          onPressed: onReset,
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.red.shade400,
            side: BorderSide(
              color: isDark ? Colors.red.shade700 : Colors.red.shade300,
            ),
            minimumSize: const Size(double.infinity, 44),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(
            isEn ? 'Reset All Data' : 'Tüm Verileri Sıfırla',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          ),
        ),
      ],
    );
  }
}
