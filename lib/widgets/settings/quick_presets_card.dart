import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/water_provider.dart';
import 'settings_card_wrapper.dart';

class QuickPresetsCard extends StatelessWidget {
  final TextEditingController preset1Controller;
  final TextEditingController preset2Controller;
  final TextEditingController preset3Controller;
  final VoidCallback onSave;

  const QuickPresetsCard({
    super.key,
    required this.preset1Controller,
    required this.preset2Controller,
    required this.preset3Controller,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isEn = Provider.of<WaterProvider>(context).language == 'en';

    Widget buildPresetColumn(int defaultAmount, TextEditingController controller) {
      return Expanded(
        child: ValueListenableBuilder<TextEditingValue>(
          valueListenable: controller,
          builder: (context, value, _) {
            final parsedAmount = int.tryParse(value.text.trim()) ?? defaultAmount;
            final meta = WaterProvider.getPresetMeta(
              parsedAmount > 0 ? parsedAmount : defaultAmount,
              lang: isEn ? 'en' : 'tr',
            );
            final icon = meta['emoji'] ?? '🥛';
            final label = meta['name'] ?? (isEn ? 'Glass' : 'Bardak');

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(icon, style: const TextStyle(fontSize: 14)),
                    const SizedBox(width: 3),
                    Expanded(
                      child: Text(
                        label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: isDark ? const Color(0xFF94A3B8) : Colors.grey,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: controller,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    suffixText: 'ml',
                    filled: true,
                    fillColor: isDark ? const Color(0xFF0B132B) : Theme.of(context).colorScheme.primary.withValues(alpha: 0.05),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: isDark ? const Color(0xFF3A506B) : Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      );
    }

    return SettingsCardWrapper(
      title: isEn ? 'Quick Add Presets' : 'Hızlı Su Ekleme Paneli',
      titleTrailing: Icon(Icons.local_drink_outlined, color: Theme.of(context).colorScheme.primary),
      children: [
        Text(
          isEn
              ? 'Customize the quick water add button amounts (ml) on your dashboard and widgets.'
              : 'Ana ekrandaki ve araç takımlarındaki hızlı su ekleme butonlarının (ml) değerlerini özelleştirin.',
          style: TextStyle(
            fontSize: 11,
            color: isDark ? const Color(0xFF94A3B8) : Colors.grey,
          ),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            buildPresetColumn(200, preset1Controller),
            const SizedBox(width: 8),
            buildPresetColumn(330, preset2Controller),
            const SizedBox(width: 8),
            buildPresetColumn(500, preset3Controller),
          ],
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: onSave,
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 44),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 0,
          ),
          child: Text(
            isEn ? 'Update Amounts' : 'Miktarları Güncelle',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          ),
        ),
      ],
    );
  }
}
