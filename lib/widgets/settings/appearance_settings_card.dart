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

        // 2.5. Auto Mascot Theme Switch (Maskota Göre Tema)
        InkWell(
          onTap: () => provider.updateUseMascotTheme(!provider.useMascotTheme),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 6,
                        runSpacing: 4,
                        children: [
                          Text(
                            AppTranslations.get('auto_mascot_theme', lang: lang),
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: isDark ? const Color(0xFFF1F5F9) : Colors.blue.shade900,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: provider.useMascotTheme
                                  ? (isDark ? const Color(0xFF065F46) : const Color(0xFFD1FAE5))
                                  : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              provider.useMascotTheme
                                  ? (lang == 'en' ? 'Active' : 'Devrede')
                                  : (lang == 'en' ? 'Original' : 'Orijinal'),
                              style: TextStyle(
                                fontSize: 9.5,
                                fontWeight: FontWeight.bold,
                                color: provider.useMascotTheme
                                    ? (isDark ? const Color(0xFF34D399) : const Color(0xFF047857))
                                    : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        AppTranslations.get('auto_mascot_theme_desc', lang: lang),
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
                  value: provider.useMascotTheme,
                  activeThumbColor: theme.colorScheme.primary,
                  onChanged: (val) => provider.updateUseMascotTheme(val),
                ),
              ],
            ),
          ),
        ),
        const Divider(height: 24, thickness: 0.5),

        // 2.6. Manual Mascot Palette Picker (Shown when auto-theme is off)
        if (!provider.useMascotTheme) ...[
          const SizedBox(height: 10),
          Text(
            lang == 'en' ? 'Manual Palette' : 'Manuel Renk Paleti',
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: isDark ? const Color(0xFFF1F5F9) : Colors.blue.shade900,
            ),
          ),
          const SizedBox(height: 6),
          Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _buildThemePill(
                      context,
                      id: 'ocean',
                      name: lang == 'en' ? '💧 Original Ocean' : '💧 Orijinal Mavi',
                      colors: [const Color(0xFF0369A1), const Color(0xFF38BDF8)],
                      isSelected: provider.customThemePreset == 'ocean',
                      onTap: () => provider.updateCustomThemePreset('ocean'),
                      isDark: isDark,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildThemePill(
                      context,
                      id: 'cat',
                      name: lang == 'en' ? '🐱 Luna Lavender' : '🐱 Luna Moru',
                      colors: [const Color(0xFF7C3AED), const Color(0xFFEC4899)],
                      isSelected: provider.customThemePreset == 'cat',
                      onTap: () => provider.updateCustomThemePreset('cat'),
                      isDark: isDark,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _buildThemePill(
                      context,
                      id: 'dog',
                      name: lang == 'en' ? '🐩 Caramel Amber' : '🐩 Karamel Amber',
                      colors: [const Color(0xFFD97706), const Color(0xFFFBBF24)],
                      isSelected: provider.customThemePreset == 'dog',
                      onTap: () => provider.updateCustomThemePreset('dog'),
                      isDark: isDark,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildThemePill(
                      context,
                      id: 'penguin',
                      name: lang == 'en' ? '🐧 Glacier Ice' : '🐧 Buzul Kristali',
                      colors: [const Color(0xFF0284C7), const Color(0xFF2DD4BF)],
                      isSelected: provider.customThemePreset == 'penguin',
                      onTap: () => provider.updateCustomThemePreset('penguin'),
                      isDark: isDark,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _buildThemePill(
                      context,
                      id: 'panda',
                      name: lang == 'en' ? '🐼 Bamboo Emerald' : '🐼 Bambu Zümrüt',
                      colors: [const Color(0xFF059669), const Color(0xFF84CC16)],
                      isSelected: provider.customThemePreset == 'panda',
                      onTap: () => provider.updateCustomThemePreset('panda'),
                      isDark: isDark,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildThemePill(
                      context,
                      id: 'squirrel',
                      name: lang == 'en' ? '🐿️ Autumn Amber' : '🐿️ Sonbahar Amberi',
                      colors: [const Color(0xFFEA580C), const Color(0xFFFB923C)],
                      isSelected: provider.customThemePreset == 'squirrel',
                      onTap: () => provider.updateCustomThemePreset('squirrel'),
                      isDark: isDark,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
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
              ? 'Choose color scheme for iOS Home Screen & Lock Screen widgets.'
              : 'iOS Ana Ekran ve Kilit Ekranı araç takımlarının renk temasını seçin.',
          style: TextStyle(
            fontSize: 11,
            color: isDark ? const Color(0xFF94A3B8) : Colors.grey,
          ),
        ),
        const SizedBox(height: 10),
        Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: _buildThemePill(
                    context,
                    id: 'ocean',
                    name: AppTranslations.get('theme_ocean', lang: lang),
                    colors: [const Color(0xFF0369A1), const Color(0xFF38BDF8)],
                    isSelected: provider.widgetTheme == 'ocean',
                    onTap: () => provider.updateWidgetTheme('ocean'),
                    isDark: isDark,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildThemePill(
                    context,
                    id: 'glass',
                    name: AppTranslations.get('theme_glass', lang: lang),
                    colors: [const Color(0xFF334155), const Color(0xFF94A3B8)],
                    isSelected: provider.widgetTheme == 'glass',
                    onTap: () => provider.updateWidgetTheme('glass'),
                    isDark: isDark,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildThemePill(
                    context,
                    id: 'neon',
                    name: AppTranslations.get('theme_neon', lang: lang),
                    colors: [const Color(0xFF2E0249), const Color(0xFFA91079)],
                    isSelected: provider.widgetTheme == 'neon',
                    onTap: () => provider.updateWidgetTheme('neon'),
                    isDark: isDark,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildThemePill(
                    context,
                    id: 'emerald',
                    name: AppTranslations.get('theme_emerald', lang: lang),
                    colors: [const Color(0xFF064E3B), const Color(0xFF10B981)],
                    isSelected: provider.widgetTheme == 'emerald',
                    onTap: () => provider.updateWidgetTheme('emerald'),
                    isDark: isDark,
                  ),
                ),
              ],
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
    final theme = Theme.of(context);
    final activeColor = colors.isNotEmpty ? colors.first : theme.colorScheme.primary;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 8),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected
                ? (isDark ? activeColor.withOpacity(0.18) : activeColor.withOpacity(0.12))
                : (isDark ? const Color(0xFF1E293B) : Colors.grey.shade50),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? activeColor
                  : (isDark ? const Color(0xFF334155) : Colors.grey.shade300),
              width: 1.2,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
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
              Flexible(
                child: Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                    color: isSelected
                        ? activeColor
                        : (isDark ? Colors.white : Colors.blue.shade900),
                  ),
                ),
              ),
              if (isSelected) ...[
                const SizedBox(width: 4),
                Icon(Icons.check_rounded, size: 14, color: activeColor),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
