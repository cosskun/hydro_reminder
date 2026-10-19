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
    if (!_isInitialized) {
      final provider = Provider.of<WaterProvider>(context);
      _selectedGender = provider.gender;
      _ageController = TextEditingController(text: provider.age.toString());
      _weightController = TextEditingController(text: provider.weight.toString());
      _dailyGoalController = TextEditingController(text: provider.dailyGoal.toString());
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
    if (goal < 500 || goal > 10000) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lütfen 500 ml ile 10.000 ml arasında geçerli bir hedef girin.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    Provider.of<WaterProvider>(context, listen: false).updateDailyGoal(goal);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Günlük su hedefiniz $goal ml olarak güncellendi! 💧'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _autoCalculateGoal() {
    final age = int.tryParse(_ageController.text) ?? 25;
    final weight = double.tryParse(_weightController.text) ?? 70.0;
    final provider = Provider.of<WaterProvider>(context, listen: false);
    final calculated = provider.calculateDailyGoal(
      gender: _selectedGender,
      age: age,
      weight: weight,
    );
    setState(() {
      _dailyGoalController.text = calculated.toString();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Profilinize göre önerilen hedef: $calculated ml. Kaydetmek için "Hedefi Güncelle"ye basın.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _saveProfile() {
    final age = int.tryParse(_ageController.text) ?? 25;
    final weight = double.tryParse(_weightController.text) ?? 70.0;
    final provider = Provider.of<WaterProvider>(context, listen: false);

    provider.updateProfile(
      gender: _selectedGender,
      age: age,
      weight: weight,
    );

    // Keep goal controller in sync with recalculated goal
    setState(() {
      _dailyGoalController.text = provider.dailyGoal.toString();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Profil bilgileri güncellendi ve yeni hedef hesaplandı! 💧'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _savePresets() {
    final p1 = int.tryParse(_preset1Controller.text) ?? 200;
    final p2 = int.tryParse(_preset2Controller.text) ?? 330;
    final p3 = int.tryParse(_preset3Controller.text) ?? 500;

    Provider.of<WaterProvider>(context, listen: false).updatePresets(p1, p2, p3);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Hızlı ekleme miktarları başarıyla güncellendi. 💧'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _confirmReset(BuildContext context, bool isDark) {
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
                'Verileri Sıfırla?',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isDark ? const Color(0xFFF1F5F9) : const Color(0xFF0F172A),
                ),
              ),
            ],
          ),
          content: Text(
            'Tüm profil bilgilerinizi, hatırlatıcı alarmlarınızı ve geçmiş su tüketim kayıtlarınızı silmek üzeresiniz.\n\nSıfırlama işlemine devam etmek istiyor musunuz?',
            style: TextStyle(
              height: 1.4,
              color: isDark ? const Color(0xFF94A3B8) : Colors.grey.shade700,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(firstDialogContext),
              child: Text('Vazgeç', style: TextStyle(color: isDark ? Colors.grey.shade400 : Colors.grey.shade600)),
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
              child: const Text('Devam Et ➡️'),
            ),
          ],
        );
      },
    );
  }

  void _showFinalResetConfirmationDialog(BuildContext context, bool isDark) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (secondDialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          backgroundColor: isDark ? const Color(0xFF1C2541) : Colors.white,
          title: const Row(
            children: [
              Text('🚨 ', style: TextStyle(fontSize: 22)),
              Text(
                'Son Doğrulama',
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'DİKKAT: Bu işlem kesinlikle geri alınamaz!',
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
              ),
              const SizedBox(height: 8),
              Text(
                'Uygulama ilk kurulum haline dönecek ve bugüne kadarki tüm su tüketim geçmişiniz ve rozetleriniz kalıcı olarak silinecektir.\n\nGerçekten silmek istediğinizi onaylıyor musunuz?',
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
              child: Text('İptal Et', style: TextStyle(color: isDark ? Colors.grey.shade400 : Colors.grey.shade700, fontWeight: FontWeight.bold)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(secondDialogContext);
                Provider.of<WaterProvider>(context, listen: false).resetAllData();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Row(
                      children: [
                        Icon(Icons.check_circle_outline, color: Colors.white),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text('Tüm veriler başarıyla sıfırlandı.'),
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
              child: const Text('Evet, Kalıcı Olarak Sil'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<WaterProvider>(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ayarlar ⚙️',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: isDark ? const Color(0xFFF1F5F9) : Colors.blue.shade900,
            ),
          ),
          const SizedBox(height: 20),
          
          const AppearanceSettingsCard(),
          const SizedBox(height: 24),
          
          DailyGoalSettingsCard(
            dailyGoalController: _dailyGoalController,
            onAutoCalculate: _autoCalculateGoal,
            onSave: _saveDailyGoal,
          ),
          const SizedBox(height: 24),
          
          ProfileSettingsCard(
            selectedGender: _selectedGender,
            onGenderChanged: (val) => setState(() => _selectedGender = val),
            ageController: _ageController,
            weightController: _weightController,
            onSave: _saveProfile,
          ),
          const SizedBox(height: 24),
          
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
          
          const EndOfDaySettingsCard(),
          const SizedBox(height: 24),
          
          QuickPresetsCard(
            preset1Controller: _preset1Controller,
            preset2Controller: _preset2Controller,
            preset3Controller: _preset3Controller,
            onSave: _savePresets,
          ),
          const SizedBox(height: 24),

          if (!kIsWeb && (theme.platform == TargetPlatform.iOS || Platform.isIOS)) ...[
            const IosShortcutsSettingsCard(),
            const SizedBox(height: 24),
          ],

          if (!kIsWeb && (theme.platform == TargetPlatform.android || Platform.isAndroid)) ...[
            const AndroidFeaturesSettingsCard(),
            const SizedBox(height: 24),
          ],

          const LegalPrivacySettingsCard(),
          const SizedBox(height: 24),
          
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1C2541) : Colors.blue.shade50.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark ? const Color(0xFF3A506B) : Colors.blue.shade50,
              ),
            ),
            child: Row(
              children: [
                const Text('💡', style: TextStyle(fontSize: 24)),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Mevcut günlük su hedefiniz: ${provider.dailyGoal} ml. Dilediğiniz zaman bu hedefi yukarıdaki alandan manuel olarak güncelleyebilir veya kilo & yaşınıza göre yeniden hesaplatabilirsiniz.',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? const Color(0xFF94A3B8) : Colors.blue.shade900.withValues(alpha: 0.8),
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
          
          DangerZoneCard(
            onReset: () => _confirmReset(context, isDark),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
