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

/// Dialogue & Visual Payload for Widgets, Dashboard and Notifications
class MascotDialogue {
  final String title;
  final String message;
  final String emoji;
  final String imageAsset;
  final MascotState state;
  final String hexColor;

  const MascotDialogue({
    required this.title,
    required this.message,
    required this.emoji,
    required this.imageAsset,
    required this.state,
    this.hexColor = '0284C7',
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
    nameTr: 'Sevimli Kedi',
    nameEn: 'Playful Cat',
    personalityTr: 'Uykucu, tatlı ve hafif sitemkar mırıltılı kedi.',
    personalityEn: 'Sleepy, cozy, slightly sassy purring cat.',
    emoji: '🐱',
    defaultImageAsset: 'assets/mascots/cat_afternoon_slump.png',
  );

  static const MascotCharacter dog = MascotCharacter(
    id: 'dog',
    nameTr: 'Neşeli Köpek',
    nameEn: 'Playful Dog',
    personalityTr: 'Enerjik, sadık, kuyruk sallayan motivasyon ustası.',
    personalityEn: 'Energetic, loyal, tail-wagging cheerleader.',
    emoji: '🐶',
    defaultImageAsset: 'assets/mascots/dog_afternoon_slump.png',
  );

  static const MascotCharacter penguin = MascotCharacter(
    id: 'penguin',
    nameTr: 'Kutup Pengueni',
    nameEn: 'Polar Penguin',
    personalityTr: 'Kutup soğukluğunu ve buz gibi suları seven serin dost.',
    personalityEn: 'Loves arctic chill and ice-cold fresh water.',
    emoji: '🐧',
    defaultImageAsset: 'assets/mascots/penguin_workout.png',
  );

  static const MascotCharacter panda = MascotCharacter(
    id: 'panda',
    nameTr: 'Tembel Panda',
    nameEn: 'Zen Panda',
    personalityTr: 'Pofuduk, koltuğunda yayılan zen ve huzur pınarı.',
    personalityEn: 'Fluffy, zen couch potato who sips peacefully.',
    emoji: '🐼',
    defaultImageAsset: 'assets/mascots/panda_work_focus.png',
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

    // Afternoon Slump: 14:00 - 16:30 ("Sen hazır uyanıkken...")
    if (hour >= 14 && hour < 16 || (hour == 16 && current.minute <= 30)) {
      return MascotState.afternoonSlump;
    }

    // Flame Streak: 3+ days streak with good progress
    if (streakDays >= 3 && percentage >= 0.60) {
      return MascotState.streakFire;
    }

    // Daytime progression
    if (hour >= 6 && hour < 9 || (hour == 9 && current.minute <= 30)) {
      return MascotState.morning;
    } else if (hour >= 9 && hour < 11 || (hour == 11 && current.minute <= 30)) {
      return MascotState.workFocus;
    } else if (hour >= 11 && hour < 14) {
      return MascotState.lunch;
    } else if (hour >= 16 && hour < 19) {
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
        imageAsset: 'assets/mascots/owl_afternoon_slump.png',
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
                ? "Roar time! You are today's hydration champion!"
                : 'Congratulations! You reached your daily goal!')
            : (mascot.id == 'cat'
                ? 'Kükreme vakti! Günün şampiyon kedisi sensin!'
                : 'Tebrikler! Günlük su hedefini tamamladın!');
        break;

      case MascotState.thirsty:
        title = isEn ? 'Heeey! Forgot About Me?' : 'Alooo! Beni unuttun mu?';
        message = isEn
            ? (mascot.id == 'cat'
                ? 'Meow! So thirsty, could you spare a sip of water?'
                : (mascot.id == 'penguin'
                    ? 'Ice is melting! Refresh yourself with cool water.'
                    : (mascot.id == 'squirrel'
                        ? 'Dropping all acorns! Need fresh water right now!'
                        : 'Parched like a desert! Please share a glass of water!')))
            : (mascot.id == 'cat'
                ? 'Miyav! Çok susadım, bir yudum su verir misin?'
                : (mascot.id == 'penguin'
                    ? 'Buzlar eriyor! Hemen taze suyla ferahla.'
                    : (mascot.id == 'squirrel'
                        ? 'Fındıklar kurudu, boğazım çöl oldu! Hemen su molası ver!'
                        : 'Çöl sıcağında kuruduk kaldık! Lütfen bana bir bardak su ver!')));
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
                ? "Feeling refreshed! Let's keep drinking water together."
                : (mascot.id == 'penguin'
                    ? 'Waddling towards the goal! First sip was great.'
                    : 'Good morning! Kickstart your body with fresh water.'))
            : (mascot.id == 'cat'
                ? 'Biraz ferahladım! Birlikte su içmeye devam edelim.'
                : (mascot.id == 'penguin'
                    ? 'Paytak adımlarla hedefe! İlk yudum harika.'
                    : 'Günaydın! Güne 1 bardak taze suyla enerjik başla.'));
        break;

      case MascotState.workFocus:
        title = isEn ? "Don't Dry Up at Desk!" : 'Masa başında kuruma!';
        message = isEn
            ? (mascot.id == 'cat'
                ? 'Happy purrs! Our hydration level is super.'
                : (mascot.id == 'penguin'
                    ? 'Cool as the ocean! Gliding with the waves.'
                    : 'Send fresh oxygen to your brain with a crisp sip.'))
            : (mascot.id == 'cat'
                ? 'Harika bir mırıltı! Hidrasyon seviyemiz süper.'
                : (mascot.id == 'penguin'
                    ? 'Serin sular gibisin! Dalgalarla akıyoruz.'
                    : 'Beynine taze bir yudum oksijen gönder, zihnin açılsın.'));
        break;

      case MascotState.lunch:
        title = isEn ? 'Pre-Meal Water Break!' : 'Yemekten önce su molası!';
        message = isEn
            ? 'Drinking water before eating eases digestion.'
            : 'Yemek öncesi su içmek sindirimi rahatlatır, afiyet olsun!';
        break;

      case MascotState.workout:
        title = isEn ? 'Keep Energy High!' : 'Mataranı tazele!';
        message = isEn
            ? (mascot.id == 'cat'
                ? 'Pawsome! Just a tiny bit left to reach the goal.'
                : (mascot.id == 'penguin'
                    ? 'Catching the polar wave! Summit is so close.'
                    : 'Active day! Maintain your hydration and stamina.'))
            : (mascot.id == 'cat'
                ? 'Sana bayılıyorum! Hedefe çok ama çok az kaldı.'
                : (mascot.id == 'penguin'
                    ? 'Kutup dalgasını yakaladık! Zirve çok yakın.'
                    : 'Günün temposu yüksek! Enerjini korumak için suyunu ihmal etme.'));
        break;

      case MascotState.evening:
        title = isEn ? 'Almost Reached Goal!' : 'Hedefe bir adım kaldı!';
        message = isEn
            ? (mascot.id == 'cat'
                ? 'Pawsome! Just a tiny bit left to reach the goal.'
                : (mascot.id == 'penguin'
                    ? 'Catching the polar wave! Summit is so close.'
                    : 'Unwind from today. Just a couple of cups left to finish.'))
            : (mascot.id == 'cat'
                ? 'Sana bayılıyorum! Hedefe çok ama çok az kaldı.'
                : (mascot.id == 'penguin'
                    ? 'Kutup dalgasını yakaladık! Zirve çok yakın.'
                    : 'Günün yorgunluğunu atıyoruz. Hedefe ulaşmaya çok az kaldı!'));
        break;

      case MascotState.streakFire:
        title = isEn ? 'Streak on Fire!' : 'Serimiz alev alev! 🔥';
        message = isEn
            ? '$streakDays days strong! Keep this legendary habit blazing!'
            : '$streakDays günlük seriyi bugün de koru, hidrasyon ateşi parlasın!';
        break;
    }

    final imageAsset = 'assets/mascots/${mascot.id}_${state.assetSuffix}.png';

    return MascotDialogue(
      title: title,
      message: message,
      emoji: emoji,
      imageAsset: imageAsset,
      state: state,
      hexColor: hexColor,
    );
  }
}
