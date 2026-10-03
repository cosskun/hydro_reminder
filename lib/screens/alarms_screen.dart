import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/alarm_setting.dart';
import '../providers/water_provider.dart';
import '../services/sound_service.dart';

class AlarmsScreen extends StatelessWidget {
  const AlarmsScreen({super.key});

  void _showAddOrEditAlarmDialog(BuildContext context, [AlarmSetting? existingAlarm]) {
    TimeOfDay selectedTime = existingAlarm != null
        ? TimeOfDay(hour: existingAlarm.hour, minute: existingAlarm.minute)
        : TimeOfDay.now();
    final labelController = TextEditingController(
      text: existingAlarm?.label ?? 'Su Zamanı 💧',
    );

    String selectedSoundName = existingAlarm?.soundName ?? 'Su Damlası 💧';
    String selectedSoundPath = existingAlarm?.soundPath ?? 'assets/sounds/sound_water_drop.wav';
    bool isCustomSound = existingAlarm?.isCustomSound ?? false;
    String? currentlyPlayingPath;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              backgroundColor: isDark ? const Color(0xFF1C2541) : Colors.white,
              title: Text(
                existingAlarm != null ? 'Alarmı Düzenle ⏰' : 'Yeni Alarm Ekle ⏰',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isDark ? const Color(0xFFF1F5F9) : const Color(0xFF0F172A),
                ),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Time Selector Button
                    InkWell(
                      onTap: () async {
                        final time = await showTimePicker(
                          context: context,
                          initialTime: selectedTime,
                          builder: (context, child) {
                            return MediaQuery(
                              data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
                              child: child ?? const SizedBox.shrink(),
                            );
                          },
                        );
                        if (time != null) {
                          setState(() {
                            selectedTime = time;
                          });
                        }
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF0B132B) : Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isDark ? const Color(0xFF3A506B) : Colors.blue.shade100,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Saat Seçin:',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: isDark ? const Color(0xFF94A3B8) : Colors.black87,
                              ),
                            ),
                            Text(
                              '${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w900,
                                color: isDark ? const Color(0xFF38BDF8) : Colors.blue.shade800,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Label TextField
                    TextField(
                      controller: labelController,
                      decoration: InputDecoration(
                        labelText: 'Alarm Başlığı',
                        filled: true,
                        fillColor: isDark ? const Color(0xFF0B132B) : Colors.blue.shade50.withValues(alpha: 0.3),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: isDark ? const Color(0xFF3A506B) : Colors.blue.shade100,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Sound Selection Header
                    Text(
                      'Alarm Sesi Seçin 🎵',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: isDark ? const Color(0xFFF1F5F9) : Colors.blue.shade900,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Presets List
                    ...SoundService.presetSounds.map((preset) {
                      final assetPath = 'assets/${preset.path}';
                      final isSelected = !isCustomSound && selectedSoundPath == assetPath;
                      final isPlaying = currentlyPlayingPath == assetPath;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 6),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? (isDark ? const Color(0xFF0B132B) : Colors.blue.shade50)
                              : (isDark ? const Color(0xFF1C2541) : Colors.white),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected
                                ? (isDark ? const Color(0xFF38BDF8) : Colors.blue.shade400)
                                : (isDark ? const Color(0xFF3A506B) : Colors.grey.shade200),
                            width: isSelected ? 1.5 : 1.0,
                          ),
                        ),
                        child: ListTile(
                          dense: true,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                          leading: Text(preset.icon, style: const TextStyle(fontSize: 20)),
                          title: Text(
                            preset.name,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                              color: isSelected
                                  ? (isDark ? const Color(0xFF38BDF8) : Colors.blue.shade900)
                                  : (isDark ? const Color(0xFFF1F5F9) : Colors.black87),
                            ),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(
                                  isPlaying ? Icons.stop_circle_rounded : Icons.play_circle_fill_rounded,
                                  color: isDark ? const Color(0xFF38BDF8) : Colors.blue.shade600,
                                  size: 26,
                                ),
                                onPressed: () async {
                                  if (isPlaying) {
                                    await SoundService().stopSound();
                                    setState(() {
                                      currentlyPlayingPath = null;
                                    });
                                  } else {
                                    await SoundService().playAlarmSound(
                                      soundPath: assetPath,
                                      isCustomSound: false,
                                      loop: false,
                                    );
                                    setState(() {
                                      currentlyPlayingPath = assetPath;
                                    });
                                  }
                                },
                              ),
                              Radio<String>(
                                value: assetPath,
                                groupValue: isCustomSound ? null : selectedSoundPath,
                                activeColor: isDark ? const Color(0xFF38BDF8) : Colors.blue.shade700,
                                onChanged: (val) {
                                  if (val != null) {
                                    setState(() {
                                      selectedSoundPath = val;
                                      selectedSoundName = '${preset.name} ${preset.icon}';
                                      isCustomSound = false;
                                    });
                                  }
                                },
                              ),
                            ],
                          ),
                          onTap: () {
                            setState(() {
                              selectedSoundPath = assetPath;
                              selectedSoundName = '${preset.name} ${preset.icon}';
                              isCustomSound = false;
                            });
                          },
                        ),
                      );
                    }),

                    const SizedBox(height: 6),

                    // Pick Custom Sound from Phone
                    InkWell(
                      onTap: () async {
                        final file = await SoundService().pickCustomAudio();
                        if (file != null && file.path != null) {
                          setState(() {
                            selectedSoundName = file.name;
                            selectedSoundPath = file.path!;
                            isCustomSound = true;
                          });
                          await SoundService().playAlarmSound(
                            soundPath: file.path!,
                            isCustomSound: true,
                            loop: false,
                          );
                          setState(() {
                            currentlyPlayingPath = file.path;
                          });
                        }
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                        decoration: BoxDecoration(
                          color: isCustomSound
                              ? (isDark ? const Color(0xFF064E3B) : Colors.green.shade50)
                              : (isDark ? const Color(0xFF0B132B) : Colors.grey.shade50),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isCustomSound
                                ? (isDark ? Colors.greenAccent : Colors.green.shade400)
                                : (isDark ? const Color(0xFF3A506B) : Colors.grey.shade300),
                            width: isCustomSound ? 1.5 : 1.0,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.folder_open_rounded,
                              color: isCustomSound ? Colors.greenAccent : (isDark ? const Color(0xFF38BDF8) : Colors.blue.shade700),
                              size: 22,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    isCustomSound ? selectedSoundName : 'Telefonumdan Ses Seç 📁',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: isCustomSound
                                          ? (isDark ? const Color(0xFFF1F5F9) : Colors.green.shade900)
                                          : (isDark ? const Color(0xFFF1F5F9) : Colors.blue.shade900),
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    isCustomSound ? 'Özel seçilmiş ses' : 'Cihazınızdaki MP3/WAV seslerini kullanın',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: isDark ? const Color(0xFF94A3B8) : Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (isCustomSound)
                              IconButton(
                                icon: Icon(
                                  currentlyPlayingPath == selectedSoundPath
                                      ? Icons.stop_circle_rounded
                                      : Icons.play_circle_fill_rounded,
                                  color: Colors.greenAccent,
                                  size: 24,
                                ),
                                onPressed: () async {
                                  if (currentlyPlayingPath == selectedSoundPath) {
                                    await SoundService().stopSound();
                                    setState(() {
                                      currentlyPlayingPath = null;
                                    });
                                  } else {
                                    await SoundService().playAlarmSound(
                                      soundPath: selectedSoundPath,
                                      isCustomSound: true,
                                      loop: false,
                                    );
                                    setState(() {
                                      currentlyPlayingPath = selectedSoundPath;
                                    });
                                  }
                                },
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actionsPadding: const EdgeInsets.only(bottom: 16, right: 16, left: 16),
              actions: [
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () {
                          SoundService().stopSound();
                          Navigator.pop(context);
                        },
                        child: Text('Vazgeç', style: TextStyle(color: isDark ? Colors.grey.shade400 : Colors.grey.shade600)),
                      ),
                    ),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          SoundService().stopSound();
                          final provider = Provider.of<WaterProvider>(context, listen: false);
                          final label = labelController.text.trim().isEmpty
                              ? 'Su Zamanı'
                              : labelController.text.trim();

                          if (existingAlarm != null) {
                            provider.editAlarm(
                              id: existingAlarm.id,
                              hour: selectedTime.hour,
                              minute: selectedTime.minute,
                              label: label,
                              soundName: selectedSoundName,
                              soundPath: selectedSoundPath,
                              isCustomSound: isCustomSound,
                            );
                          } else {
                            provider.addAlarm(
                              hour: selectedTime.hour,
                              minute: selectedTime.minute,
                              label: label,
                              soundName: selectedSoundName,
                              soundPath: selectedSoundPath,
                              isCustomSound: isCustomSound,
                            );
                          }
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0288D1),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Kaydet'),
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        );
      },
    ).then((_) {
      SoundService().stopSound();
    });
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Hatırlatıcı Alarmlar ⏰',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: isDark ? const Color(0xFFF1F5F9) : Colors.blue.shade900,
                ),
              ),
              IconButton(
                onPressed: () => _showAddOrEditAlarmDialog(context),
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: Color(0xFF0288D1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.add, color: Colors.white, size: 20),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Belirlediğiniz saatlerde tam ekran kapatılamayan akıllı alarmlar çalar.',
            style: TextStyle(
              color: isDark ? const Color(0xFF94A3B8) : Colors.grey,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 20),

          // List of Alarms
          if (provider.alarms.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(40),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1C2541) : Colors.blue.shade50.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isDark ? const Color(0xFF3A506B) : Colors.blue.shade50,
                ),
              ),
              child: Column(
                children: [
                  const Text('🔔', style: TextStyle(fontSize: 40)),
                  const SizedBox(height: 12),
                  Text(
                    'Kayıtlı alarm bulunmuyor.',
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? const Color(0xFFF1F5F9) : Colors.blue.shade900.withValues(alpha: 0.5),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Sağ üstteki "+" butonuna basarak ekleyin.',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? const Color(0xFF94A3B8) : Colors.grey,
                    ),
                  ),
                ],
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: provider.alarms.length,
              itemBuilder: (context, index) {
                final alarm = provider.alarms[index];
                return InkWell(
                  onTap: () => _showAddOrEditAlarmDialog(context, alarm),
                  borderRadius: BorderRadius.circular(16),
                  child: Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(
                        color: isDark ? const Color(0xFF3A506B) : Colors.blue.shade50,
                      ),
                    ),
                    color: isDark ? const Color(0xFF1C2541) : Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Row(
                        children: [
                          Icon(
                            Icons.alarm_rounded,
                            color: alarm.isEnabled ? const Color(0xFF38BDF8) : (isDark ? const Color(0xFF64748B) : Colors.grey.shade400),
                            size: 28,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  alarm.timeFormatted,
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w900,
                                    color: alarm.isEnabled
                                        ? (isDark ? const Color(0xFFF1F5F9) : Colors.blue.shade900)
                                        : (isDark ? const Color(0xFF64748B) : Colors.grey.shade600),
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Wrap(
                                  spacing: 6,
                                  runSpacing: 4,
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  children: [
                                    Text(
                                      alarm.label,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: isDark ? const Color(0xFF94A3B8) : Colors.grey.shade600,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: isDark ? const Color(0xFF0B132B) : Colors.blue.shade50,
                                        borderRadius: BorderRadius.circular(6),
                                        border: Border.all(
                                          color: isDark ? const Color(0xFF3A506B) : Colors.transparent,
                                        ),
                                      ),
                                      child: Text(
                                        alarm.soundName,
                                        style: TextStyle(
                                          fontSize: 9.5,
                                          fontWeight: FontWeight.bold,
                                          color: isDark ? const Color(0xFF38BDF8) : Colors.blue.shade700,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 6),
                          // Toggle switch
                          Switch(
                            value: alarm.isEnabled,
                            activeThumbColor: const Color(0xFF38BDF8),
                            activeTrackColor: const Color(0xFF0288D1),
                            inactiveThumbColor: isDark ? const Color(0xFF64748B) : Colors.grey.shade400,
                            inactiveTrackColor: isDark ? const Color(0xFF0B132B) : Colors.grey.shade200,
                            onChanged: (val) {
                              provider.toggleAlarm(alarm.id, val);
                            },
                          ),
                          // Delete icon
                          IconButton(
                            padding: const EdgeInsets.all(4),
                            constraints: const BoxConstraints(),
                            icon: Icon(
                              Icons.delete_outline_rounded,
                              color: Colors.red.shade300,
                              size: 20,
                            ),
                            onPressed: () {
                              provider.deleteAlarm(alarm.id);
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}
