import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/water_provider.dart';
import 'settings_card_wrapper.dart';

class ProfileSettingsCard extends StatelessWidget {
  final String selectedGender;
  final ValueChanged<String> onGenderChanged;
  final TextEditingController ageController;
  final TextEditingController weightController;
  final VoidCallback onSave;

  const ProfileSettingsCard({
    super.key,
    required this.selectedGender,
    required this.onGenderChanged,
    required this.ageController,
    required this.weightController,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isEn = Provider.of<WaterProvider>(context).language == 'en';

    String getGenderLabel(String g) {
      if (!isEn) return g;
      switch (g) {
        case 'Erkek':
          return 'Male';
        case 'Kadın':
          return 'Female';
        case 'Diğer':
          return 'Other';
        default:
          return g;
      }
    }

    return SettingsCardWrapper(
      title: isEn ? 'Update Profile' : 'Profil Bilgilerini Güncelle',
      children: [
        Text(
          isEn ? 'Gender' : 'Cinsiyet',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: isDark ? const Color(0xFF94A3B8) : Colors.grey,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: ['Erkek', 'Kadın', 'Diğer'].map((g) {
            final isSelected = selectedGender == g;
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: InkWell(
                  onTap: () => onGenderChanged(g),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Theme.of(context).colorScheme.primary
                          : (isDark ? const Color(0xFF0B132B) : Theme.of(context).colorScheme.primary.withValues(alpha: 0.08)),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isSelected
                            ? Theme.of(context).colorScheme.primary
                            : (isDark ? const Color(0xFF3A506B) : Theme.of(context).colorScheme.primary.withValues(alpha: 0.2)),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        getGenderLabel(g),
                        style: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : (isDark ? const Color(0xFFF1F5F9) : const Color(0xFF1E293B)),
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isEn ? 'Age' : 'Yaş',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isDark ? const Color(0xFF94A3B8) : Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: ageController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      suffixText: isEn ? 'yrs' : 'yıl',
                      filled: true,
                      fillColor: isDark ? const Color(0xFF0B132B) : Theme.of(context).colorScheme.primary.withValues(alpha: 0.05),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: isDark ? const Color(0xFF3A506B) : Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isEn ? 'Weight' : 'Kilo',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isDark ? const Color(0xFF94A3B8) : Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: weightController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      suffixText: 'kg',
                      filled: true,
                      fillColor: isDark ? const Color(0xFF0B132B) : Theme.of(context).colorScheme.primary.withValues(alpha: 0.05),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: isDark ? const Color(0xFF3A506B) : Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: onSave,
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 48),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 0,
          ),
          child: Text(
            isEn ? 'Save Changes' : 'Değişiklikleri Kaydet',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}
