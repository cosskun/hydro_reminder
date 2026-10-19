import 'package:audioplayers/audioplayers.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class PresetSound {
  final String name;
  final String icon;
  final String path;

  const PresetSound({
    required this.name,
    required this.icon,
    required this.path,
  });
}

class SoundService {
  static final SoundService _instance = SoundService._internal();
  factory SoundService() => _instance;
  SoundService._internal();

  static const MethodChannel _hapticsChannel =
      MethodChannel('com.antigravity.hydroReminder/alarm_haptics');

  final AudioPlayer _alarmPlayer = AudioPlayer();
  final AudioPlayer _effectPlayer = AudioPlayer();

  static const List<PresetSound> presetSounds = [
    PresetSound(
      name: 'Su Damlası',
      icon: '💧',
      path: 'sounds/sound_water_drop.wav',
    ),
    PresetSound(
      name: 'Okyanus Dalgası',
      icon: '🌊',
      path: 'sounds/sound_ocean_waves.wav',
    ),
    PresetSound(
      name: 'Kristal Çan',
      icon: '🔔',
      path: 'sounds/sound_crystal_bell.wav',
    ),
    PresetSound(
      name: 'Doğa & Kuşlar',
      icon: '🌿',
      path: 'sounds/sound_nature_birds.wav',
    ),
    PresetSound(
      name: 'Enerjik Melodi',
      icon: '✨',
      path: 'sounds/sound_energy_chime.wav',
    ),
  ];

  // Trigger native hardware vibration + Taptic Engine burst (works in Silent Mode on both iOS & Android)
  Future<void> triggerAlarmVibration() async {
    try {
      await _alarmPlayer.stop();
    } catch (_) {}

    try {
      HapticFeedback.vibrate();
      HapticFeedback.heavyImpact();
      if (!kIsWeb &&
          (defaultTargetPlatform == TargetPlatform.iOS ||
              defaultTargetPlatform == TargetPlatform.android)) {
        await _hapticsChannel.invokeMethod('vibrateAlarm');
      }
    } catch (_) {}
  }

  // Play alarm sound (looping or single)
  Future<void> playAlarmSound({
    required String soundPath,
    required bool isCustomSound,
    bool loop = true,
  }) async {
    try {
      await _alarmPlayer.stop();

      // On Android, check if the device ringer is in Silent or Vibrate mode so we mute audio and only vibrate (matching iOS)
      if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
        try {
          final isSilent =
              await _hapticsChannel.invokeMethod<bool>('isSilentMode');
          if (isSilent == true) {
            return;
          }
        } catch (_) {}
      }

      // Respect silent switch on iOS so silent mode mutes audio and never blocks hardware vibration
      try {
        await _alarmPlayer.setAudioContext(
          AudioContextConfig(
            respectSilence: true,
            stayAwake: false,
          ).build(),
        );
      } catch (_) {}

      if (loop) {
        await _alarmPlayer.setReleaseMode(ReleaseMode.loop);
      } else {
        await _alarmPlayer.setReleaseMode(ReleaseMode.release);
      }

      if (isCustomSound) {
        await _alarmPlayer.play(DeviceFileSource(soundPath));
      } else {
        String cleanPath = soundPath;
        if (cleanPath.startsWith('assets/')) {
          cleanPath = cleanPath.substring(7);
        }
        await _alarmPlayer.play(AssetSource(cleanPath));
      }
    } catch (_) {
      // Fallback
    }
  }

  // Play water sip / pour sound effect
  Future<void> playWaterSipSound() async {
    try {
      await _effectPlayer.stop();
      await _effectPlayer.setReleaseMode(ReleaseMode.release);
      await _effectPlayer.play(AssetSource('sounds/sound_water_drop.wav'));
    } catch (_) {}
  }

  // Play badge celebration chime sound effect
  Future<void> playBadgeCelebrationSound() async {
    try {
      await _effectPlayer.stop();
      await _effectPlayer.setReleaseMode(ReleaseMode.release);
      await _effectPlayer.play(AssetSource('sounds/sound_energy_chime.wav'));
    } catch (_) {}
  }

  // Stop currently playing sound
  Future<void> stopSound() async {
    try {
      await _alarmPlayer.stop();
      await _effectPlayer.stop();
    } catch (_) {}
  }

  // Pick audio file from device storage
  Future<PlatformFile?> pickCustomAudio() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.audio,
        allowMultiple: false,
      );
      if (result != null && result.files.isNotEmpty) {
        return result.files.first;
      }
    } catch (_) {}
    return null;
  }
}
