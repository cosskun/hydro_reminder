import 'package:flutter/material.dart';

/// 10 Contextual & Emotional States for hydration mascots
enum MascotState {
  morning, // 06:00 - 09:30: Waking up, fresh morning glass
  workFocus, // 09:30 - 11:30: Desk work & studying
  lunch, // 11:30 - 14:00: Pre-lunch hydration
  afternoonSlump, // 14:00 - 16:30: Judging side-eye in bed/desk
  workout, // 16:30 - 19:00: Active, sweatband, afternoon energy
  evening, // 19:00 - 21:30: Evening chill, unwinding
  bedtime, // 21:30 - 02:00: Night sleeping cap, "Hadi son bir yudum"
  goalReached, // 100%+ Celebration, trophy, confetti, gold crown
  thirsty, // Critical thirst (0% or > 3.5 hrs since last sip)
  streakFire, // 3+ days streak, flame cape, superpower
}

extension MascotStateExtension on MascotState {
  String get assetSuffix {
    switch (this) {
      case MascotState.morning:
        return 'morning';
      case MascotState.workFocus:
        return 'work_focus';
      case MascotState.lunch:
        return 'lunch';
      case MascotState.afternoonSlump:
        return 'afternoon_slump';
      case MascotState.workout:
        return 'workout';
      case MascotState.evening:
        return 'evening';
      case MascotState.bedtime:
        return 'bedtime';
      case MascotState.goalReached:
        return 'goal_reached';
      case MascotState.thirsty:
        return 'thirsty';
      case MascotState.streakFire:
        return 'streak_fire';
    }
  }
}

/// Mascot character representation
class MascotCharacter {
  final String id;
  final String nameTr;
  final String nameEn;
  final String personalityTr;
  final String personalityEn;
  final String emoji;
  final String defaultImageAsset;

  const MascotCharacter({
    required this.id,
    required this.nameTr,
    required this.nameEn,
    required this.personalityTr,
    required this.personalityEn,
    required this.emoji,
    required this.defaultImageAsset,
  });
}

/// 5 Discrete Hydration Energy Tiers (Su içtikçe kademe kademe şarj olan enerji merdiveni)
enum MascotEnergyTier {
  energy0, // 0% (0 ml): Kupkuru, bitkin, sıfır şarj
  energy25, // 1% - 29% (~500 ml): İlk yudum, toparlanma
  energy50, // 30% - 59% (~1000 ml): Yarı şarj, tatlı canlanma
  energy75, // 60% - 89% (~1500-2000 ml): Yüksek enerji, pırıl pırıl canlılık
  energy100, // 90%+ (2000+ ml): Tam şarj, zirve canlılık
}

extension MascotEnergyTierExtension on MascotEnergyTier {
  int get stepValue {
    switch (this) {
      case MascotEnergyTier.energy0:
        return 0;
      case MascotEnergyTier.energy25:
        return 25;
      case MascotEnergyTier.energy50:
        return 50;
      case MascotEnergyTier.energy75:
        return 75;
      case MascotEnergyTier.energy100:
        return 100;
    }
  }

  String get fileSuffix => 'energy_$stepValue';
}

/// Helper for resolving Hydration Energy Ladder
class MascotEnergyLadder {
  static MascotEnergyTier getTier(double percentage) {
    if (percentage <= 0.0) return MascotEnergyTier.energy0;
    if (percentage < 0.30) return MascotEnergyTier.energy25;
    if (percentage < 0.60) return MascotEnergyTier.energy50;
    if (percentage < 0.90) return MascotEnergyTier.energy75;
    return MascotEnergyTier.energy100;
  }

