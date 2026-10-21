import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_translations.dart';
import '../../models/mascot_model.dart';
import '../../providers/water_provider.dart';
import '../dialogs/mascot_preview_dialog.dart';
import 'settings_card_wrapper.dart';

class AppearanceSettingsCard extends StatelessWidget {
  const AppearanceSettingsCard({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<WaterProvider>(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final lang = provider.language;

    return SettingsCardWrapper(
      title: lang == 'en' ? 'Appearance & Effects 🎨' : 'Görünüm & Efektler 🎨',
      titleTrailing: Icon(
        isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
        color: const Color(0xFF38BDF8),
      ),
      children: [
        // 1. Language Switcher (Uygulama Dili)
        Text(
          AppTranslations.get('section_language', lang: lang),
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isDark ? const Color(0xFFF1F5F9) : Colors.blue.shade900,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildChoiceChip(
                context,
                title: 'Türkçe',
                icon: '🇹🇷',
                isSelected: lang == 'tr',
                onTap: () => provider.updateLanguage('tr'),
                isDark: isDark,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildChoiceChip(
                context,
                title: 'English',
                icon: '🇬🇧',
                isSelected: lang == 'en',
                onTap: () => provider.updateLanguage('en'),
                isDark: isDark,
              ),
            ),
          ],
        ),
        const Divider(height: 24, thickness: 0.5),

        // 2. Custom Mascot Selection (Özel Maskotlar)
        Row(
          children: [
            Expanded(
              child: Text(
                AppTranslations.get('section_mascot', lang: lang),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isDark ? const Color(0xFFF1F5F9) : Colors.blue.shade900,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFF38BDF8).withOpacity(0.18),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                '5 Maskot • 10 Durum',
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0284C7),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          lang == 'en'
              ? 'Choose which mascot accompanies your hydration journey with time-aware smart illustrations.'
              : 'Gün boyu saate ve su hedefinize göre size eğlenceli sözler ve çizimlerle eşlik edecek maskotunuzu seçin.',
          style: TextStyle(
            fontSize: 11,
            color: isDark ? const Color(0xFF94A3B8) : Colors.grey,
          ),
        ),
        const SizedBox(height: 10),
        ...MascotCatalog.allMascots.map((m) {
          final isSelected = provider.mascotType == m.id;
          return Padding(
            padding: const EdgeInsets.only(bottom: 4.0),
            child: _buildMascotOption(
              context,
              mascot: m,
              lang: lang,
              isSelected: isSelected,
              onTap: () => provider.updateMascotType(m.id),
              isDark: isDark,
            ),
          );
        }),
        const Divider(height: 24, thickness: 0.5),

        // 3. Widget & Color Theme Selector (Widget Teması)
        Text(
          AppTranslations.get('section_widget_theme', lang: lang),
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isDark ? const Color(0xFFF1F5F9) : Colors.blue.shade900,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          lang == 'en'
              ? 'Personalize widget backgrounds and accents for Android & iOS.'
              : 'Android ve iOS araç takımlarının arka plan ve renk paletini özelleştirin.',
          style: TextStyle(
            fontSize: 11,
            color: isDark ? const Color(0xFF94A3B8) : Colors.grey,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildThemePill(
              context,
              id: 'ocean',
              name: AppTranslations.get('theme_ocean', lang: lang),
              colors: [const Color(0xFF0369A1), const Color(0xFF38BDF8)],
              isSelected: provider.widgetTheme == 'ocean',
              onTap: () => provider.updateWidgetTheme('ocean'),
              isDark: isDark,
            ),
            _buildThemePill(
              context,
              id: 'glass',
              name: AppTranslations.get('theme_glass', lang: lang),
              colors: [const Color(0xFF0F172A), const Color(0xFF334155)],
              isSelected: provider.widgetTheme == 'glass',
              onTap: () => provider.updateWidgetTheme('glass'),
              isDark: isDark,
            ),
            _buildThemePill(
              context,
              id: 'neon',
              name: AppTranslations.get('theme_neon', lang: lang),
              colors: [const Color(0xFF2E0249), const Color(0xFFD946EF)],
              isSelected: provider.widgetTheme == 'neon',
              onTap: () => provider.updateWidgetTheme('neon'),
              isDark: isDark,
            ),
            _buildThemePill(
              context,
              id: 'emerald',
              name: AppTranslations.get('theme_emerald', lang: lang),
              colors: [const Color(0xFF064E3B), const Color(0xFF10B981)],
              isSelected: provider.widgetTheme == 'emerald',
              onTap: () => provider.updateWidgetTheme('emerald'),
              isDark: isDark,
            ),
          ],
        ),
        const Divider(height: 24, thickness: 0.5),

        // 4. Dark Theme Switch
        InkWell(
          onTap: () => provider.updateThemeMode(
            provider.isDarkMode ? ThemeMode.light : ThemeMode.dark,
          ),
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
                        lang == 'en'
                            ? 'Midnight Dark Theme'
                            : 'Gece Mavisi Karanlık Tema',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? const Color(0xFFF1F5F9)
                              : Colors.blue.shade900,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        lang == 'en'
                            ? 'Eye-friendly deep navy and midnight blue interface.'
                            : 'Gözü yormayan derin lacivert ve gece mavisi arayüz.',
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
                  value: provider.isDarkMode,
                  activeThumbColor: const Color(0xFF38BDF8),
                  onChanged: (val) {
                    provider.updateThemeMode(
                      val ? ThemeMode.dark : ThemeMode.light,
                    );
                  },
                ),
              ],
            ),
          ),
        ),
        const Divider(height: 16, thickness: 0.5),

        // 5. Sound & Haptic Effects Switch
        InkWell(
          onTap: () => provider.updateSoundEffectsEnabled(
            !provider.isSoundEffectsEnabled,
          ),
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
                        lang == 'en'
                            ? 'Water Sip & Haptic Feedback'
                            : 'Su Ekleme Ses & Titreşim Efektleri',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? const Color(0xFFF1F5F9)
                              : Colors.blue.shade900,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        lang == 'en'
                            ? 'Plays a gentle sip audio on water log and celebration melody on goals.'
                            : 'Su eklerken yudumlama sesi ve hedefe ulaşınca kutlama melodisi çalar.',
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
                  value: provider.isSoundEffectsEnabled,
                  activeThumbColor: const Color(0xFF38BDF8),
                  onChanged: (val) {
                    provider.updateSoundEffectsEnabled(val);
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildChoiceChip(
    BuildContext context, {
    required String title,
    required String icon,
    required bool isSelected,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? const Color(0xFF0F2B48) : const Color(0xFFE0F2FE))
              : (isDark ? const Color(0xFF1E293B) : Colors.grey.shade50),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF38BDF8)
                : (isDark ? const Color(0xFF334155) : Colors.grey.shade300),
            width: isSelected ? 1.8 : 1.0,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(icon, style: const TextStyle(fontSize: 15)),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected
                      ? const Color(0xFF38BDF8)
                      : (isDark ? Colors.white : Colors.blue.shade900),
                ),
              ),
            ),
            if (isSelected) ...[
              const SizedBox(width: 4),
              const Icon(Icons.check_circle_rounded, size: 14, color: Color(0xFF38BDF8)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMascotOption(
    BuildContext context, {
    required MascotCharacter mascot,
    required String lang,
    required bool isSelected,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    final isEn = lang == 'en';
    final name = AppTranslations.get('mascot_${mascot.id}', lang: lang);
    final personality = isEn ? mascot.personalityEn : mascot.personalityTr;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? const Color(0xFF0F2B48) : const Color(0xFFE0F2FE))
              : (isDark ? const Color(0xFF1E293B) : Colors.grey.shade50),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF38BDF8)
                : (isDark ? const Color(0xFF334155) : Colors.grey.shade300),
            width: isSelected ? 1.8 : 1.0,
          ),
        ),
        child: Row(
          children: [
            // Mascot Thumbnail / Avatar
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFF38BDF8).withOpacity(0.2)
                    : (isDark ? const Color(0xFF0F172A) : Colors.white),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFF38BDF8).withOpacity(0.5)
                      : Colors.transparent,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.asset(
                  mascot.defaultImageAsset,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Center(
                    child: Text(
                      mascot.emoji,
                      style: const TextStyle(fontSize: 20),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),

            // Name & Personality
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: isSelected
                          ? const Color(0xFF38BDF8)
                          : (isDark ? Colors.white : Colors.blue.shade900),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    personality,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark ? const Color(0xFF94A3B8) : Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 6),

            // Preview 10 States Button
            IconButton(
              tooltip: isEn ? 'Preview 10 States' : '10 Durumu İncele',
              icon: Icon(
                Icons.visibility_outlined,
                size: 20,
                color: isDark ? const Color(0xFF94A3B8) : Colors.grey.shade600,
              ),
              onPressed: () {
                showMascotStatePreviewDialog(context, mascot, lang: lang);
              },
            ),

            // Selection Radio Indicator
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: isSelected
                  ? const Color(0xFF38BDF8)
                  : (isDark ? Colors.grey : Colors.grey.shade400),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThemePill(
    BuildContext context, {
    required String id,
    required String name,
    required List<Color> colors,
    required bool isSelected,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? const Color(0xFF0F2B48) : const Color(0xFFE0F2FE))
              : (isDark ? const Color(0xFF1E293B) : Colors.grey.shade50),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF38BDF8)
                : (isDark ? const Color(0xFF334155) : Colors.grey.shade300),
            width: isSelected ? 1.8 : 1.0,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(colors: colors),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              name,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected
                    ? const Color(0xFF38BDF8)
                    : (isDark ? Colors.white : Colors.blue.shade900),
              ),
            ),
            if (isSelected) ...[
              const SizedBox(width: 6),
              const Icon(Icons.check_rounded, size: 14, color: Color(0xFF38BDF8)),
            ],
          ],
        ),
      ),
    );
  }
}
