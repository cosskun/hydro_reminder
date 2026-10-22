import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/alarm_setting.dart';
import '../../providers/water_provider.dart';
import '../../services/sound_service.dart';

void showAlarmEditDialog(BuildContext context, [AlarmSetting? existingAlarm]) {
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
  final theme = Theme.of(context);
  final isDark = theme.brightness == Brightness.dark;

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
                      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF0B132B) : theme.colorScheme.primary.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isDark ? const Color(0xFF3A506B) : theme.colorScheme.primary.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Text(
                              'Saat Seçin:',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: isDark ? const Color(0xFF94A3B8) : Colors.black87,
                              ),
                            ),
                          ),
                          Text(
                            '${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              color: theme.colorScheme.primary,
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
                      fillColor: isDark ? const Color(0xFF0B132B) : theme.colorScheme.primary.withValues(alpha: 0.05),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: isDark ? const Color(0xFF3A506B) : theme.colorScheme.primary.withValues(alpha: 0.2),
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
                      color: isDark ? const Color(0xFFF1F5F9) : const Color(0xFF0F172A),
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
                            ? (isDark ? const Color(0xFF0B132B) : theme.colorScheme.primary.withValues(alpha: 0.1))
                            : (isDark ? const Color(0xFF1C2541) : Colors.white),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? theme.colorScheme.primary
                              : (isDark ? const Color(0xFF3A506B) : Colors.grey.shade200),
                          width: isSelected ? 1.5 : 1.0,
                        ),
                      ),
                      child: Material(
                        type: MaterialType.transparency,
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
                                  ? theme.colorScheme.primary
                                  : (isDark ? const Color(0xFFF1F5F9) : Colors.black87),
                            ),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                              icon: Icon(
                                isPlaying ? Icons.stop_circle_rounded : Icons.play_circle_fill_rounded,
                                color: theme.colorScheme.primary,
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
                              activeColor: theme.colorScheme.primary,
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
                            color: isCustomSound ? Colors.greenAccent : theme.colorScheme.primary,
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
                                        : (isDark ? const Color(0xFFF1F5F9) : const Color(0xFF0F172A)),
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
                        backgroundColor: theme.colorScheme.primary,
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