  static Map<String, String> getDialogue({
    required String mascotId,
    required MascotEnergyTier tier,
    required bool isEn,
  }) {
    if (mascotId == 'cat') {
      switch (tier) {
        case MascotEnergyTier.energy0:
          return {
            'title': isEn ? 'Zero Energy • Dehydrated' : 'Sıfır Enerji • Kupkuru',
            'message': isEn
                ? 'Purrr... Glass is empty, feeling so drained!'
                : 'Miyav... Bardağım bomboş, halıya yapıştım kaldım!',
          };
        case MascotEnergyTier.energy25:
          return {
            'title': isEn ? 'First Sip • Recharging' : 'İlk Yudum • Toparlanıyoruz',
            'message': isEn
                ? 'First sip felt great! Slowly waking up.'
                : 'İlk yudum iyi geldi! Yavaş yavaş gözlerim açılıyor.',
          };
        case MascotEnergyTier.energy50:
          return {
            'title': isEn ? 'Half Energy • Purring' : 'Yarı Enerji • Mırıltı Başladı',
            'message': isEn
                ? 'Purrr! Battery half full, feeling cozy.'
                : 'Mırrr! Yarım depo doldu, tatlı tatlı mırıldanıyorum.',
          };
        case MascotEnergyTier.energy75:
          return {
            'title': isEn ? 'High Vitality • Sparkling' : 'Yüksek Canlılık • Pırıl Pırıl',
            'message': isEn
                ? 'Tail high, energy peaking! Almost at the goal.'
                : 'Kuyruğum dimdik, enerjim harika! Hedefe çok az kaldı.',
          };
        case MascotEnergyTier.energy100:
          return {
            'title': isEn ? 'Full Charge • Peak Energy' : 'Tam Şarj • Zirve Canlılık',
            'message': isEn
                ? 'Fully charged! A sparkling day, thank you! 🌟'
                : 'Tam şarj olduk! Pırıl pırıl bir gün, teşekkürler! 🌟',
          };
      }
    } else if (mascotId == 'dog') {
      switch (tier) {
        case MascotEnergyTier.energy0:
          return {
            'title': isEn ? 'Zero Energy • Dehydrated' : 'Sıfır Enerji • Pili Bitti',
            'message': isEn
                ? 'Woof... Water bowl is dry, no energy to run!'
                : 'Hav... Su kabım bomboş, hiç koşturacak gücüm kalmadı!',
          };
        case MascotEnergyTier.energy25:
          return {
            'title': isEn ? 'First Sip • Recharging' : 'İlk Yudum • Canlanıyoruz',
            'message': isEn
                ? 'First sip felt great! My tail started wagging.'
                : 'İlk yudum iyi geldi! Kuyruğum hafiften sallanmaya başladı.',
          };
        case MascotEnergyTier.energy50:
          return {
            'title': isEn ? 'Half Energy • Joyful' : 'Yarı Enerji • Neşe Geldi',
            'message': isEn
                ? 'Tank half full! Ready for a little playtime!'
                : 'Yarım depo doldu! Keyfim yerine geliyor, biraz oyun vakti!',
          };
        case MascotEnergyTier.energy75:
          return {
            'title': isEn ? 'High Vitality • Sparkling' : 'Yüksek Canlılık • Pırıl Pırıl',
            'message': isEn
                ? 'Going great! Fluffy ears up, energy is high.'
                : 'Harika gidiyoruz! Pofuduk kulaklar dik, enerjim tam yerinde.',
          };
        case MascotEnergyTier.energy100:
          return {
            'title': isEn ? 'Full Charge • Peak Energy' : 'Tam Şarj • Zirve Canlılık',
            'message': isEn
                ? 'Fully charged! Ready to leap with joy in the park! 🎾🌟'
                : 'Tam şarj olduk! Parkta neşeyle zıplamaya hazırım! 🎾🌟',
          };
      }
    } else if (mascotId == 'penguin') {
      switch (tier) {
        case MascotEnergyTier.energy0:
          return {
            'title': isEn ? 'Zero Energy • Ice Melted' : 'Sıfır Enerji • Buzlar Eridi',
            'message': isEn
                ? 'Ice melted, feeling totally drained! Please give me a cold glass of water! 🧊'
                : 'Buzlarım eridi, takatim kalmadı! Lütfen hemen soğuk bir bardak su ver! 🧊',
          };
        case MascotEnergyTier.energy25:
          return {
            'title': isEn ? 'First Sip • Cool Start' : 'İlk Yudum • Serin Başlangıç',
            'message': isEn
                ? 'First ice-cold sip felt amazing! Slowly waddling back to my feet.'
                : 'Buz gibi ilk yudum harika geldi! Yavaş yavaş ayaklanıyorum.',
          };
        case MascotEnergyTier.energy50:
          return {
            'title': isEn ? 'Half Energy • Scarf On' : 'Yarı Enerji • Atkı Takıldı',
            'message': isEn
                ? 'Red scarf on! Tank half full, ready to slide onto the ice rink!'
                : 'Kırmızı atkımı taktım, yarı depoyla buz pistine çıkmaya hazırım!',
          };
        case MascotEnergyTier.energy75:
          return {
            'title': isEn ? 'High Vitality • Glacier Slide' : 'Yüksek Canlılık • Buz Kaydırağı',
            'message': isEn
                ? 'Sunglasses on, belly-sliding straight towards the goal! 🏄❄️'
                : 'Gözlükler takıldı, göbeğimin üstünde hedefe doğru kayıyorum! 🏄❄️',
          };
        case MascotEnergyTier.energy100:
          return {
            'title': isEn ? 'Full Charge • Polar Champion' : 'Tam Şarj • Kutup Şampiyonu',
            'message': isEn
                ? 'Polar wave conquered! At the summit with a crystal chalice, awesome! 👑❄️'
                : 'Kutup dalgasını yakaladık! Kristal kadehle zirvedeyiz, harikasın! 👑❄️',
          };
      }
    } else if (mascotId == 'panda') {
      switch (tier) {
        case MascotEnergyTier.energy0:
          return {
            'title': isEn ? 'Zero Energy • Bamboo Dried' : 'Sıfır Enerji • Bambu Kurudu',
            'message': isEn
                ? 'Collapsed on the cushion! My bamboo cup is dry, need fresh water... 🎋'
                : 'Minderin üstüne yığıldım kaldım! Bambu bardağım bomboş, biraz su ver... 🎋',
          };
        case MascotEnergyTier.energy25:
          return {
            'title': isEn ? 'First Sip • Zen Awakening' : 'İlk Yudum • Zen Uyanış',
            'message': isEn
                ? 'First fresh sip felt peaceful. Slowly opening my eyes, feeling calm.'
                : 'İlk taze yudum iyi geldi. Gözlerimi yavaşça açıyorum, huzur doluyor.',
          };
        case MascotEnergyTier.energy50:
          return {
            'title': isEn ? 'Half Energy • Bamboo Tumbler' : 'Yarı Enerji • Bambu Bardağı',
            'message': isEn
                ? 'Sipping peacefully from my bamboo tumbler. Tank is halfway full!'
                : 'Yeşil bambu bardağımdan tatlı tatlı yudumluyorum. Keyfim yarı yarıya doldu!',
          };
        case MascotEnergyTier.energy75:
          return {
            'title': isEn ? 'High Vitality • Fluffy Power' : 'Yüksek Canlılık • Pofuduk Güç',
            'message': isEn
                ? 'On our feet! Fresh green leaves and cool water got my energy soaring.'
                : 'Ayaktayız! Taze yapraklar ve serin suyla enerjim tavan yaptı.',
          };
        case MascotEnergyTier.energy100:
          return {
            'title': isEn ? 'Full Charge • Zen Master' : 'Tam Şarj • Zen Ustası',
            'message': isEn
                ? 'Fully charged! Our golden bamboo chalice is overflowing, fantastic! 🎋✨'
                : 'Tam şarj olduk! Altın bambu kupamız dolup taştı, harikasın! 🎋✨',
          };
      }
    }

    // Generic Fallback
    switch (tier) {
      case MascotEnergyTier.energy0:
        return {
          'title': isEn ? 'Zero Energy' : 'Sıfır Enerji • Susuz',
          'message': isEn
              ? 'Started dehydrated! Grab a fresh glass of water.'
              : 'Güne susuz başladın! Hemen bir bardak su al.',
        };
      case MascotEnergyTier.energy25:
        return {
          'title': isEn ? 'First Step' : 'İlk Yudum • Başlangıç',
          'message': isEn
              ? 'First step taken! Stepping steadily towards your goal.'
              : 'İlk adımı attın! Yavaş yavaş hedefe ilerliyorsun.',
        };
      case MascotEnergyTier.energy50:
        return {
          'title': isEn ? 'Halfway' : 'Yarı Depo • Canlanıyor',
          'message': isEn
              ? 'Going great! Your body thanks you.'
              : 'Harika gidiyorsun! Vücudun sana teşekkür ediyor.',
        };
      case MascotEnergyTier.energy75:
        return {
          'title': isEn ? 'High Energy' : 'Yüksek Canlılık',
          'message': isEn
              ? 'Almost there! Your energy is peaking.'
              : 'Neredeyse tamamladın! Enerjin tam yerinde.',
        };
      case MascotEnergyTier.energy100:
        return {
          'title': isEn ? 'Fully Charged' : 'Tam Şarj • Harika!',
          'message': isEn
              ? 'Congratulations! You reached your daily goal!'
              : 'Tebrikler! Günlük su hedefini tamamladın!',
        };
    }
  }
}

