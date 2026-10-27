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

  String localizedName(String lang) {
    if (lang == 'en') {
      switch (name) {
        case 'Çalar Saat & Melodi (Alarm)':
          return 'Alarm Clock Ring';
        case 'Su Damlası':
          return 'Water Drop';
        case 'Okyanus Dalgası':
          return 'Ocean Waves';
        case 'Kristal Çan':
          return 'Crystal Bell';
        case 'Doğa & Kuşlar':
          return 'Nature & Birds';
        case 'Enerjik Melodi':
          return 'Energetic Melody';
        case 'Huzurlu Yağmur':
          return 'Gentle Rain';
        case 'Nehir Akıntısı':
          return 'River Stream';
        default:
          return name;
      }
    }
    return name;
  }
}

class SoundService {
  static final SoundService _instance = SoundService._internal();
  factory SoundService() => _instance;
  SoundService._internal() {
    _initAudioContexts();
  }

  static const MethodChannel _hapticsChannel =
      MethodChannel('com.antigravity.hydroReminder/alarm_haptics');

  final AudioPlayer _alarmPlayer = AudioPlayer();
  final AudioPlayer _effectPlayer = AudioPlayer();

  /// AudioContext for UI sound effects (water drops, badges, goal celebrations).
  /// - iOS: [AVAudioSessionCategory.ambient] seamlessly mixes with background music (Spotify, Apple Music, podcasts) without pausing or ducking it.
  /// - Android: [AndroidAudioFocus.none] ensures no audio focus is seized, keeping background media playing uninterrupted.
  static final AudioContext effectAudioContext = AudioContext(
    iOS: AudioContextIOS(
      category: AVAudioSessionCategory.ambient,
      options: const {},
    ),
    android: const AudioContextAndroid(
      isSpeakerphoneOn: false,
      stayAwake: false,
      contentType: AndroidContentType.sonification,
      usageType: AndroidUsageType.assistanceSonification,
      audioFocus: AndroidAudioFocus.none,
    ),
  );

  /// AudioContext for alarms & alarm sound previews.
  /// - iOS: [AVAudioSessionCategory.playback] rings aloud through phone speakers like a real alarm and ducks other audio.
  /// - Android: [AndroidAudioFocus.gainTransientMayDuck] ensures clear, loud alarm playback without terminating user music.
  static final AudioContext alarmAudioContext = AudioContext(
    iOS: AudioContextIOS(
      category: AVAudioSessionCategory.playback,
      options: {
        AVAudioSessionOptions.duckOthers,
      },
    ),
    android: const AudioContextAndroid(
      isSpeakerphoneOn: false,
      stayAwake: false,
      contentType: AndroidContentType.sonification,
      usageType: AndroidUsageType.alarm,
      audioFocus: AndroidAudioFocus.gainTransientMayDuck,
    ),
  );

  /// Initializes audio contexts globally and on individual players
  Future<void> init() async {
    await _initAudioContexts();
  }

  Future<void> _initAudioContexts() async {
    try {
      if (!kIsWeb) {
        await AudioPlayer.global.setAudioContext(effectAudioContext);
        await _effectPlayer.setAudioContext(effectAudioContext);
        await _alarmPlayer.setAudioContext(alarmAudioContext);
      }
    } catch (_) {}
  }

  static const List<PresetSound> presetSounds = [
    PresetSound(
      name: 'Çalar Saat & Melodi (Alarm)',
      icon: '⏰',
      path: 'sounds/sound_alarm_ring.wav',
    ),
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
    PresetSound(
      name: 'Huzurlu Yağmur',
      icon: '🌧️',
      path: 'sounds/sound_gentle_rain.wav',
    ),
    PresetSound(
      name: 'Nehir Akıntısı',
      icon: '🏞️',
      path: 'sounds/sound_river_stream.wav',
    ),
    PresetSound(
      name: 'Tibet Kasesi & Zen',
      icon: '🧘',
      path: 'sounds/sound_tibetan_bowl.wav',
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

      // Apply non-interrupting alarm AudioContext (mixes with music, respects silent mode)
      try {
        await _alarmPlayer.setAudioContext(alarmAudioContext);
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

  // Play water sip / pour sound effect (mixes seamlessly over user music without pausing it)
  Future<void> playWaterSipSound() async {
    try {
      await _effectPlayer.stop();
      try {
        await _effectPlayer.setAudioContext(effectAudioContext);
      } catch (_) {}
      await _effectPlayer.setReleaseMode(ReleaseMode.release);
      await _effectPlayer.play(AssetSource('sounds/sound_water_drop.wav'));
    } catch (_) {}
  }

  // Play badge celebration chime sound effect (mixes seamlessly over user music)
  Future<void> playBadgeCelebrationSound() async {
    try {
      await _effectPlayer.stop();
      try {
        await _effectPlayer.setAudioContext(effectAudioContext);
      } catch (_) {}
      await _effectPlayer.setReleaseMode(ReleaseMode.release);
      await _effectPlayer.play(AssetSource('sounds/sound_energy_chime.wav'));
    } catch (_) {}
  }

  // Play daily goal reached celebration sound effect + multi-stage haptic fanfare
  Future<void> playGoalReachedCelebrationSound() async {
    try {
      HapticFeedback.heavyImpact();
      Future.delayed(const Duration(milliseconds: 140), () => HapticFeedback.mediumImpact());
      Future.delayed(const Duration(milliseconds: 280), () => HapticFeedback.lightImpact());
      await _effectPlayer.stop();
      try {
        await _effectPlayer.setAudioContext(effectAudioContext);
      } catch (_) {}
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
