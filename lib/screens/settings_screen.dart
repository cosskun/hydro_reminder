import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/water_provider.dart';
import '../services/alarm_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
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
    _checkPermission();
  }

  Future<void> _checkPermission() async {
    final status = await AlarmService().checkPermissionStatus();
    if (mounted) {
      setState(() {
        _hasNotificationPermission = status;
      });
    }
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
    _ageController.dispose();
    _weightController.dispose();
    _dailyGoalController.dispose();
    _preset1Controller.dispose();
    _preset2Controller.dispose();
    _preset3Controller.dispose();
    super.dispose();
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
    // 1. First Confirmation Dialog
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
                // Trigger 2nd Final Confirmation Dialog
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

  // 2. Second and Final Confirmation Dialog
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

          // 🌙 Appearance & Theme Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1C2541) : Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: isDark ? const Color(0xFF3A506B) : Colors.blue.shade50,
              ),
              boxShadow: [
                BoxShadow(
                  color: isDark ? Colors.black26 : Colors.blue.shade900.withValues(alpha: 0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Görünüm & Efektler 🎨',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isDark ? const Color(0xFFF1F5F9) : Colors.blue.shade900,
                      ),
                    ),
                    Icon(
                      isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                      color: const Color(0xFF38BDF8),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Dark Theme Toggle
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
                  activeColor: const Color(0xFF38BDF8),
                  onChanged: (val) {
                    provider.updateThemeMode(val ? ThemeMode.dark : ThemeMode.light);
                  },
                ),
                const Divider(height: 16, thickness: 0.5),

                // Sound & Haptic Effects Toggle
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
                  activeColor: const Color(0xFF38BDF8),
                  onChanged: (val) {
                    provider.updateSoundEffectsEnabled(val);
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Daily Goal Customization Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1C2541) : Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: isDark ? const Color(0xFF3A506B) : Colors.blue.shade50,
              ),
              boxShadow: [
                BoxShadow(
                  color: isDark ? Colors.black26 : Colors.blue.shade900.withValues(alpha: 0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Günlük Su Hedefi 🎯',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isDark ? const Color(0xFFF1F5F9) : Colors.blue.shade900,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF0B132B) : Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isDark ? const Color(0xFF3A506B) : Colors.blue.shade100,
                        ),
                      ),
                      child: Text(
                        '${provider.dailyGoal} ml',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isDark ? const Color(0xFF38BDF8) : Colors.blue.shade800,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'İstediğiniz günlük hedef miktarını serbestçe belirleyin veya otomatik hesaplama seçeneğini kullanın.',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? const Color(0xFF94A3B8) : Colors.grey,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 16),

                // Goal Input Field
                TextField(
                  controller: _dailyGoalController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Günlük Hedef Miktarı',
                    suffixText: 'ml',
                    filled: true,
                    fillColor: isDark ? const Color(0xFF0B132B) : Colors.blue.shade50.withValues(alpha: 0.2),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: isDark ? const Color(0xFF3A506B) : Colors.blue.shade100,
                      ),
                    ),
                    prefixIcon: const Icon(Icons.water_drop, color: Color(0xFF0288D1)),
                  ),
                ),
                const SizedBox(height: 12),

                // Quick Preset Chips (2000, 2500, 3000, 3500 ml)
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [2000, 2500, 3000, 3500].map((amount) {
                    return ActionChip(
                      label: Text('$amount ml'),
                      labelStyle: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: isDark ? const Color(0xFFF1F5F9) : Colors.blue.shade900,
                      ),
                      backgroundColor: isDark
                          ? const Color(0xFF0B132B)
                          : Colors.blue.shade50.withValues(alpha: 0.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: BorderSide(
                          color: isDark ? const Color(0xFF3A506B) : Colors.blue.shade100,
                        ),
                      ),
                      onPressed: () {
                        setState(() {
                          _dailyGoalController.text = amount.toString();
                        });
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 12),

                // Auto Calculate Button
                OutlinedButton.icon(
                  onPressed: _autoCalculateGoal,
                  icon: const Icon(Icons.auto_awesome, size: 16),
                  label: const Text(
                    'Kilo ve Yaşıma Göre Önerilen Hedefi Hesapla',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF0288D1),
                    side: BorderSide(
                      color: isDark ? const Color(0xFF38BDF8) : Colors.blue.shade200,
                    ),
                    minimumSize: const Size(double.infinity, 40),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Save Goal Button
                ElevatedButton(
                  onPressed: _saveDailyGoal,
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
                    'Günlük Hedefi Kaydet',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Profile Update Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1C2541) : Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: isDark ? const Color(0xFF3A506B) : Colors.blue.shade50,
              ),
              boxShadow: [
                BoxShadow(
                  color: isDark ? Colors.black26 : Colors.blue.shade900.withValues(alpha: 0.01),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Profil Bilgilerini Güncelle',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDark ? const Color(0xFFF1F5F9) : Colors.blue.shade900,
                  ),
                ),
                const SizedBox(height: 20),

                // Gender Choice
                Text(
                  'Cinsiyet',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: isDark ? const Color(0xFF94A3B8) : Colors.grey,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: ['Erkek', 'Kadın', 'Diğer'].map((g) {
                    final isSelected = _selectedGender == g;
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              _selectedGender = g;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? const Color(0xFF0288D1)
                                  : (isDark ? const Color(0xFF0B132B) : Colors.blue.shade50.withValues(alpha: 0.4)),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: isSelected
                                    ? const Color(0xFF0288D1)
                                    : (isDark ? const Color(0xFF3A506B) : Colors.blue.shade100),
                              ),
                            ),
                            child: Center(
                              child: Text(
                                g,
                                style: TextStyle(
                                  color: isSelected
                                      ? Colors.white
                                      : (isDark ? const Color(0xFFF1F5F9) : Colors.blue.shade900),
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

                // Age & Weight Row
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Yaş',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: isDark ? const Color(0xFF94A3B8) : Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _ageController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              suffixText: 'yıl',
                              filled: true,
                              fillColor: isDark ? const Color(0xFF0B132B) : Colors.blue.shade50.withValues(alpha: 0.2),
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
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Kilo',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: isDark ? const Color(0xFF94A3B8) : Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _weightController,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            decoration: InputDecoration(
                              suffixText: 'kg',
                              filled: true,
                              fillColor: isDark ? const Color(0xFF0B132B) : Colors.blue.shade50.withValues(alpha: 0.2),
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
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Save button
                ElevatedButton(
                  onPressed: _saveProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0288D1),
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Değişiklikleri Kaydet',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Notification Settings Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1C2541) : Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: isDark ? const Color(0xFF3A506B) : Colors.blue.shade50,
              ),
              boxShadow: [
                BoxShadow(
                  color: isDark ? Colors.black26 : Colors.blue.shade900.withValues(alpha: 0.01),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Bildirim ve Alarm Ayarları',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isDark ? const Color(0xFFF1F5F9) : Colors.blue.shade900,
                      ),
                    ),
                    const Icon(Icons.notifications_active_outlined, color: Color(0xFF38BDF8)),
                  ],
                ),
                const SizedBox(height: 20),

                // System Permission Indicator
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: _hasNotificationPermission
                        ? (isDark ? const Color(0xFF064E3B) : Colors.green.shade50.withValues(alpha: 0.4))
                        : (isDark ? const Color(0xFF7C2D12) : Colors.orange.shade50.withValues(alpha: 0.4)),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: _hasNotificationPermission
                          ? (isDark ? Colors.green.shade700 : Colors.green.shade100)
                          : (isDark ? Colors.orange.shade700 : Colors.orange.shade200),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _hasNotificationPermission ? Icons.check_circle_outline : Icons.warning_amber_rounded,
                        color: _hasNotificationPermission ? Colors.greenAccent : Colors.orangeAccent,
                        size: 18,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _hasNotificationPermission
                              ? 'Telefon bildirim izinleri aktif.'
                              : 'Telefon bildirim izinleri kapalı! Alarmlar çalmayabilir.',
                          style: TextStyle(
                            fontSize: 12,
                            color: _hasNotificationPermission
                                ? (isDark ? const Color(0xFFF1F5F9) : Colors.green.shade900)
                                : (isDark ? const Color(0xFFF1F5F9) : Colors.orange.shade900),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      if (!_hasNotificationPermission)
                        TextButton(
                          onPressed: () async {
                            final result = await AlarmService().requestPermission();
                            setState(() {
                              _hasNotificationPermission = result;
                            });
                          },
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            foregroundColor: const Color(0xFF38BDF8),
                          ),
                          child: const Text(
                            'İzin İste',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Global Notification Switch
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    'Su Hatırlatıcı Bildirimleri',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isDark ? const Color(0xFFF1F5F9) : Colors.blue.shade900,
                    ),
                  ),
                  subtitle: Text(
                    'Gün içindeki tüm hatırlatıcıları açar/kapatır.',
                    style: TextStyle(fontSize: 11, color: isDark ? const Color(0xFF94A3B8) : Colors.grey),
                  ),
                  value: provider.isNotificationsEnabled,
                  activeColor: const Color(0xFF0288D1),
                  onChanged: (val) {
                    provider.updateNotificationSettings(
                      isEnabled: val,
                      sound: provider.isSoundEnabled,
                      vibration: provider.isVibrationEnabled,
                    );
                  },
                ),
                const Divider(height: 16, thickness: 0.5),

                // Sound Toggle
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    'Sesli Uyarı',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isDark ? const Color(0xFFF1F5F9) : Colors.blue.shade900,
                    ),
                  ),
                  subtitle: Text(
                    'Alarm çaldığında zil sesi çalar.',
                    style: TextStyle(fontSize: 11, color: isDark ? const Color(0xFF94A3B8) : Colors.grey),
                  ),
                  value: provider.isSoundEnabled,
                  activeColor: const Color(0xFF0288D1),
                  onChanged: provider.isNotificationsEnabled
                      ? (val) {
                          provider.updateNotificationSettings(
                            isEnabled: provider.isNotificationsEnabled,
                            sound: val,
                            vibration: provider.isVibrationEnabled,
                          );
                        }
                      : null,
                ),
                const Divider(height: 16, thickness: 0.5),

                // Vibration Toggle
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    'Titreşim',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isDark ? const Color(0xFFF1F5F9) : Colors.blue.shade900,
                    ),
                  ),
                  subtitle: Text(
                    'Alarm çaldığında telefon titrer.',
                    style: TextStyle(fontSize: 11, color: isDark ? const Color(0xFF94A3B8) : Colors.grey),
                  ),
                  value: provider.isVibrationEnabled,
                  activeColor: const Color(0xFF0288D1),
                  onChanged: provider.isNotificationsEnabled
                      ? (val) {
                          provider.updateNotificationSettings(
                            isEnabled: provider.isNotificationsEnabled,
                            sound: provider.isSoundEnabled,
                            vibration: val,
                          );
                        }
                      : null,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // End of Day Summary Notification Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1C2541) : Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: isDark ? const Color(0xFF3A506B) : Colors.blue.shade50,
              ),
              boxShadow: [
                BoxShadow(
                  color: isDark ? Colors.black26 : Colors.blue.shade900.withValues(alpha: 0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Gün Sonu Özet Bildirimi',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isDark ? const Color(0xFFF1F5F9) : Colors.blue.shade900,
                      ),
                    ),
                    const Text('🌙', style: TextStyle(fontSize: 20)),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Günün belirlediğiniz saatinde o gün içtiğiniz ve hedefinize ulaşmak için kalan su miktarını bildirim olarak iletir.',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? const Color(0xFF94A3B8) : Colors.grey,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 16),

                // Switch
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    'Gün Sonu Özeti',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isDark ? const Color(0xFFF1F5F9) : Colors.blue.shade900,
                    ),
                  ),
                  subtitle: Text(
                    provider.isEndOfDayEnabled ? 'Her gün belirlenen saatte iletilecek' : 'Kapalı',
                    style: TextStyle(fontSize: 11, color: isDark ? const Color(0xFF94A3B8) : Colors.grey),
                  ),
                  value: provider.isEndOfDayEnabled,
                  activeColor: const Color(0xFF0288D1),
                  onChanged: (val) {
                    provider.updateEndOfDaySettings(
                      isEnabled: val,
                      hour: provider.endOfDayHour,
                      minute: provider.endOfDayMinute,
                    );
                  },
                ),

                if (provider.isEndOfDayEnabled) ...[
                  const Divider(height: 16, thickness: 0.5),
                  InkWell(
                    onTap: () async {
                      final time = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay(
                          hour: provider.endOfDayHour,
                          minute: provider.endOfDayMinute,
                        ),
                        builder: (context, child) {
                          return MediaQuery(
                            data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
                            child: child ?? const SizedBox.shrink(),
                          );
                        },
                      );
                      if (time != null) {
                        provider.updateEndOfDaySettings(
                          isEnabled: true,
                          hour: time.hour,
                          minute: time.minute,
                        );
                      }
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.access_time_rounded,
                                size: 20,
                                color: isDark ? const Color(0xFF38BDF8) : Colors.blue.shade700,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Bildirim Saati',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: isDark ? const Color(0xFFF1F5F9) : Colors.blue.shade900,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF0B132B) : Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: isDark ? const Color(0xFF3A506B) : Colors.blue.shade100,
                              ),
                            ),
                            child: Row(
                              children: [
                                Text(
                                  '${provider.endOfDayHour.toString().padLeft(2, '0')}:${provider.endOfDayMinute.toString().padLeft(2, '0')}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: isDark ? const Color(0xFF38BDF8) : Colors.blue.shade800,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Icon(
                                  Icons.edit_outlined,
                                  size: 14,
                                  color: isDark ? const Color(0xFF38BDF8) : Colors.blue.shade700,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],

                const Divider(height: 24, thickness: 0.5),

                // Sleep & Health Water Tip Notification Action
                InkWell(
                  onTap: () {
                    provider.sendSleepTipNotification();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Uyku & Su bildirimi bildirim çubuğunuza gönderildi! 🌙'),
                        duration: Duration(seconds: 2),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF0B132B) : Colors.blue.shade50.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isDark ? const Color(0xFF3A506B) : Colors.blue.shade100,
                      ),
                    ),
                    child: Row(
                      children: [
                        const Text('💤', style: TextStyle(fontSize: 16)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Kaliteli Uyku İpucu Bildirimi',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? const Color(0xFFF1F5F9) : Colors.blue.shade900,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '"Uyumadan 2 saat önce su alımını tamamla!" uyarısı',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: isDark ? const Color(0xFF94A3B8) : Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 6),
                        Icon(
                          Icons.send_rounded,
                          size: 18,
                          color: isDark ? const Color(0xFF38BDF8) : Colors.blue.shade700,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Custom Presets Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1C2541) : Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: isDark ? const Color(0xFF3A506B) : Colors.blue.shade50,
              ),
              boxShadow: [
                BoxShadow(
                  color: isDark ? Colors.black26 : Colors.blue.shade900.withValues(alpha: 0.01),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Hızlı Su Ekleme Miktarları',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isDark ? const Color(0xFFF1F5F9) : Colors.blue.shade900,
                      ),
                    ),
                    const Icon(Icons.local_drink_outlined, color: Color(0xFF38BDF8)),
                  ],
                ),
                const SizedBox(height: 8),
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
                    // Preset 1
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Text('🥛', style: TextStyle(fontSize: 14)),
                              const SizedBox(width: 3),
                              Expanded(
                                child: Text(
                                  'Bardak',
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
                            controller: _preset1Controller,
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
                    ),
                    const SizedBox(width: 8),

                    // Preset 2
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Text('🥤', style: TextStyle(fontSize: 14)),
                              const SizedBox(width: 3),
                              Expanded(
                                child: Text(
                                  'Küçük Şişe',
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
                            controller: _preset2Controller,
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
                    ),
                    const SizedBox(width: 8),

                    // Preset 3
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Text('🌊', style: TextStyle(fontSize: 14)),
                              const SizedBox(width: 3),
                              Expanded(
                                child: Text(
                                  'Büyük Şişe',
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
                            controller: _preset3Controller,
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
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Save button
                ElevatedButton(
                  onPressed: _savePresets,
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
            ),
          ),
          const SizedBox(height: 24),

          // Target recalculation info box
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

          // Danger zone Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF3B1219) : Colors.red.shade50.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: isDark ? Colors.red.shade900 : Colors.red.shade100.withValues(alpha: 0.5),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tehlikeli Alan',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.red.shade300 : Colors.red.shade800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Uygulamadaki tüm kayıtları ve ayarları kalıcı olarak silip temiz kurulum sayfasına geri dönebilirsiniz.',
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? const Color(0xFFFCA5A5) : Colors.grey,
                  ),
                ),
                const SizedBox(height: 16),
                OutlinedButton(
                  onPressed: () => _confirmReset(context, isDark),
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
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