/// Dialogue & Visual Payload for Widgets, Dashboard and Notifications
class MascotDialogue {
  final String title;
  final String message;
  final String emoji;
  final String imageAsset;
  final MascotState state;
  final String hexColor;
  final String energyImageAsset;
  final int energyPercentage;
  final String energyTitle;
  final String energyMessage;
  final String routineImageAsset;
  final String routineTitle;
  final String routineMessage;

  const MascotDialogue({
    required this.title,
    required this.message,
    required this.emoji,
    required this.imageAsset,
    required this.state,
    this.hexColor = '0284C7',
    this.energyImageAsset = '',
    this.energyPercentage = 0,
    this.energyTitle = '',
    this.energyMessage = '',
    this.routineImageAsset = '',
    this.routineTitle = '',
    this.routineMessage = '',
  });
}

/// The Official Mascots for HydroSoft
class MascotCatalog {
  static const MascotCharacter vitality = MascotCharacter(
    id: 'vitality',
    nameTr: 'Canlılık Yüzleri (Klasik)',
    nameEn: 'Vitality Expressions (Classic)',
    personalityTr: 'Her yudumda neşelenen klasik canlılık ifadeleri.',
    personalityEn: 'Classic vitality expressions that cheer up with each sip.',
    emoji: '🥱',
    defaultImageAsset: 'assets/mascots/cat_morning.png',
  );

