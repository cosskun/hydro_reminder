import 'package:flutter/material.dart';
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

    return SettingsCardWrapper(
      title: 'Sıfırlama',
      isDangerZone: true,
      children: [
        Text(
          'Uygulamadaki tüm kayıtları ve ayarları kalıcı olarak silip temiz kurulum sayfasına geri dönebilirsiniz.',
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
          child: const Text(
            'Tüm Verileri Sıfırla',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          ),
        ),
      ],
    );
  }
}
