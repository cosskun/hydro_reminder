import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/water_provider.dart';
import 'settings_card_wrapper.dart';

class AppearanceSettingsCard extends StatelessWidget {
  const AppearanceSettingsCard({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<WaterProvider>(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SettingsCardWrapper(
      title: 'Görünüm & Efektler 🎨',
      titleTrailing: Icon(
        isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
        color: const Color(0xFF38BDF8),
      ),
      children: [
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(
            'Gece Mavisi Karanlık Tema',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isDark ? const Color(0xFFF1F5F9) : Colors.blue.shade900,
            ),
          ),
          subtitle: Text(
            'Gözü yormayan derin lacivert ve gece mavisi arayüz.',
            style: TextStyle(
              fontSize: 11,
              color: isDark ? const Color(0xFF94A3B8) : Colors.grey,
            ),
          ),
          value: provider.isDarkMode,
          activeThumbColor: const Color(0xFF38BDF8),
          onChanged: (val) {
            provider.updateThemeMode(val ? ThemeMode.dark : ThemeMode.light);
          },
        ),
        const Divider(height: 16, thickness: 0.5),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(
            'Su Ekleme Ses & Titreşim Efektleri',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isDark ? const Color(0xFFF1F5F9) : Colors.blue.shade900,
            ),
          ),
          subtitle: Text(
            'Su eklerken yudumlama sesi ve rozet kazanınca kutlama melodisi çalar.',
            style: TextStyle(
              fontSize: 11,
              color: isDark ? const Color(0xFF94A3B8) : Colors.grey,
            ),
          ),
          value: provider.isSoundEffectsEnabled,
          activeThumbColor: const Color(0xFF38BDF8),
          onChanged: (val) {
            provider.updateSoundEffectsEnabled(val);
          },
        ),
      ],
    );
  }
}