  static const MascotCharacter cat = MascotCharacter(
    id: 'cat',
    nameTr: 'Luna (Kedi)',
    nameEn: 'Luna (Cat)',
    personalityTr: 'Uykucu, tatlı ve hafif sitemkar mırıltılı kedi.',
    personalityEn: 'Sleepy, cozy, slightly sassy purring cat.',
    emoji: '🐱',
    defaultImageAsset: 'assets/mascots/cat_morning.png',
  );

  static const MascotCharacter dog = MascotCharacter(
    id: 'dog',
    nameTr: 'Kahverengi Poodle',
    nameEn: 'Brown Poodle',
    personalityTr: 'Kıvırcık pofuduk kahverengi tüyleri ve neşeli enerjisiyle sadık dost.',
    personalityEn: 'Fluffy brown curly poodle with cheerful puppy energy and loyalty.',
    emoji: '🐩',
    defaultImageAsset: 'assets/mascots/dog_morning.png',
  );

  static const MascotCharacter penguin = MascotCharacter(
    id: 'penguin',
    nameTr: 'Kutup Pengueni',
    nameEn: 'Polar Penguin',
    personalityTr: 'Kutup soğukluğunu ve buz gibi suları seven serin dost.',
    personalityEn: 'Loves arctic chill and ice-cold fresh water.',
    emoji: '🐧',
    defaultImageAsset: 'assets/mascots/penguin_morning.png',
  );

  static const MascotCharacter panda = MascotCharacter(
    id: 'panda',
    nameTr: 'Tembel Panda',
    nameEn: 'Zen Panda',
    personalityTr: 'Pofuduk, koltuğunda yayılan zen ve huzur pınarı.',
    personalityEn: 'Fluffy, zen couch potato who sips peacefully.',
    emoji: '🐼',
    defaultImageAsset: 'assets/mascots/panda_morning.png',
  );

  static const MascotCharacter squirrel = MascotCharacter(
    id: 'squirrel',
    nameTr: 'Fındık (Sincap)',
    nameEn: 'Nutty (Squirrel)',
    personalityTr: 'Pofuduk kuyruklu, enerjik ve su molalarını hiç kaçırmayan sevimli sincap.',
    personalityEn: 'Fluffy-tailed, energetic squirrel who never misses a water break.',
    emoji: '🐿️',
    defaultImageAsset: 'assets/mascots/squirrel_afternoon_slump.png',
  );

  // Backward compatibility alias for saved user settings
  static const MascotCharacter owl = squirrel;

  static const MascotCharacter plant = MascotCharacter(
    id: 'plant',
    nameTr: 'Yeşil Filiz & Doğa',
    nameEn: 'Sprout & Nature',
    personalityTr: 'Suyla yeşerip koca bir çınara dönüşen doğa.',
    personalityEn: 'Sprouts with water and grows into a vibrant tree.',
    emoji: '🌱',
    defaultImageAsset: 'assets/mascots/cat_morning.png',
  );

  static const List<MascotCharacter> allMascots = [
    cat,
    dog,
    penguin,
    panda,
    squirrel,
  ];

  static MascotCharacter getById(String id) {
    switch (id) {
      case 'dog':
        return dog;
      case 'penguin':
        return penguin;
      case 'panda':
        return panda;
      case 'squirrel':
      case 'owl':
        return squirrel;
      case 'plant':
        return plant;
      case 'vitality':
        return vitality;
      case 'cat':
      default:
        return cat;
    }
  }
}

/// Resolves the active Mascot State and Dialogues dynamically
class MascotResolver {
  /// Evaluates current state based on percentage, time of day, streak and thirst
  static MascotState resolveCurrentState({
    required double percentage,
    int streakDays = 0,
    DateTime? lastLogTime,
    DateTime? now,
  }) {
    if (percentage >= 1.0) {
      return MascotState.goalReached;
    }
    if (percentage <= 0.0) {
      return MascotState.thirsty;
    }

    final current = now ?? DateTime.now();
    final hour = current.hour;

    // Bedtime: 21:30 - 05:59 ("Hadi son bir yudum")
    if (hour >= 22 || hour < 6 || (hour == 21 && current.minute >= 30)) {
      return MascotState.bedtime;
    }

    // Critical Daytime Thirst: > 3.5 hrs without drink
    if (lastLogTime != null && hour >= 9 && hour <= 21) {
      final hoursPassed = current.difference(lastLogTime).inMinutes / 60.0;
      if (hoursPassed >= 3.5 && percentage < 0.70) {
        return MascotState.thirsty;
      }
    }

    // Afternoon Slump: 14:00 - 16:30 ("Sen hazır uyanıkken..."), only if behind on water (< 50%)
    if ((hour >= 14 && hour < 16) || (hour == 16 && current.minute <= 30)) {
      if (percentage < 0.50) {
        return MascotState.afternoonSlump;
      }
    }

    // Flame Streak: 3+ days streak with strong progress (75%+)
    if (streakDays >= 3 && percentage >= 0.75) {
      return MascotState.streakFire;
    }

    // Dynamic Hydration Energy Ladder (Su içtikçe artan enerji ve canlılık)
    if (percentage < 0.25) {
      return MascotState.morning;
    } else if (percentage < 0.50) {
      return MascotState.workFocus;
    } else if (percentage < 0.70) {
      return MascotState.lunch;
    } else if (percentage < 0.88) {
      return MascotState.workout;
    } else {
      return MascotState.evening;
    }
  }

