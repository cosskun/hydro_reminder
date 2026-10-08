import 'package:flutter/material.dart';
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

    Widget buildPresetColumn(String icon, String label, TextEditingController controller) {
      return Expanded(
        child: Column(
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
                fillColor: isDark ? const Color(0xFF0B132B) : Colors.blue.shade50.withValues(alpha: 0.2),
                contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: isDark ? const Color(0xFF3A506B) : Colors.blue.shade100,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return SettingsCardWrapper(
      title: 'Hızlı Su Ekleme Miktarları',
      titleTrailing: const Icon(Icons.local_drink_outlined, color: Color(0xFF38BDF8)),
      children: [
        const SizedBox(height: -8),
        Text(
          'Ana ekrandaki hızlı su ekleme butonlarının (ml) değerlerini özelleştirin.',
          style: TextStyle(
            fontSize: 11,
            color: isDark ? const Color(0xFF94A3B8) : Colors.grey,
          ),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            buildPresetColumn('🥛', 'Bardak', preset1Controller),
            const SizedBox(width: 8),
            buildPresetColumn('🥤', 'Küçük Şişe', preset2Controller),
            const SizedBox(width: 8),
            buildPresetColumn('🌊', 'Büyük Şişe', preset3Controller),
          ],
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: onSave,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF0288D1),
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 44),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 0,
          ),
          child: const Text(
            'Miktarları Güncelle',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          ),
        ),
      ],
    );
  }
}
