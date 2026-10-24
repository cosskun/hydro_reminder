import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb, TargetPlatform;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/water_provider.dart';
import '../services/alarm_service.dart';
import '../widgets/settings/appearance_settings_card.dart';
import '../widgets/settings/daily_goal_settings_card.dart';
import '../widgets/settings/profile_settings_card.dart';
import '../widgets/settings/notification_settings_card.dart';
import '../widgets/settings/end_of_day_settings_card.dart';
import '../widgets/settings/quick_presets_card.dart';
import '../widgets/settings/ios_shortcuts_settings_card.dart';
import '../widgets/settings/android_features_settings_card.dart';
import '../widgets/settings/legal_privacy_settings_card.dart';
import '../widgets/settings/danger_zone_card.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> with WidgetsBindingObserver {
  late String _selectedGender;
  late TextEditingController _ageController;
  late TextEditingController _weightController;
  late TextEditingController _dailyGoalController;
  late TextEditingController _preset1Controller;
  late TextEditingController _preset2Controller;
  late TextEditingController _preset3Controller;
  bool _isInitialized = false;
  bool _hasNotificationPermission = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkPermission();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final provider = Provider.of<WaterProvider>(context);
    if (!_isInitialized) {
      _selectedGender = provider.gender;
      _ageController = TextEditingController(text: provider.age.toString());
      _weightController = TextEditingController(text: provider.weight.toString());
      _dailyGoalController = TextEditingController(text: provider.baseDailyGoal.toString());
      _preset1Controller = TextEditingController(text: provider.preset1.toString());
      _preset2Controller = TextEditingController(text: provider.preset2.toString());
      _preset3Controller = TextEditingController(text: provider.preset3.toString());
      _isInitialized = true;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _ageController.dispose();
    _weightController.dispose();
    _dailyGoalController.dispose();
    _preset1Controller.dispose();
    _preset2Controller.dispose();
    _preset3Controller.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkPermission();
    }
  }

  Future<void> _checkPermission() async {
    final status = await AlarmService().checkPermissionStatus();
    if (mounted) {
      setState(() {
        _hasNotificationPermission = status;
      });
      final provider = Provider.of<WaterProvider>(context, listen: false);
      await provider.syncNotificationPermissionFromOS(status);
    }
  }

  void _saveDailyGoal() {
    final goal = int.tryParse(_dailyGoalController.text) ?? 2500;
    final isEn = Provider.of<WaterProvider>(context, listen: false).language == 'en';
    if (goal < 500 || goal > 10000) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isEn
                ? 'Please enter a valid goal between 500 ml and 10,000 ml.'
                : 'Lütfen 500 ml ile 10.000 ml arasında geçerli bir hedef girin.',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    Provider.of<WaterProvider>(context, listen: false).updateDailyGoal(goal);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isEn
              ? 'Your daily water goal has been updated to $goal ml! 💧'
              : 'Günlük su hedefiniz $goal ml olarak güncellendi! 💧',
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _autoCalculateGoal() {
    final age = int.tryParse(_ageController.text.trim()) ?? 25;
    final weight = double.tryParse(_weightController.text.trim().replaceAll(',', '.')) ?? 70.0;
    final provider = Provider.of<WaterProvider>(context, listen: false);
    final calculated = provider.calculateDailyGoal(
      gender: _selectedGender,
      age: age,
      weight: weight,
    );
    final isEn = provider.language == 'en';
    setState(() {
      _dailyGoalController.text = calculated.toString();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isEn
              ? 'Recommended goal based on your profile: $calculated ml. Press "Save Daily Goal" to apply.'
              : 'Profilinize göre önerilen hedef: $calculated ml. Kaydetmek için "Hedefi Güncelle"ye basın.',
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _saveProfile() {
    final age = int.tryParse(_ageController.text.trim()) ?? 25;
    final weight = double.tryParse(_weightController.text.trim().replaceAll(',', '.')) ?? 70.0;
    final provider = Provider.of<WaterProvider>(context, listen: false);

    provider.updateProfile(
      gender: _selectedGender,
      age: age,
      weight: weight,
    );

    // Keep goal controller in sync with recalculated base goal
    setState(() {
      _dailyGoalController.text = provider.baseDailyGoal.toString();
    });

    final isEn = provider.language == 'en';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isEn
              ? 'Profile updated and new daily goal calculated! 💧'
              : 'Profil bilgileri güncellendi ve yeni hedef hesaplandı! 💧',
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _savePresets() {
    final p1 = int.tryParse(_preset1Controller.text) ?? 200;
    final p2 = int.tryParse(_preset2Controller.text) ?? 330;
    final p3 = int.tryParse(_preset3Controller.text) ?? 500;

    final provider = Provider.of<WaterProvider>(context, listen: false);
    provider.updatePresets(p1, p2, p3);
    final isEn = provider.language == 'en';

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isEn
              ? 'Quick add presets successfully updated. 💧'
              : 'Hızlı ekleme miktarları başarıyla güncellendi. 💧',
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _confirmReset(BuildContext context, bool isDark) {
    final isEn = Provider.of<WaterProvider>(context, listen: false).language == 'en';
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (firstDialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          backgroundColor: isDark ? const Color(0xFF1C2541) : Colors.white,
          title: Row(
            children: [
              const Text('⚠️ ', style: TextStyle(fontSize: 22)),
              Text(
                isEn ? 'Reset All Data?' : 'Verileri Sıfırla?',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isDark ? const Color(0xFFF1F5F9) : const Color(0xFF0F172A),
                ),
              ),
            ],
          ),
          content: Text(
            isEn
                ? 'You are about to delete all your profile information, reminder alarms, and water intake history.\n\nDo you want to proceed with the reset?'
                : 'Tüm profil bilgilerinizi, hatırlatıcı alarmlarınızı ve geçmiş su tüketim kayıtlarınızı silmek üzeresiniz.\n\nSıfırlama işlemine devam etmek istiyor musunuz?',
            style: TextStyle(
              height: 1.4,
              color: isDark ? const Color(0xFF94A3B8) : Colors.grey.shade700,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(firstDialogContext),
              child: Text(
                isEn ? 'Cancel' : 'Vazgeç',
                style: TextStyle(color: isDark ? Colors.grey.shade400 : Colors.grey.shade600),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(firstDialogContext);
                _showFinalResetConfirmationDialog(context, isDark);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange.shade700,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: Text(isEn ? 'Continue ➡️' : 'Devam Et ➡️'),
            ),
          ],
        );
      },
    );
  }

  void _showFinalResetConfirmationDialog(BuildContext context, bool isDark) {
    final isEn = Provider.of<WaterProvider>(context, listen: false).language == 'en';
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (secondDialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          backgroundColor: isDark ? const Color(0xFF1C2541) : Colors.white,
          title: Row(
            children: [
              const Text('🚨 ', style: TextStyle(fontSize: 22)),
              Text(
                isEn ? 'Final Confirmation' : 'Son Doğrulama',
                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isEn
                    ? 'ATTENTION: This action cannot be undone!'
                    : 'DİKKAT: Bu işlem kesinlikle geri alınamaz!',
                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
              ),
              const SizedBox(height: 8),
              Text(
                isEn
                    ? 'The app will return to its initial state, and all your hydration history and badges will be permanently deleted.\n\nAre you sure you want to delete everything?'
                    : 'Uygulama ilk kurulum haline dönecek ve bugüne kadarki tüm su tüketim geçmişiniz ve rozetleriniz kalıcı olarak silinecektir.\n\nGerçekten silmek istediğinizi onaylıyor musunuz?',
                style: TextStyle(
                  height: 1.4,
                  color: isDark ? const Color(0xFF94A3B8) : Colors.grey.shade700,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(secondDialogContext),
              child: Text(
                isEn ? 'Cancel' : 'İptal Et',
                style: TextStyle(color: isDark ? Colors.grey.shade400 : Colors.grey.shade700, fontWeight: FontWeight.bold),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(secondDialogContext);
                Provider.of<WaterProvider>(context, listen: false).resetAllData();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        const Icon(Icons.check_circle_outline, color: Colors.white),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            isEn
                                ? 'All data has been successfully reset.'
                                : 'Tüm veriler başarıyla sıfırlandı.',
                          ),
                        ),
                      ],
                    ),
                    backgroundColor: Colors.red,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade700,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: Text(isEn ? 'Yes, Permanently Delete' : 'Evet, Kalıcı Olarak Sil'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<WaterProvider>(context);
    final isEn = provider.language == 'en';
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isEn ? 'Settings ⚙️' : 'Ayarlar ⚙️',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: isDark ? const Color(0xFFF1F5F9) : const Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 20),
          
          // 1. Profil bilgilerini güncelle
          ProfileSettingsCard(
            selectedGender: _selectedGender,
            onGenderChanged: (val) => setState(() => _selectedGender = val),
            ageController: _ageController,
            weightController: _weightController,
            onSave: _saveProfile,
          ),
          const SizedBox(height: 24),
          
          // 2. Günlük su hedefi
          DailyGoalSettingsCard(
            dailyGoalController: _dailyGoalController,
            onAutoCalculate: _autoCalculateGoal,
            onSave: _saveDailyGoal,
          ),
          const SizedBox(height: 14),

          // 3. Hedef ve hesaplama bilgilendirme uyarısı
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1C2541) : theme.colorScheme.primary.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark ? const Color(0xFF3A506B) : theme.colorScheme.primary.withValues(alpha: 0.15),
              ),
            ),
            child: Row(
              children: [
                const Text('💡', style: TextStyle(fontSize: 22)),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    isEn
                        ? 'Your current daily water goal: ${provider.dailyGoal} ml. You can update this goal manually from above or recalculate it based on your weight & age anytime.'
                        : 'Mevcut günlük su hedefiniz: ${provider.dailyGoal} ml. Dilediğiniz zaman bu hedefi yukarıdaki alandan manuel olarak güncelleyebilir veya kilo & yaşınıza göre yeniden hesaplatabilirsiniz.',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF1E293B),
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // 4. Hızlı su ekleme paneli
          QuickPresetsCard(
            preset1Controller: _preset1Controller,
            preset2Controller: _preset2Controller,
            preset3Controller: _preset3Controller,
            onSave: _savePresets,
          ),
          const SizedBox(height: 24),

          // 5. Gün sonu özet
          const EndOfDaySettingsCard(),
          const SizedBox(height: 24),

          // 6. Görünüm efekt
          const AppearanceSettingsCard(),
          const SizedBox(height: 24),

          // 7. Bildirim alarm
          NotificationSettingsCard(
            hasNotificationPermission: _hasNotificationPermission,
            onRequestPermission: () async {
              final result = await AlarmService().requestPermission();
              if (!result) {
                await AlarmService().openNotificationSettings();
              }
              await _checkPermission();
            },
          ),
          const SizedBox(height: 24),

          // 8. Android Hızlı kontroller (iOS için iOS Kestirmeler)
          if (!kIsWeb && (theme.platform == TargetPlatform.iOS || Platform.isIOS)) ...[
            const IosShortcutsSettingsCard(),
            const SizedBox(height: 24),
          ],

          if (!kIsWeb && (theme.platform == TargetPlatform.android || Platform.isAndroid)) ...[
            const AndroidFeaturesSettingsCard(),
            const SizedBox(height: 24),
          ],

          // 9. Yasal bilgiler
          const LegalPrivacySettingsCard(),
          const SizedBox(height: 28),
          
          // 10. Sıfırlama (eski Tehlikeli Alan)
          DangerZoneCard(
            onReset: () => _confirmReset(context, isDark),
          ),          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