  /// Returns localized dialogues and image assets for the specific mascot & state
  static MascotDialogue resolveDialogue({
    required String mascotType,
    required double percentage,
    int streakDays = 0,
    DateTime? lastLogTime,
    String lang = 'tr',
    DateTime? now,
    bool preferEnergyAsset = true,
  }) {
    final state = resolveCurrentState(
      percentage: percentage,
      streakDays: streakDays,
      lastLogTime: lastLogTime,
      now: now,
    );
    final isEn = lang == 'en';
    final mascot = MascotCatalog.getById(mascotType);

    String emoji;
    String title;
    String message;
    String hexColor;

    // 1. Classical Vitality Mascot
    if (mascot.id == 'vitality') {
      if (percentage <= 0.0) {
        emoji = '🥱';
        title = isEn ? 'Dehydrated Start!' : 'Güne susuz başladın!';
        message = isEn
            ? 'Started the day dehydrated! Grab a glass of water.'
            : 'Güne susuz başladın! Hemen bir bardak su al.';
        hexColor = 'E11D48';
      } else if (percentage < 0.35) {
        emoji = '🙂';
        title = isEn ? 'First Step!' : 'İlk adımı attın!';
        message = isEn
            ? 'First step taken! Stepping steadily towards your goal.'
            : 'İlk adımı attın! Yavaş yavaş hedefe ilerliyorsun.';
        hexColor = 'F59E0B';
      } else if (percentage < 0.70) {
        emoji = '😊';
        title = isEn ? 'Going Great!' : 'Harika gidiyorsun!';
        message = isEn
            ? 'Going great! Your body thanks you.'
            : 'Harika gidiyorsun! Vücudun sana teşekkür ediyor.';
        hexColor = '10B981';
      } else if (percentage < 1.0) {
        emoji = '😎';
        title = isEn ? 'Almost There!' : 'Neredeyse tamamladın!';
        message = isEn
            ? 'Almost there! Your energy is peaking.'
            : 'Neredeyse tamamladın! Enerjin tam yerinde.';
        hexColor = '06B6D4';
      } else {
        emoji = '🥳';
        title = isEn ? 'Congratulations!' : 'Tebrikler!';
        message = isEn
            ? 'Congratulations! You reached your daily goal!'
            : 'Tebrikler! Günlük su hedefini tamamladın!';
        hexColor = '8B5CF6';
      }

      return MascotDialogue(
        title: title,
        message: message,
        emoji: emoji,
        imageAsset: 'assets/mascots/cat_morning.png',
        state: state,
        hexColor: hexColor,
      );
    }

    // 2. Classical Plant Mascot
    if (mascot.id == 'plant') {
      if (percentage <= 0.0) {
        emoji = '🥀';
        title = isEn ? 'Leaves are Drooping!' : 'Yapraklar boyun büktü!';
        message = isEn
            ? 'Leaves are drooping! Time for some revitalizing water.'
            : 'Yapraklar boyun büktü! Biraz can suyu ver.';
        hexColor = 'E11D48';
      } else if (percentage < 0.35) {
        emoji = '🌱';
        title = isEn ? 'First Green Shoot!' : 'İlk filiz yeşerdi!';
        message = isEn
            ? 'First green shoot sprouted! Reviving with water.'
            : 'İlk filiz yeşerdi! Suyla yeniden canlanıyoruz.';
        hexColor = 'F59E0B';
      } else if (percentage < 0.70) {
        emoji = '🌿';
        title = isEn ? 'Branches Growing Strong!' : 'Dallar uzuyor!';
        message = isEn
            ? 'Branches growing strong, freshness everywhere.'
            : 'Dallar uzuyor, tazelik her yere yayılıyor.';
        hexColor = '10B981';
      } else if (percentage < 1.0) {
        emoji = '🪴';
        title = isEn ? 'Blooming Bright!' : 'Işıl ışıl parlıyorsun!';
        message = isEn
            ? 'Blooming bright! Just a little left to full bloom.'
            : 'Işıl ışıl parlıyorsun! Çiçek açmaya çok az kaldı.';
        hexColor = '06B6D4';
      } else {
        emoji = '🌳';
        title = isEn ? 'Standing Tall!' : 'Koca bir çınar!';
        message = isEn
            ? 'Standing tall and vibrant! Congratulations!'
            : 'Koca bir çınar gibi dipdirisin! Tebrikler!';
        hexColor = '8B5CF6';
      }

      return MascotDialogue(
        title: title,
        message: message,
        emoji: emoji,
        imageAsset: 'assets/mascots/cat_morning.png',
        state: state,
        hexColor: hexColor,
      );
    }

    // 3. Animal Mascots: Cat, Dog, Penguin, Panda, Owl
    // Hydration Emoji based on strict milestone percentage
    if (percentage <= 0.0) {
      hexColor = 'E11D48';
      switch (mascot.id) {
        case 'cat':
          emoji = '😿';
          break;
        case 'penguin':
          emoji = '🧊';
          break;
        case 'dog':
          emoji = '🐶';
          break;
        case 'panda':
          emoji = '🐼';
          break;
        case 'squirrel':
          emoji = '🍂';
          break;
        case 'owl':
        default:
          emoji = '🥱';
          break;
      }
    } else if (percentage < 0.35) {
      hexColor = 'F59E0B';
      switch (mascot.id) {
        case 'cat':
          emoji = '🐱';
          break;
        case 'penguin':
          emoji = '🐧';
          break;
        case 'dog':
          emoji = '🐶';
          break;
        case 'panda':
          emoji = '🌱';
          break;
        case 'squirrel':
          emoji = '🐿️';
          break;
        case 'owl':
        default:
          emoji = '🙂';
          break;
      }
    } else if (percentage < 0.70) {
      hexColor = '10B981';
      switch (mascot.id) {
        case 'cat':
          emoji = '😺';
          break;
        case 'penguin':
          emoji = '🦭';
          break;
        case 'dog':
          emoji = '🎾';
          break;
        case 'panda':
          emoji = '🎍';
          break;
        case 'squirrel':
          emoji = '🌰';
          break;
        case 'owl':
        default:
          emoji = '😊';
          break;
      }
    } else if (percentage < 1.0) {
      hexColor = '06B6D4';
      switch (mascot.id) {
        case 'cat':
          emoji = '😻';
          break;
        case 'penguin':
          emoji = '🏄';
          break;
        case 'dog':
          emoji = '🏃';
          break;
        case 'panda':
          emoji = '☕';
          break;
        case 'squirrel':
          emoji = '⚡';
          break;
        case 'owl':
        default:
          emoji = '😎';
          break;
      }
    } else {
      hexColor = '8B5CF6';
      switch (mascot.id) {
        case 'cat':
          emoji = '🦁';
          break;
        case 'penguin':
          emoji = '👑';
          break;
        case 'dog':
          emoji = '🏆';
          break;
        case 'panda':
          emoji = '🎉';
          break;
        case 'squirrel':
          emoji = '👑';
          break;
        case 'owl':
        default:
          emoji = '🥳';
          break;
      }
    }

    // Contextual Dialogue & Title based on 10 States
    switch (state) {
      case MascotState.goalReached:
        title = isEn ? 'You Champion!' : 'İşte bu, şampiyon!';
        message = isEn
            ? (mascot.id == 'cat'
                ? "Trophy raised, confetti bursting! You are today's hydration champion! 🏆🎉"
                : (mascot.id == 'dog'
                    ? "Trophy won, confetti flying! You are today's hydration champion! 🏆🎉"
                    : (mascot.id == 'penguin'
                        ? "Polar trophy raised, confetti on ice! You are today's hydration champion! 🏆❄️"
                        : (mascot.id == 'panda'
                            ? "Golden trophy raised, bamboo confetti bursting! You are today's hydration champion! 🏆🎋"
                            : 'Congratulations! You reached your daily goal!'))))
            : (mascot.id == 'cat'
                ? 'Kupayı kaldırdık, konfetiler patladı! Günün şampiyon kedisi sensin! 🏆🎉'
                : (mascot.id == 'dog'
                    ? 'Kupayı kaptık, konfetiler havada! Günün şampiyon köpüşü sensin! 🏆🎉'
                    : (mascot.id == 'penguin'
                        ? 'Buz kupasını kaldırdık, konfetiler havada! Günün kutup şampiyonu sensin! 🏆❄️'
                        : (mascot.id == 'panda'
                            ? 'Altın kupayı kaldırdık, konfetiler patladı! Günün şampiyon pandası sensin! 🏆🎋'
                            : 'Tebrikler! Günlük su hedefini tamamladın!'))));
        break;

      case MascotState.thirsty:
        title = isEn ? 'Heeey! Forgot About Me?' : 'Alooo! Beni unuttun mu?';
        message = isEn
            ? (mascot.id == 'cat'
                ? 'Meow! So thirsty, could you spare a sip of water?'
                : (mascot.id == 'dog'
                    ? 'Woof woof! So thirsty, my water bowl is empty! Please share some water!'
                    : (mascot.id == 'penguin'
                        ? 'Ice is melting! Refresh yourself with cool water.'
                        : (mascot.id == 'squirrel'
                            ? 'Dropping all acorns! Need fresh water right now!'
                            : 'Parched like a desert! Please share a glass of water!'))))
            : (mascot.id == 'cat'
                ? 'Miyav! Boğazım kurudu, bardağım bomboş kaldı. Lütfen hemen bir bardak su ver!'
                : (mascot.id == 'dog'
                    ? 'Hav hav! Boğazım kurudu, su kabım bomboş kaldı! Lütfen hemen bir bardak su ver!'
                    : (mascot.id == 'penguin'
                        ? 'Buzlar eriyor! Hemen taze suyla ferahla.'
                        : (mascot.id == 'squirrel'
                            ? 'Fındıklar kurudu, boğazım çöl oldu! Hemen su molası ver!'
                            : 'Çöl sıcağında kuruduk kaldık! Lütfen bana bir bardak su ver!'))));
        break;

      case MascotState.bedtime:
        title = isEn ? 'Just One Last Sip!' : 'Hadi son bir yudum!';
        message = isEn
            ? 'One last sip before bed, sweet dreams... 🌙💤'
            : 'Hadi son bir yudum! Gece susuz kalma, tatlı rüyalar... 🌙💤';
        break;

      case MascotState.afternoonSlump:
        title = isEn ? 'While you are awake...' : 'Sen hazır uyanıkken...';
        message = isEn
            ? 'Eyes getting heavy? Grab a cold glass before nodding off!'
            : 'Sen hazır uyanıkken... Gözler süzülmesin, hemen 1 bardak su al!';
        break;

      case MascotState.morning:
        title = isEn ? 'Start with 1 Glass!' : 'Güne 1 bardak suyla başla!';
        message = isEn
            ? (mascot.id == 'cat'
                ? "Purrr... Stretching time! Let's start the day with a fresh glass of water."
                : (mascot.id == 'dog'
                    ? "Waking up with tail wags! Let's start the day with a fresh glass of water."
                    : (mascot.id == 'penguin'
                        ? "Waddling out of the igloo! Let's start the day with a cold glass of glacier water."
                        : 'Good morning! Kickstart your body with fresh water.')))
            : (mascot.id == 'cat'
                ? 'Mırrr... Gerinme vakti! Güne 1 bardak taze suyla enerjik başlayalım.'
                : (mascot.id == 'dog'
                    ? 'Kuyruk sallayarak uyandık! Güne 1 bardak taze suyla enerjik başlayalım.'
                    : (mascot.id == 'penguin'
                        ? 'İglodan paytak adımlarla çıktık! Güne 1 bardak buz gibi taze suyla başlayalım.'
                        : 'Günaydın! Güne 1 bardak taze suyla enerjik başla.')));
        break;

      case MascotState.workFocus:
        title = isEn ? "Don't Dry Up at Desk!" : 'Masa başında kuruma!';
        message = isEn
            ? (mascot.id == 'cat'
                ? 'Glasses on, focus mode activated! Keep your water tumbler close at the desk.'
                : (mascot.id == 'dog'
                    ? 'Glasses on, paws on keyboard! Keep your water close at the desk.'
                    : (mascot.id == 'penguin'
                        ? 'Round glasses on, igloo desk mode! Sip cold water while focusing.'
                        : 'Send fresh oxygen to your brain with a crisp sip.')))
            : (mascot.id == 'cat'
                ? 'Gözlükler takıldı, çalışma başladı! Masa başında suyunu yudumlamayı unutma.'
                : (mascot.id == 'dog'
                    ? 'Gözlükler takıldı, patiler klavyede! Masa başında suyunu yudumlamayı unutma.'
                    : (mascot.id == 'penguin'
                        ? 'Yuvarlak gözlükler takıldı, masa başı odaklanma! Soğuk suyunu yudumlamayı unutma.'
                        : 'Beynine taze bir yudum oksijen gönder, zihnin açılsın.')));
        break;

      case MascotState.lunch:
        title = isEn ? 'Pre-Meal Water Break!' : 'Yemekten önce su molası!';
        message = isEn
            ? 'A fresh glass of water before lunch aids digestion. Bon appétit!'
            : 'Yemek öncesi su içmek sindirimi rahatlatır, afiyet olsun!';
        break;

      case MascotState.workout:
        title = isEn ? 'Keep Energy High!' : 'Mataranı tazele!';
        message = isEn
            ? (mascot.id == 'cat'
                ? 'Sweatband on, workout mode! Keep your hydration and stamina high.'
                : (mascot.id == 'dog'
                    ? 'Red headband on, workout mode! Keep your hydration high while running.'
                    : (mascot.id == 'penguin'
                        ? 'Red sweatband on, sliding workout! Keep your stamina high with glacier water.'
                        : 'Active day! Maintain your hydration and stamina.')))
            : (mascot.id == 'cat'
                ? 'Spor bandı takıldı, tempo yükseldi! Enerjini korumak için suyunu ihmal etme.'
                : (mascot.id == 'dog'
                    ? 'Kırmızı kafa bandı takıldı, tempo yükseldi! Koşarken suyunu ihmal etme.'
                    : (mascot.id == 'penguin'
                        ? 'Kırmızı alın bandı takıldı, tempo yükseldi! Buzda kayarken suyunu ihmal etme.'
                        : 'Günün temposu yüksek! Enerjini korumak için suyunu ihmal etme.')));
        break;

      case MascotState.evening:
        title = isEn ? 'Almost Reached Goal!' : 'Hedefe bir adım kaldı!';
        message = isEn
            ? (mascot.id == 'cat'
                ? 'Cozy armchair purrs... Unwind from the day with a refreshing cup of water.'
                : (mascot.id == 'dog'
                    ? 'Curled up in armchair... Unwind from the day with a fresh cup of water.'
                    : (mascot.id == 'penguin'
                        ? 'Cozy blanket on the armchair... Unwind from the day with a cold cup of water.'
                        : 'Unwind from today. Just a couple of cups left to finish.')))
            : (mascot.id == 'cat'
                ? 'Koltukta huzurlu mırıltılar... Günün yorgunluğunu taze bir bardak suyla atalım.'
                : (mascot.id == 'dog'
                    ? 'Koltukta kıvrılıp dinlenme vakti... Günün yorgunluğunu taze bir bardak suyla atalım.'
                    : (mascot.id == 'penguin'
                        ? 'Koltukta battaniyeye sarılıp dinlenme vakti... Günün yorgunluğunu taze suyla atalım.'
                        : 'Günün yorgunluğunu atıyoruz. Hedefe ulaşmaya çok az kaldı!')));
        break;

      case MascotState.streakFire:
        title = isEn ? 'Streak on Fire!' : 'Serimiz alev alev! 🔥';
        message = isEn
            ? (mascot.id == 'cat'
                ? '$streakDays days strong like a superhero! Keep the fire burning! 🔥'
                : (mascot.id == 'dog'
                    ? '$streakDays days strong like a superhero! Keep the fire burning! 🔥'
                    : (mascot.id == 'penguin'
                        ? '$streakDays days strong! Polar superhero protecting the flames! 🔥❄️'
                        : '$streakDays days strong! Keep this legendary habit blazing!')))
            : (mascot.id == 'cat'
                ? '$streakDays günlük seriyi süper kahraman gibi koruyoruz! Alevler sönmesin! 🔥'
                : (mascot.id == 'dog'
                    ? '$streakDays günlük seriyi süper kahraman peleriniyle koruyoruz! Alevler sönmesin! 🔥'
                    : (mascot.id == 'penguin'
                        ? '$streakDays günlük seriyi kutup peleriniyle koruyoruz! Alevler sönmesin! 🔥❄️'
                        : '$streakDays günlük seriyi bugün de koru, hidrasyon ateşi parlasın!')));
        break;
    }

    final energyTier = MascotEnergyLadder.getTier(percentage);
    final energyImageAsset = 'assets/mascots/${mascot.id}_${energyTier.fileSuffix}.png';
    final routineImageAsset = 'assets/mascots/${mascot.id}_${state.assetSuffix}.png';

    final energyData = MascotEnergyLadder.getDialogue(
      mascotId: mascot.id,
      tier: energyTier,
      isEn: isEn,
    );

    final routineTitle = title;
    final routineMessage = message;

    // Contextual Show / Reminder events:
    final bool isSpecialShowEvent = state == MascotState.goalReached ||
        state == MascotState.bedtime ||
        state == MascotState.afternoonSlump ||
        state == MascotState.streakFire ||
        state == MascotState.thirsty;

    // Primary Image Selection:
    // When a mascot has an energy ladder (Cat, Dog, Penguin, Panda), hydration level energy ladder has
    // absolute priority on the in-app screen and widgets!
    // Time-based routine events (bedtime, afternoon slump) do NOT override the user's water energy progress.
    final bool hasEnergyLadder = mascot.id == 'cat' || mascot.id == 'dog' || mascot.id == 'penguin' || mascot.id == 'panda';
    final String resolvedImageAsset;
    final String finalTitle;
    final String finalMessage;

    if (hasEnergyLadder && preferEnergyAsset) {
      resolvedImageAsset = energyImageAsset;
      finalTitle = energyData['title']!;
      finalMessage = energyData['message']!;
    } else if (isSpecialShowEvent) {
      resolvedImageAsset = routineImageAsset;
      finalTitle = routineTitle;
      finalMessage = routineMessage;
    } else {
      resolvedImageAsset = routineImageAsset;
      finalTitle = routineTitle;
      finalMessage = routineMessage;
    }

    return MascotDialogue(
      title: finalTitle,
      message: finalMessage,
      emoji: emoji,
      imageAsset: resolvedImageAsset,
      state: state,
      hexColor: hexColor,
      energyImageAsset: energyImageAsset,
      energyPercentage: energyTier.stepValue,
      energyTitle: energyData['title']!,
      energyMessage: energyData['message']!,
      routineImageAsset: routineImageAsset,
      routineTitle: routineTitle,
      routineMessage: routineMessage,
    );
  }
}
