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
    if (percentage < 0.35) return MascotEnergyTier.energy25;
    if (percentage < 0.70) return MascotEnergyTier.energy50;
    if (percentage < 0.92) return MascotEnergyTier.energy75;
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
    } else if (mascotId == 'squirrel') {
      switch (tier) {
        case MascotEnergyTier.energy0:
          return {
            'title': isEn ? 'Zero Energy • Acorns Dried' : 'Sıfır Enerji • Fındıklar Kurudu',
            'message': isEn
                ? 'Fluffy tail drooping to the ground! My acorn cup is empty, no energy to leap... 🍂'
                : 'Pofuduk kuyruğum yere serildi! Palamut bardağım bomboş, hiç zıplayacak gücüm yok... 🍂',
          };
        case MascotEnergyTier.energy25:
          return {
            'title': isEn ? 'First Sip • Tail Twitching' : 'İlk Yudum • Kuyruk Sallanıyor',
            'message': isEn
                ? 'First fresh sip felt great! Tiny paws reviving, tail twitching happily.'
                : 'İlk taze yudum iyi geldi! Minik patilerim canlanıyor, kuyruğum kıpırdadı.',
          };
        case MascotEnergyTier.energy50:
          return {
            'title': isEn ? 'Half Energy • Acorn Tumbler' : 'Yarı Enerji • Palamut Matarası',
            'message': isEn
                ? 'Crisp sip from my acorn tumbler! Halfway full, jumping branch to branch.'
                : 'Palamut mataramdan ferah bir yudum! Yarı depoyla daldan dala atlamaya başladım.',
          };
        case MascotEnergyTier.energy75:
          return {
            'title': isEn ? 'High Vitality • Acorn Speed' : 'Yüksek Canlılık • Fındık Hızı',
            'message': isEn
                ? 'Energy peaking! Fluffy tail held high, hydration sparkle glowing in the forest.'
                : 'Enerji tavan yaptı! Pofuduk kuyruğum dimdik, ormanda su ateşi parıldıyor.',
          };
        case MascotEnergyTier.energy100:
          return {
            'title': isEn ? 'Full Charge • Forest Champion' : 'Tam Şarj • Orman Şampiyonu',
            'message': isEn
                ? 'Fully charged! Raised the golden acorn chalice, what a glorious day! 🌰👑'
                : 'Tam şarj olduk! Altın palamut kadehini kaldırdık, harika bir gün! 🌰👑',
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
    defaultImageAsset: 'assets/mascots/squirrel_morning.png',
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
    if (percentage <= 0.0) {
      return MascotState.thirsty;
    }

    final current = now ?? DateTime.now();
    final hour = current.hour;

    // Bedtime window: 21:30 - 05:59 ("Hadi son bir yudum" or "Şampiyonlar da uyur")
    // Natural bedtime takes priority even for champions to keep night hours peaceful and restful
    if (hour >= 22 || hour < 6 || (hour == 21 && current.minute >= 30)) {
      return MascotState.bedtime;
    }

    final bool isGoalCompleted = percentage >= 1.0;

    // When goal is completed, determine if we are in the initial celebration window (< 45 mins since goal log)
    // or transitioning into time-sensitive champion routines (slump, workout, evening, thirst nudge, streak)
    if (isGoalCompleted) {
      if (lastLogTime != null) {
        final minutesPassed = current.difference(lastLogTime).inMinutes;
        final hoursPassed = minutesPassed / 60.0;

        // 1. Initial Celebration Window: first 45 minutes after completing/logging goal
        if (minutesPassed < 45) {
          return MascotState.goalReached;
        }

        // 2. Daytime Thirst Nudge: > 3.5 hrs without drink even as a champion
        if (hour >= 9 && hour <= 21 && hoursPassed >= 3.5) {
          return MascotState.thirsty;
        }

        // 3. Afternoon Slump Window: 14:00 - 16:30 ("Sen hazır uyanıkken... şampiyonluk turunda su iç")
        if ((hour >= 14 && hour < 16) || (hour == 16 && current.minute <= 30)) {
          return MascotState.afternoonSlump;
        }

        // 4. Workout / Active Evening Window: 17:00 - 19:30 ("Şampiyonluk maratonu")
        if ((hour >= 17 && hour < 19) || (hour == 19 && current.minute < 30)) {
          return MascotState.workout;
        }

        // 5. Evening Relaxation Window: 19:30 - 21:30 ("Koltukta şampiyonluk keyfi")
        if ((hour == 19 && current.minute >= 30) || (hour >= 20 && hour < 21) || (hour == 21 && current.minute < 30)) {
          return MascotState.evening;
        }

        // 6. Blazing Streak (3+ days)
        if (streakDays >= 3) {
          return MascotState.streakFire;
        }

        // 7. Otherwise, keep champion celebration
        return MascotState.goalReached;
      }

      // If lastLogTime is null (e.g. test without log timestamps), default to goalReached
      return MascotState.goalReached;
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

    // Natural Time-of-Day Daytime Routine Progression
    if (hour >= 6 && (hour < 9 || (hour == 9 && current.minute <= 30))) {
      return MascotState.morning;
    } else if ((hour == 9 && current.minute > 30) || hour == 10 || (hour == 11 && current.minute <= 30)) {
      // In the morning work window, if user hasn't started drinking yet (< 25%), keep encouraging morning wake-up
      if (percentage < 0.25) {
        return MascotState.morning;
      }
      return MascotState.workFocus;
    } else if ((hour == 11 && current.minute > 30) || (hour >= 12 && hour < 14)) {
      return MascotState.lunch;
    } else if (hour >= 14 && (hour < 16 || (hour == 16 && current.minute <= 30))) {
      return MascotState.afternoonSlump;
    } else if ((hour == 16 && current.minute > 30) || hour == 17 || hour == 18 || (hour == 19 && current.minute <= 30)) {
      return MascotState.workout;
    } else if ((hour == 19 && current.minute > 30) || hour == 20 || (hour == 21 && current.minute < 30)) {
      return MascotState.evening;
    } else {
      return MascotState.bedtime;
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

    final bool isGoalCompleted = percentage >= 1.0;

    // Contextual Dialogue & Title based on 10 States
    final routineData = getRoutineDialogue(
      mascotId: mascot.id,
      state: state,
      isEn: isEn,
      streakDays: streakDays,
      isGoalCompleted: isGoalCompleted,
    );
    title = routineData['title']!;
    message = routineData['message']!;

    final energyTier = MascotEnergyLadder.getTier(percentage);
    final energyImageAsset = 'assets/mascots/${mascot.id}_${energyTier.fileSuffix}.png';
    final routineImageAsset = 'assets/mascots/${mascot.id}_${state.assetSuffix}.png';

    final energyData = MascotEnergyLadder.getDialogue(
      mascotId: mascot.id,
      tier: energyTier,
      isEn: isEn,
    );
    String energyMessageText = energyData['message']!;
    if (percentage >= 1.05 && energyTier == MascotEnergyTier.energy100) {
      energyMessageText = isEn
          ? 'You surpassed your goal, victory lap in progress! Every extra sip is bonus hydration! ⚡🏆'
          : 'Hedefi aştın, şampiyonluk turundasın! Fazladan her yudum bir bonus puan! ⚡🏆';
    }

    final routineTitle = title;
    final routineMessage = message;

    // Contextual Show / Reminder events:
    final bool isSpecialShowEvent = state == MascotState.goalReached ||
        state == MascotState.bedtime ||
        state == MascotState.afternoonSlump ||
        state == MascotState.streakFire ||
        state == MascotState.thirsty;

    final bool hasEnergyLadder = mascot.id == 'cat' ||
        mascot.id == 'dog' ||
        mascot.id == 'penguin' ||
        mascot.id == 'panda' ||
        mascot.id == 'squirrel';
    final String resolvedImageAsset;
    final String finalTitle;
    final String finalMessage;

    if (hasEnergyLadder && preferEnergyAsset) {
      resolvedImageAsset = energyImageAsset;
      finalTitle = energyData['title']!;
      finalMessage = energyMessageText;
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
      energyPercentage: (percentage * 100).toInt(),
      energyTitle: energyData['title']!,
      energyMessage: energyMessageText,
      routineImageAsset: routineImageAsset,
      routineTitle: routineTitle,
      routineMessage: routineMessage,
    );
  }

  /// Title badge / chip label for the 10 daily routine states
  static String getStateTag(MascotState state, bool isEn) {
    switch (state) {
      case MascotState.morning:
        return isEn ? 'Morning Awakening' : 'Sabah Uyanışı';
      case MascotState.workFocus:
        return isEn ? 'Desk Focus' : 'Masa Başı Odaklanma';
      case MascotState.lunch:
        return isEn ? 'Lunch Break' : 'Öğle Yemeği Molası';
      case MascotState.afternoonSlump:
        return isEn ? 'Afternoon Slump & Sassy Eye' : 'Öğleden Sonra Rehaveti & Sitem';
      case MascotState.workout:
        return isEn ? 'Workout & Motion' : 'Spor & Hareket';
      case MascotState.evening:
        return isEn ? 'Evening Rest' : 'Akşam Dinlenmesi';
      case MascotState.bedtime:
        return isEn ? 'Bedtime & Last Sip' : 'Gece Uykusu & Son Yudum';
      case MascotState.goalReached:
        return isEn ? 'Daily Goal Champion' : 'Günlük Hedef Şampiyonu';
      case MascotState.thirsty:
        return isEn ? 'Critical Thirst Alert' : 'Kritik Susuzluk Uyarısı';
      case MascotState.streakFire:
        return isEn ? 'Streak Fire Hero' : 'Seri Ateşi & Süper Kahraman';
    }
  }

  /// Unique theme accent color for each of the 10 routine states
  static String getStateHexColor(MascotState state) {
    switch (state) {
      case MascotState.morning:
        return 'F59E0B'; // Amber
      case MascotState.workFocus:
        return '3B82F6'; // Blue
      case MascotState.lunch:
        return '10B981'; // Emerald
      case MascotState.afternoonSlump:
        return '8B5CF6'; // Purple
      case MascotState.workout:
        return 'F97316'; // Orange
      case MascotState.evening:
        return '6366F1'; // Indigo
      case MascotState.bedtime:
        return '4F46E5'; // Deep Indigo
      case MascotState.goalReached:
        return 'EAB308'; // Gold
      case MascotState.thirsty:
        return 'EF4444'; // Red
      case MascotState.streakFire:
        return 'F97316'; // Flame
    }
  }

  /// Expressive emoji matching character & state
  static String getStateEmoji(String mascotId, MascotState state) {
    switch (state) {
      case MascotState.morning:
        return mascotId == 'cat'
            ? '🌅'
            : (mascotId == 'dog'
                ? '🐶'
                : (mascotId == 'penguin'
                    ? '🧊'
                    : (mascotId == 'panda'
                        ? '🥱'
                        : (mascotId == 'squirrel'
                            ? '🐿️'
                            : (mascotId == 'plant' ? '🌱' : '🌅')))));
      case MascotState.workFocus:
        return mascotId == 'cat'
            ? '👓'
            : (mascotId == 'dog'
                ? '💻'
                : (mascotId == 'penguin'
                    ? '❄️'
                    : (mascotId == 'panda'
                        ? '🎋'
                        : (mascotId == 'squirrel'
                            ? '🌰'
                            : (mascotId == 'plant' ? '☀️' : '🧠')))));
      case MascotState.lunch:
        return mascotId == 'cat'
            ? '🥗'
            : (mascotId == 'dog'
                ? '🍖'
                : (mascotId == 'penguin'
                    ? '🐟'
                    : (mascotId == 'panda'
                        ? '🎍'
                        : (mascotId == 'squirrel'
                            ? '🍓'
                            : (mascotId == 'plant' ? '🌿' : '🍽️')))));
      case MascotState.afternoonSlump:
        return mascotId == 'cat'
            ? '😼'
            : (mascotId == 'dog'
                ? '🐾'
                : (mascotId == 'penguin'
                    ? '😴'
                    : (mascotId == 'panda'
                        ? '💤'
                        : (mascotId == 'squirrel'
                            ? '🍂'
                            : (mascotId == 'plant' ? '🥀' : '🥱')))));
      case MascotState.workout:
        return mascotId == 'cat'
            ? '🏃'
            : (mascotId == 'dog'
                ? '🎾'
                : (mascotId == 'penguin'
                    ? '🏄'
                    : (mascotId == 'panda'
                        ? '🥋'
                        : (mascotId == 'squirrel'
                            ? '⚡'
                            : (mascotId == 'plant' ? '💧' : '💪')))));
      case MascotState.evening:
        return mascotId == 'cat'
            ? '🛋️'
            : (mascotId == 'dog'
                ? '🛋️'
                : (mascotId == 'penguin'
                    ? '🦭'
                    : (mascotId == 'panda'
                        ? '☕'
                        : (mascotId == 'squirrel'
                            ? '🏡'
                            : (mascotId == 'plant' ? '🪴' : '🌙')))));
      case MascotState.bedtime:
        return mascotId == 'cat'
            ? '💤'
            : (mascotId == 'dog'
                ? '🌙'
                : (mascotId == 'penguin'
                    ? '✨'
                    : (mascotId == 'panda'
                        ? '🛌'
                        : (mascotId == 'squirrel'
                            ? '🌙'
                            : (mascotId == 'plant' ? '😴' : '💤')))));
      case MascotState.goalReached:
        return mascotId == 'cat'
            ? '🏆'
            : (mascotId == 'dog'
                ? '🏆'
                : (mascotId == 'penguin'
                    ? '👑'
                    : (mascotId == 'panda'
                        ? '🏆'
                        : (mascotId == 'squirrel'
                            ? '👑'
                            : (mascotId == 'plant' ? '🌳' : '🌟')))));
      case MascotState.thirsty:
        return mascotId == 'cat'
            ? '😿'
            : (mascotId == 'dog'
                ? '🚨'
                : (mascotId == 'penguin'
                    ? '🧊'
                    : (mascotId == 'panda'
                        ? '🆘'
                        : (mascotId == 'squirrel'
                            ? '⚠️'
                            : (mascotId == 'plant' ? '🥀' : '🚨')))));
      case MascotState.streakFire:
        return mascotId == 'cat'
            ? '🔥'
            : (mascotId == 'dog'
                ? '🔥'
                : (mascotId == 'penguin'
                    ? '🔥'
                    : (mascotId == 'panda'
                        ? '🔥'
                        : (mascotId == 'squirrel'
                            ? '🔥'
                            : (mascotId == 'plant' ? '🌿' : '🔥')))));
    }
  }

  /// Comprehensive routine dialogue dictionary covering all 10 states for all 7 mascots
  static Map<String, String> getRoutineDialogue({
    required String mascotId,
    required MascotState state,
    required bool isEn,
    int streakDays = 0,
    bool isGoalCompleted = false,
  }) {
    if (isGoalCompleted) {
      final championDialogue = _getChampionRoutineDialogue(
        mascotId: mascotId,
        state: state,
        isEn: isEn,
        streakDays: streakDays,
      );
      if (championDialogue != null) {
        return championDialogue;
      }
    }

    switch (state) {
      case MascotState.morning:
        if (mascotId == 'cat') {
          return {
            'title': isEn ? 'Start with 1 Glass!' : 'Güne 1 bardak suyla başla!',
            'message': isEn
                ? "Purrr... Stretching time! Let's start the day with a fresh glass of water."
                : 'Mırrr... Gerinme vakti! Güne 1 bardak taze suyla enerjik başlayalım.',
          };
        } else if (mascotId == 'dog') {
          return {
            'title': isEn ? 'Start with 1 Glass!' : 'Kuyruk salla, suyla uyan!',
            'message': isEn
                ? "Waking up with tail wags! Let's start the day with a fresh glass of water."
                : 'Kuyruk sallayarak uyandık! Güne 1 bardak taze suyla enerjik başlayalım.',
          };
        } else if (mascotId == 'penguin') {
          return {
            'title': isEn ? 'Start with 1 Glass!' : 'İglodan serin uyanış!',
            'message': isEn
                ? "Waddling out of the igloo! Let's start the day with a cold glass of glacier water."
                : 'İglodan paytak adımlarla çıktık! Güne 1 bardak buz gibi taze suyla başlayalım.',
          };
        } else if (mascotId == 'panda') {
          return {
            'title': isEn ? 'Start with 1 Glass!' : 'Uykulu panda esnemesi!',
            'message': isEn
                ? "Yawning and stretching paws! Let's start the morning with a fresh glass of water."
                : 'Esneme molası bitti! Bambuların gölgesinde güne 1 bardak taze suyla başlayalım.',
          };
        } else if (mascotId == 'squirrel') {
          return {
            'title': isEn ? 'Start with 1 Glass!' : 'Pofuduk kuyruk uyandı!',
            'message': isEn
                ? "Tiny paws stretching forward, bushy tail up! Start the day with a fresh glass of water."
                : 'Minik patiler gerindi! Güne fındık tadında taze 1 bardak suyla enerjik başla.',
          };
        } else if (mascotId == 'plant') {
          return {
            'title': isEn ? 'Morning Dew!' : 'Sabah çiyi vakti!',
            'message': isEn
                ? 'Sun has risen! Revitalize your leaves with fresh morning water.'
                : 'Güneş doğdu! Yapraklarını taze sabah suyuyla canlandır.',
          };
        } else {
          return {
            'title': isEn ? 'Start with 1 Glass!' : 'Güne zinde başla!',
            'message': isEn
                ? 'Good morning! Kickstart your body with fresh water.'
                : 'Güne 1 bardak taze suyla başlayarak metabolizmanı uyandır.',
          };
        }

      case MascotState.workFocus:
        if (mascotId == 'cat') {
          return {
            'title': isEn ? "Don't Dry Up at Desk!" : 'Masa başında kuruma!',
            'message': isEn
                ? 'Glasses on, focus mode activated! Keep your water tumbler close at the desk.'
                : 'Gözlükler takıldı, çalışma başladı! Masa başında suyunu yudumlamayı unutma.',
          };
        } else if (mascotId == 'dog') {
          return {
            'title': isEn ? "Don't Dry Up at Desk!" : 'Patiler klavyede, su yanında!',
            'message': isEn
                ? 'Glasses on, paws on keyboard! Keep your water close at the desk.'
                : 'Gözlükler takıldı, patiler klavyede! Masa başında suyunu yudumlamayı unutma.',
          };
        } else if (mascotId == 'penguin') {
          return {
            'title': isEn ? "Don't Dry Up at Desk!" : 'Kutup ofisinde derin odak!',
            'message': isEn
                ? 'Round glasses on, igloo desk mode! Sip cold water while focusing.'
                : 'Yuvarlak gözlükler takıldı, masa başı odaklanma! Soğuk suyunu yudumlamayı unutma.',
          };
        } else if (mascotId == 'panda') {
          return {
            'title': isEn ? "Don't Dry Up at Desk!" : 'Bambu masasında konsantrasyon!',
            'message': isEn
                ? 'Reading glasses on, zen focus at the bamboo desk! Keep sipping your water.'
                : 'Gözlükler takıldı, bambu masasında sessiz ve odaklıyız. Suyunu yudumlamayı unutma.',
          };
        } else if (mascotId == 'squirrel') {
          return {
            'title': isEn ? "Don't Dry Up at Desk!" : 'Palamut başında tam odaklanma!',
            'message': isEn
                ? 'Tiny glasses on nose, calculating acorn stash! Keep your water close at the desk.'
                : 'Gözlükler burunda, hesaplar yapılıyor! Masandaki sudan bir yudum al, zihnin açılsın.',
          };
        } else if (mascotId == 'plant') {
          return {
            'title': isEn ? 'Nourish Under Light!' : 'Işık alırken beslen!',
            'message': isEn
                ? 'Remember photosynthesis while working! A glass of water keeps your mind fresh.'
                : 'Çalışırken fotosentez yapmayı unutma! Bir bardak su zihnini taze tutar.',
          };
        } else {
          return {
            'title': isEn ? 'Focus & Oxygen!' : 'Zihne taze oksijen!',
            'message': isEn
                ? 'Send fresh oxygen to your brain with a crisp sip.'
                : 'Masa başında kuruma! Bir yudum suyla dikkatini ve enerjini topla.',
          };
        }

      case MascotState.lunch:
        if (mascotId == 'cat') {
          return {
            'title': isEn ? 'Pre-Meal Water Break!' : 'Yemekten önce su molası!',
            'message': isEn
                ? 'A fresh glass of water before lunch aids digestion. Bon appétit, purrr!'
                : 'Yemekten önce su içmek sindirimi rahatlatır. Afiyet olsun, mırrr!',
          };
        } else if (mascotId == 'dog') {
          return {
            'title': isEn ? 'Pre-Meal Water Break!' : 'Mama saati öncesi taze su!',
            'message': isEn
                ? 'Water before mealtime keeps digestion smooth and happy. Woof!'
                : 'Mama kasesinden önce bir kase taze su! Sindirime iyi gelir, afiyet olsun!',
          };
        } else if (mascotId == 'penguin') {
          return {
            'title': isEn ? 'Pre-Meal Water Break!' : 'Balık ziyafeti öncesi ferahlık!',
            'message': isEn
                ? 'Cold water before lunch aids digestion like an arctic fresh breeze!'
                : 'Yemek öncesi buz gibi su içmek sindirimi rahatlatır, afiyet olsun!',
          };
        } else if (mascotId == 'panda') {
          return {
            'title': isEn ? 'Pre-Meal Water Break!' : 'Taze bambu öncesi su yudumu!',
            'message': isEn
                ? 'A refreshing glass before crunchy bamboo shoots aids smooth digestion. Enjoy!'
                : 'Taze yeşil bambulardan önce bir bardak su sindirimi rahatlatır, afiyet olsun!',
          };
        } else if (mascotId == 'squirrel') {
          return {
            'title': isEn ? 'Pre-Meal Water Break!' : 'Orman meyveleri öncesi su molası!',
            'message': isEn
                ? 'A glass of fresh water before wild berries and nuts aids digestion!'
                : 'Taze fındık ve böğürtlenlerden önce bir bardak su sindirimi rahatlatır, afiyet olsun!',
          };
        } else if (mascotId == 'plant') {
          return {
            'title': isEn ? 'Midday Hydration!' : 'Öğle nemi!',
            'message': isEn
                ? 'Hydrate soil and roots to process nutrients comfortably under midday sun.'
                : 'Öğle vakti besinleri sindirmek için toprağını ve gövdeni nemlendir.',
          };
        } else {
          return {
            'title': isEn ? 'Pre-Meal Water Break!' : 'Sindirim dostu yudum!',
            'message': isEn
                ? 'A fresh glass of water before lunch aids digestion. Bon appétit!'
                : 'Yemek öncesi su içmek sindirimi rahatlatır, afiyet olsun!',
          };
        }

      case MascotState.afternoonSlump:
        if (mascotId == 'cat') {
          return {
            'title': isEn ? 'While you are awake...' : 'Sen hazır uyanıkken...',
            'message': isEn
                ? 'Eyes getting heavy? Grab a cold glass before nodding off!'
                : 'Sen hazır uyanıkken... Gözler süzülmesin, hemen 1 bardak su al! Yoksa uyurum bak!',
          };
        } else if (mascotId == 'dog') {
          return {
            'title': isEn ? 'While you are awake...' : 'Gözüm üstünde, su nerede?',
            'message': isEn
                ? 'Lounging on the rug with eyes on you... Go get a glass of cold water!'
                : 'Sen hazır uyanıkken... Halıya yayıldım ama gözüm üstünde, hemen 1 bardak su al!',
          };
        } else if (mascotId == 'penguin') {
          return {
            'title': isEn ? 'While you are awake...' : 'Buzda rehavet mi çöktü?',
            'message': isEn
                ? 'Belly-flopped on ice waiting for you... Go grab a tall glass of icy water!'
                : 'Sen hazır uyanıkken... Gözler süzülmesin, hemen buz gibi 1 bardak su al!',
          };
        } else if (mascotId == 'panda') {
          return {
            'title': isEn ? 'While you are awake...' : 'Minderde sitemkar bakış...',
            'message': isEn
                ? 'Lounging on the cushion giving you side-eye... Grab a cup of water right now!'
                : 'Sen hazır uyanıkken... Minderden kalkmaya üşeniyorum ama sana bakıyorum, hemen su iç!',
          };
        } else if (mascotId == 'squirrel') {
          return {
            'title': isEn ? 'While you are awake...' : 'Daldan sitem dolu yan bakış...',
            'message': isEn
                ? 'Resting on the tree branch with sassy side-eye... Grab a cup of water before nodding off!'
                : 'Sen hazır uyanıkken... Dala uzandım seni izliyorum, rehaveti dağıtmak için hemen su iç!',
          };
        } else if (mascotId == 'plant') {
          return {
            'title': isEn ? "Don't Wilt!" : 'Yapraklar pörsümesin!',
            'message': isEn
                ? "Don't let afternoon slump bend your leaves. Give a quick revitalizing sip!"
                : 'Öğleden sonra rehaveti yapraklarını bükmesin. Hemen can suyu ver!',
          };
        } else {
          return {
            'title': isEn ? 'Break the Slump!' : 'Rehaveti dağıt!',
            'message': isEn
                ? 'Eyes getting heavy? Grab a cold glass before nodding off!'
                : 'Sen hazır uyanıkken... Gözler süzülmesin, hemen 1 bardak su al!',
          };
        }

      case MascotState.workout:
        if (mascotId == 'cat') {
          return {
            'title': isEn ? 'Keep Energy High!' : 'Mataranı tazele!',
            'message': isEn
                ? 'Sweatband on, workout mode! Keep your hydration and stamina high.'
                : 'Spor bandı takıldı, tempo yükseldi! Enerjini korumak için suyunu ihmal etme.',
          };
        } else if (mascotId == 'dog') {
          return {
            'title': isEn ? 'Keep Energy High!' : 'Kırmızı kafa bandıyla tam gaz!',
            'message': isEn
                ? 'Red headband on, workout mode! Keep your hydration high while running.'
                : 'Kırmızı kafa bandı takıldı, tempo yükseldi! Koşarken suyunu ihmal etme.',
          };
        } else if (mascotId == 'penguin') {
          return {
            'title': isEn ? 'Keep Energy High!' : 'Buz pateni ve tempo vakti!',
            'message': isEn
                ? 'Red sweatband on, sliding workout! Keep your stamina high with glacier water.'
                : 'Kırmızı alın bandı takıldı, tempo yükseldi! Buzda kayarken suyunu ihmal etme.',
          };
        } else if (mascotId == 'panda') {
          return {
            'title': isEn ? 'Keep Energy High!' : 'Panda antrenmanı başladı!',
            'message': isEn
                ? 'Sporty headband on! Gentle panda jogging needs steady water intake.'
                : 'Kırmızı kafa bandı takıldı, tempo yükseldi! Ter atarken suyunu ihmal etme.',
          };
        } else if (mascotId == 'squirrel') {
          return {
            'title': isEn ? 'Keep Energy High!' : 'Daldan dala tam tempo!',
            'message': isEn
                ? 'Sporty headband on, leaping branch to branch! Refill your flask to keep up stamina.'
                : 'Spor kafa bandı takıldı, daldan dala koşuyoruz! Mataranı doldur, temponu koru!',
          };
        } else if (mascotId == 'plant') {
          return {
            'title': isEn ? 'Growth Spurt!' : 'Büyüme atağı!',
            'message': isEn
                ? 'Recover moisture lost during activity and renew your vital cells.'
                : 'Aktif hareket ederken terle kaybettiğin nemi geri kazan, hücrelerini yenile.',
          };
        } else {
          return {
            'title': isEn ? 'Keep Energy High!' : 'Kaybettiğin suyu geri al!',
            'message': isEn
                ? 'Active day! Maintain your hydration and stamina.'
                : 'Günün temposu yüksek! Enerjini korumak için suyunu ihmal etme.',
          };
        }

      case MascotState.evening:
        if (mascotId == 'cat') {
          return {
            'title': isEn ? 'Almost Reached Goal!' : 'Hedefe bir adım kaldı!',
            'message': isEn
                ? 'Cozy armchair purrs... Unwind from the day with a refreshing cup of water.'
                : 'Koltukta huzurlu mırıltılar... Günün yorgunluğunu taze bir bardak suyla atalım.',
          };
        } else if (mascotId == 'dog') {
          return {
            'title': isEn ? 'Almost Reached Goal!' : 'Koltukta kıvrılma keyfi!',
            'message': isEn
                ? 'Curled up in armchair... Unwind from the day with a fresh cup of water.'
                : 'Koltukta kıvrılıp dinlenme vakti... Günün yorgunluğunu taze bir bardak suyla atalım.',
          };
        } else if (mascotId == 'penguin') {
          return {
            'title': isEn ? 'Almost Reached Goal!' : 'Sıcak yuvada akşam serinliği!',
            'message': isEn
                ? 'Cozy blanket on the armchair... Unwind from the day with a cold cup of water.'
                : 'Koltukta battaniyeye sarılıp dinlenme vakti... Günün yorgunluğunu taze suyla atalım.',
          };
        } else if (mascotId == 'panda') {
          return {
            'title': isEn ? 'Almost Reached Goal!' : 'Zen çay fincanında su keyfi!',
            'message': isEn
                ? 'Curled up in armchair sipping peacefully. Just a few steps to the daily goal!'
                : 'Geniş koltuğa yayıldık. Günün yorgunluğunu sakin bir fincan suyla atalım.',
          };
        } else if (mascotId == 'squirrel') {
          return {
            'title': isEn ? 'Almost Reached Goal!' : 'Kuyruğuna sarılıp dinlenme!',
            'message': isEn
                ? 'Bushy tail wrapped like a blanket on the armchair. Just a couple of sips to reach the goal!'
                : 'Pofuduk kuyruğuma sarıldım, koltukta dinleniyorum. Hedefe çok az kaldı, suyunu iç!',
          };
        } else if (mascotId == 'plant') {
          return {
            'title': isEn ? 'Breathe in Cool Air!' : 'Akşam serinliğiyle nefes al!',
            'message': isEn
                ? 'The sun is down. Unwind by feeding roots with evening freshness.'
                : 'Günün güneşi bitti. Akşam serinliğinde köklerine su vererek dinlen.',
          };
        } else {
          return {
            'title': isEn ? 'Almost Reached Goal!' : 'Akşam gevşemesi!',
            'message': isEn
                ? 'Unwind from today. Just a couple of cups left to finish.'
                : 'Günün yorgunluğunu atıyoruz. Hedefe ulaşmaya çok az kaldı!',
          };
        }

      case MascotState.bedtime:
        if (mascotId == 'cat') {
          return {
            'title': isEn ? 'Just One Last Sip!' : 'Hadi son bir yudum!',
            'message': isEn
                ? 'One last sip before bed, sweet dreams... 🌙💤'
                : 'Uykucu gecelik beremi taktım! Hadi son bir yudum; gece susuz kalma, tatlı rüyalar... 🌙💤',
          };
        } else if (mascotId == 'dog') {
          return {
            'title': isEn ? 'Just One Last Sip!' : 'Hadi son bir yudum!',
            'message': isEn
                ? 'Cozy nightcap on, one last sip before bedtime. Sweet dreams! 🌙💤'
                : 'Pofuduk gece beremi taktım! Hadi son bir yudum; gece susuz kalma, tatlı rüyalar... 🌙💤',
          };
        } else if (mascotId == 'penguin') {
          return {
            'title': isEn ? 'Just One Last Sip!' : 'Hadi son bir yudum!',
            'message': isEn
                ? 'Striped pompom cap on, cozy igloo bed is ready. One last sip before sleep! 🌙💤'
                : 'Ponponlu uyku beremi taktım! Hadi son bir serin yudum, tatlı rüyalar... 🌙💤',
          };
        } else if (mascotId == 'panda') {
          return {
            'title': isEn ? 'Just One Last Sip!' : 'Hadi son bir yudum!',
            'message': isEn
                ? 'Sleeping nightcap on, stars are shining. One last sip before sweet dreams... 🌙💤'
                : 'Uyku beremi taktım, esniyorum. Uyumadan önce son bir yudum su al, huzurlu rüyalar... 🌙💤',
          };
        } else if (mascotId == 'squirrel') {
          return {
            'title': isEn ? 'Just One Last Sip!' : 'Hadi son bir yudum!',
            'message': isEn
                ? 'Cozy nightcap on, tail wrapped tight. One last sip before bed, sweet dreams! 🌙💤'
                : 'Uyku takkemi taktım, kuyruğumu üstüme çektim. Yatmadan önce son bir yudum su al! 🌙💤',
          };
        } else if (mascotId == 'plant') {
          return {
            'title': isEn ? 'Just One Last Sip!' : 'Hadi son bir yudum!',
            'message': isEn
                ? 'Take a sip of water so your roots stay hydrated through the night. Good night.'
                : 'Gece boyunca köklerinin kurumaması için son bir yudum su iç, iyi geceler.',
          };
        } else {
          return {
            'title': isEn ? 'Just One Last Sip!' : 'Hadi son bir yudum!',
            'message': isEn
                ? 'One last sip before bed, sweet dreams... 🌙💤'
                : 'Hadi son bir yudum! Gece susuz kalma, tatlı rüyalar... 🌙💤',
          };
        }

      case MascotState.goalReached:
        if (mascotId == 'cat') {
          return {
            'title': isEn ? 'You Champion!' : 'İşte bu, şampiyon!',
            'message': isEn
                ? "Trophy raised, confetti bursting! You are today's hydration champion! 🏆🎉"
                : 'Kupayı kaldırdık, konfetiler patladı! Günün şampiyon kedisi sensin! 🏆🎉',
          };
        } else if (mascotId == 'dog') {
          return {
            'title': isEn ? 'You Champion!' : 'Kupayı kaptık, şampiyon köpek!',
            'message': isEn
                ? "Trophy won, confetti flying! You are today's hydration champion! 🏆🎉"
                : 'Kupayı kaptık, konfetiler havada! Günün şampiyon köpüşü sensin! 🏆🎉',
          };
        } else if (mascotId == 'penguin') {
          return {
            'title': isEn ? 'You Champion!' : 'Kutup kupası ellerde!',
            'message': isEn
                ? "Polar trophy raised, confetti on ice! You are today's hydration champion! 🏆❄️"
                : 'Buz kupasını kaldırdık, konfetiler havada! Günün kutup şampiyonu sensin! 🏆❄️',
          };
        } else if (mascotId == 'panda') {
          return {
            'title': isEn ? 'You Champion!' : 'Altın kupa ellerde, bambu şöleni!',
            'message': isEn
                ? "Golden trophy raised, bamboo confetti bursting! You are today's hydration champion! 🏆🎋"
                : 'Altın kupayı kaldırdık, konfetiler patladı! Günün şampiyon pandası sensin! 🏆🎋',
          };
        } else if (mascotId == 'squirrel') {
          return {
            'title': isEn ? 'You Champion!' : 'Altın palamut kupası havada!',
            'message': isEn
                ? "Golden acorn trophy raised high! Confetti fluttering, you are the forest hydration champion! 🏆🌰"
                : 'Altın palamut kupasını kaldırdık! Ormanın su şampiyonu sensin, tebrikler! 🏆🐿️',
          };
        } else if (mascotId == 'plant') {
          return {
            'title': isEn ? 'Mighty Plane Tree!' : 'Koca bir çınar açtı!',
            'message': isEn
                ? 'Magnificent! You completed your daily goal, vibrant and blooming like pure nature! 🌳🌸'
                : 'Muhteşem! Günlük su hedefini tamamladın, doğa gibi capcanlı ve güçlüsün! 🌳🌸',
          };
        } else {
          return {
            'title': isEn ? 'You Champion!' : 'Zirveye ulaştın!',
            'message': isEn
                ? 'Congratulations! You reached your daily goal!'
                : 'Tebrikler! Günlük su hedefini tamamladın!',
          };
        }

      case MascotState.thirsty:
        if (mascotId == 'cat') {
          return {
            'title': isEn ? 'Heeey! Forgot About Me?' : 'Alooo! Beni unuttun mu?',
            'message': isEn
                ? 'Meow! So thirsty, could you spare a sip of water?'
                : 'Miyav! Boğazım kurudu, bardağım bomboş kaldı. Lütfen hemen bir bardak su ver!',
          };
        } else if (mascotId == 'dog') {
          return {
            'title': isEn ? 'Heeey! Forgot About Me?' : 'Hav hav! Su kabım bomboş!',
            'message': isEn
                ? 'Woof woof! So thirsty, my water bowl is empty! Please share some water!'
                : 'Hav hav! Boğazım kurudu, su kabım bomboş kaldı! Lütfen hemen bir bardak su ver!',
          };
        } else if (mascotId == 'penguin') {
          return {
            'title': isEn ? 'Heeey! Forgot About Me?' : 'Buzlar eriyor, çöl gibi oldu!',
            'message': isEn
                ? 'Ice is melting! Refresh yourself with cool water.'
                : 'Buzlar eriyor! Hemen taze suyla ferahla.',
          };
        } else if (mascotId == 'panda') {
          return {
            'title': isEn ? 'Heeey! Forgot About Me?' : 'Bambu bardağım bomboş kaldı!',
            'message': isEn
                ? 'Panting on the floor! Bamboo cup is empty, please share a glass of water!'
                : 'Nefesim kesildi, bambu bardağım bomboş! Lütfen hemen bana bir bardak su ver!',
          };
        } else if (mascotId == 'squirrel') {
          return {
            'title': isEn ? 'Heeey! Forgot About Me?' : 'Fındıklar kurudu, acil su!',
            'message': isEn
                ? 'Dropping all acorns! Need fresh water right now!'
                : 'Fındıklar kurudu, boğazım çöl oldu! Hemen su molası ver!',
          };
        } else if (mascotId == 'plant') {
          return {
            'title': isEn ? 'Soil Parched!' : 'Toprak çatladı, acil su!',
            'message': isEn
                ? 'Leaves turning yellow, soil is parched! Please give some revitalizing water.'
                : 'Yapraklarım sararıyor, toprak kurudu! Lütfen hemen biraz can suyu ver.',
          };
        } else {
          return {
            'title': isEn ? 'Heeey! Forgot About Me?' : 'Acil su molası!',
            'message': isEn
                ? 'Parched like a desert! Please share a glass of water!'
                : 'Çok uzun süredir su içmedin! Vücudunu hemen taze bir bardak suyla canlandır.',
          };
        }

      case MascotState.streakFire:
        if (mascotId == 'cat') {
          return {
            'title': isEn ? 'Streak on Fire!' : 'Serimiz alev alev! 🔥',
            'message': isEn
                ? '$streakDays days strong like a superhero! Keep the fire burning! 🔥'
                : '$streakDays günlük seriyi süper kahraman gibi koruyoruz! Alevler sönmesin! 🔥',
          };
        } else if (mascotId == 'dog') {
          return {
            'title': isEn ? 'Streak on Fire!' : 'Kahraman pelerini dalgalanıyor!',
            'message': isEn
                ? '$streakDays days strong like a superhero! Keep the fire burning! 🔥'
                : '$streakDays günlük seriyi süper kahraman peleriniyle koruyoruz! Alevler sönmesin! 🔥',
          };
        } else if (mascotId == 'penguin') {
          return {
            'title': isEn ? 'Streak on Fire!' : 'Kutup peleriniyle buz ve alev!',
            'message': isEn
                ? '$streakDays days strong! Polar superhero protecting the flames! 🔥❄️'
                : '$streakDays günlük seriyi kutup peleriniyle koruyoruz! Alevler sönmesin! 🔥❄️',
          };
        } else if (mascotId == 'panda') {
          return {
            'title': isEn ? 'Streak on Fire!' : 'Zen kahramanı su asasını kaldırdı!',
            'message': isEn
                ? '$streakDays days strong! Zen hero wielding the water staff, keep the flame burning! 🔥🎋'
                : '$streakDays günlük seriyi su asasıyla koruyoruz! Bambu ateşi parlasın! 🔥🎋',
          };
        } else if (mascotId == 'squirrel') {
          return {
            'title': isEn ? 'Streak on Fire!' : 'Süper sincap palamut asasıyla nöbette!',
            'message': isEn
                ? '$streakDays days strong! Superhero squirrel cape flying, protecting the hydration flame! 🔥🌰'
                : '$streakDays günlük seriyi palamut ateşiyle koruyoruz! Bu efsane alışkanlık sönmesin! 🔥🌰',
          };
        } else if (mascotId == 'plant') {
          return {
            'title': isEn ? 'Deep Roots Streak!' : 'Köklü ve sarsılmaz seri!',
            'message': isEn
                ? 'Watered faithfully for $streakDays days! Your roots are stronger than ever! 🌿🔥'
                : '$streakDays gündür düzenli sulanıyorsun! Köklerin her zamankinden daha sağlam ve güçlü! 🌿🔥',
          };
        } else {
          return {
            'title': isEn ? 'Streak on Fire!' : 'Alev alev hidrasyon serisi!',
            'message': isEn
                ? '$streakDays days strong! Keep this legendary habit blazing!'
                : '$streakDays günlük seriyi bugün de koru, hidrasyon ateşi parlasın! 🔥',
          };
        }
    }
  }

  /// Specialized champion dialogues tailored to keep hydration engaging and lively throughout the day even after reaching 100%
  static Map<String, String>? _getChampionRoutineDialogue({
    required String mascotId,
    required MascotState state,
    required bool isEn,
    int streakDays = 0,
  }) {
    switch (state) {
      case MascotState.bedtime:
        if (mascotId == 'cat') {
          return {
            'title': isEn ? 'Champions Sleep Too!' : 'Şampiyonlar da uyur!',
            'message': isEn
                ? 'Goal crushed, trophy won! Nightcap on; take one last sip before bed, sweet dreams... 🌙💤'
                : 'Hedef tamam, kupa cepte! Pofuduk uyku beremi taktım; geceyi susuz kapatma, tatlı rüyalar... 🌙💤',
          };
        } else if (mascotId == 'dog') {
          return {
            'title': isEn ? 'Champion Pup Bedtime!' : 'Şampiyon köpüşün tatlı uykusu!',
            'message': isEn
                ? 'You were amazing today! Nightcap on; take one last sip before sleep, rest well... 🌙💤'
                : 'Bugün harikaydın! Uyku beremi taktım; yatmadan önce son bir yudum al, güzelce dinlenelim... 🌙💤',
          };
        } else if (mascotId == 'penguin') {
          return {
            'title': isEn ? 'Igloo Champion Sleep!' : 'İgloda şampiyon uykusu!',
            'message': isEn
                ? 'Trophy raised, time to sleep in the igloo! End the night with a cool sip of water... 🌙💤'
                : 'Kupayı kaldırdık, igloda uyku vakti! Geceye bir yudum serin suyla veda edelim... 🌙💤',
          };
        } else if (mascotId == 'panda') {
          return {
            'title': isEn ? 'Peaceful Champion Sleep!' : 'Huzurlu şampiyon uykusu!',
            'message': isEn
                ? 'Water cup finished, nightcap on. Rest like a champion, sweet dreams... 🌙💤'
                : 'Bambu fincanında su bitti, uyku beresi takıldı. Şampiyon gibi dinlen, tatlı rüyalar... 🌙💤',
          };
        } else if (mascotId == 'squirrel') {
          return {
            'title': isEn ? 'Cozy Champion Bedtime!' : 'Kuyruğuna sarılan şampiyon!',
            'message': isEn
                ? 'Goal achieved! Tail curled up tight; take one last sip before bed, good night... 🌙💤'
                : 'Hedefi devirdik! Kuyruğumu üstüme çektim; yatmadan önce son bir yudum su al, iyi geceler... 🌙💤',
          };
        } else if (mascotId == 'plant') {
          return {
            'title': isEn ? 'Night Dew of Victory!' : 'Zaferin gece çiyi!',
            'message': isEn
                ? 'Goal reached! Take one last sip so your roots stay vibrant through the night... 🌙💤'
                : 'Hedef tamamlandı! Gece boyunca köklerinin zinde kalması için son bir yudum su iç... 🌙💤',
          };
        } else {
          return {
            'title': isEn ? 'Champions Rest Too!' : 'Şampiyonlar da dinlenir!',
            'message': isEn
                ? 'Daily goal achieved! Take one last sip to stay hydrated through the night... 🌙💤'
                : 'Bugünkü hedefin fazlasıyla tamamlandı! Gece boyunca zinde kalmak için son bir yudum su al... 🌙💤',
          };
        }

      case MascotState.afternoonSlump:
        if (mascotId == 'cat') {
          return {
            'title': isEn ? 'While you are awake...' : 'Sen hazır uyanıkken...',
            'message': isEn
                ? 'No slumping just because the goal is done! Lounging on the rug with eyes on you; grab a champion bonus glass! 😉'
                : 'Hedefi geçtik diye rehavete kapılmak yok! Halıya yayıldım ama gözüm üstünde; şampiyonluk turunda bir bardak daha su al! 😉',
          };
        } else if (mascotId == 'dog') {
          return {
            'title': isEn ? 'While you are awake...' : 'Minderde gözüm üstünde!',
            'message': isEn
                ? 'Lounging sideways with tail alert! Let us refresh our record with a bonus champion cup. 😉'
                : 'Minderde yan yatıyorum ama kuyruk tetikte! Şampiyonluk turunda bir bardak daha suyla rekor tazeleyelim. 😉',
          };
        } else if (mascotId == 'penguin') {
          return {
            'title': isEn ? 'Ice Champion Slump!' : 'Buzda şampiyon rehaveti!',
            'message': isEn
                ? 'While you are awake... Lounging on the ice; a cold bonus glass fits the champion victory lap!'
                : 'Sen hazır uyanıkken... Buzun üstüne uzandım ama izliyorum; şampiyonluk turuna buz gibi bir bardak su yakışır!',
          };
        } else if (mascotId == 'panda') {
          return {
            'title': isEn ? 'Sassy Side-eye Slump...' : 'Minderde sitemkar bakış...',
            'message': isEn
                ? 'While you are awake... Goal is done but I am too cozy to move; go grab a champion bonus cup of water!'
                : 'Sen hazır uyanıkken... Hedefi tamamladık ama kalkmaya üşeniyorum, şampiyonluk bonusu için hemen bir fincan su kap!',
          };
        } else if (mascotId == 'squirrel') {
          return {
            'title': isEn ? 'Branch Sassy Side-eye...' : 'Daldan sitem dolu yan bakış...',
            'message': isEn
                ? 'While you are awake... Watching from the tree branch; crown your victory lap with another crisp glass!'
                : 'Sen hazır uyanıkken... Dala uzandım seni izliyorum; şampiyonluk turunu fındık tadında bir bardak suyla taçlandır!',
          };
        } else {
          return {
            'title': isEn ? 'Keep Vitality High!' : 'Rehavete teslim olma!',
            'message': isEn
                ? 'You are today champion! Keep the freshness going with a bonus glass of water.'
                : 'Günün şampiyonusun ama ferahlığı elden bırakma! Bir bardak can suyuyla rekorunu daha da yukarı taşı.',
          };
        }

      case MascotState.workout:
        if (mascotId == 'cat') {
          return {
            'title': isEn ? 'Victory Marathon!' : 'Şampiyonluk maratonu!',
            'message': isEn
                ? 'Sweatband on, high tempo! Goal is secured but keep moving; every extra sip is bonus hydration! ⚡'
                : 'Kırmızı kafa bandı takıldı, tempo yükseldi! Hedef cepte ama hareket bitmedi; ekstra her yudum bir bonus puan! ⚡',
          };
        } else if (mascotId == 'dog') {
          return {
            'title': isEn ? 'Victory Marathon!' : 'Şampiyonluk maratonu!',
            'message': isEn
                ? 'Red headband on, running full speed! Goal reached, now running the bonus hydration lap! ⚡'
                : 'Kırmızı kafa bandıyla tam gaz koşuyoruz! Hedef tamam, şimdi bonus hidrasyon turundayız! ⚡',
          };
        } else if (mascotId == 'penguin') {
          return {
            'title': isEn ? 'Ice Victory Skate!' : 'Buzda şampiyonluk kayışı!',
            'message': isEn
                ? 'Headband on, sliding fast across the ice! A bonus chill sip feels amazing after the trophy! ⚡'
                : 'Alın bandını taktım, buzda tam tempo kayıyorum! Şampiyonluk kupasından sonra bonus serinlik harika! ⚡',
          };
        } else if (mascotId == 'panda') {
          return {
            'title': isEn ? 'Panda Victory Lap!' : 'Panda şampiyonluk turu!',
            'message': isEn
                ? 'Red headband on! Goal crushed with high energy; keep your flask full and stay energized! ⚡'
                : 'Kırmızı bandı taktım! Hedef devrildi ama enerjimiz tam; mataranı tazeleyip canlılığı koru! ⚡',
          };
        } else if (mascotId == 'squirrel') {
          return {
            'title': isEn ? 'Branch to Branch Victory Run!' : 'Daldan dala şampiyonluk koşusu!',
            'message': isEn
                ? 'Sweatband on, celebrating branch to branch! Keep up your champion pace with a fresh sip! ⚡'
                : 'Spor bandı takıldı, daldan dala kutlama yapıyoruz! Bir yudum suyla şampiyonluk hızını koru! ⚡',
          };
        } else {
          return {
            'title': isEn ? 'Supercharged Stamina!' : 'Süper şarjlı tempo!',
            'message': isEn
                ? 'You surpassed your goal, great form! Keep your energy at the peak with every extra sip.'
                : 'Hedefini aştın, harika bir formdasın! Fazladan her yudumla enerjini zirvede tut.',
          };
        }

      case MascotState.evening:
        if (mascotId == 'cat') {
          return {
            'title': isEn ? 'Armchair Champion Rest!' : 'Koltukta şampiyonluk keyfi!',
            'message': isEn
                ? 'Cozy purrs in the armchair... You are today champion; unwind with a fresh cup of water.'
                : 'Koltukta mırıl mırıl huzur... Günün şampiyonusun; bir yudum taze suyla günün yorgunluğunu atalım.',
          };
        } else if (mascotId == 'dog') {
          return {
            'title': isEn ? 'Armchair Champion Rest!' : 'Koltukta şampiyonluk keyfi!',
            'message': isEn
                ? 'Curled up resting in the armchair... Goal is done, let us enjoy with a fresh cup of water.'
                : 'Koltukta kıvrılıp dinlenme vakti... Hedefi tamamladık, taze bir bardak suyla keyfimize bakalım.',
          };
        } else if (mascotId == 'penguin') {
          return {
            'title': isEn ? 'Warm Igloo Evening!' : 'Sıcak yuvada akşam keyfi!',
            'message': isEn
                ? 'Trophy won, wrapped in blanket! Celebrate today victory with a calm cup of water.'
                : 'Kupayı kazandık, battaniyeye sarıldık! Günün şampiyonluğuna sakin bir fincan su eşlik etsin.',
          };
        } else if (mascotId == 'panda') {
          return {
            'title': isEn ? 'Zen Cup Victory Sip!' : 'Zen fincanda zafer suyu!',
            'message': isEn
                ? 'Lounging in the big chair, trophy beside us. Unwinding like a champion with a calm sip.'
                : 'Geniş koltuğa yayıldık, kupa yanımızda. Günün şampiyonu olarak sakin bir yudum suyla dinleniyoruz.',
          };
        } else if (mascotId == 'squirrel') {
          return {
            'title': isEn ? 'Cozy Tail Victory Unwind!' : 'Kuyruğa sarılıp şampiyonluk keyfi!',
            'message': isEn
                ? 'Wrapped in my bushy tail, resting cozy. Savor the victory with a fresh cup of water!'
                : 'Kuyruğuma sarıldım, koltukta dinleniyorum. Şampiyonluğun tadını taze bir fincan suyla çıkar!',
          };
        } else {
          return {
            'title': isEn ? 'Evening Cool & Victory!' : 'Akşam serinliği & Zafer!',
            'message': isEn
                ? 'You crushed the daily goal! Reward your body with a fresh cup while unwinding.'
                : 'Günün hedefini devirdin! Akşam dinlenirken bir bardak suyla bedenini ödüllendir.',
          };
        }

      case MascotState.thirsty:
        if (mascotId == 'cat') {
          return {
            'title': isEn ? "Don't Dry Up, Champion!" : 'Şampiyon kuruyup kalmasın!',
            'message': isEn
                ? 'Did you forget us just because you got the trophy? Grab a cup of water to refresh your record!'
                : 'Kupayı aldık diye bizi unuttun mu? Şampiyonluk rekorunu tazelemek için hemen 1 bardak su kap!',
          };
        } else if (mascotId == 'dog') {
          return {
            'title': isEn ? 'Champion Pup is Thirsty!' : 'Şampiyon köpüş susadı!',
            'message': isEn
                ? 'We won the trophy but have not had water in a while! Time for a victory water bowl refill!'
                : 'Kupayı kaldırdık ama uzun süre su içmedik! Şampiyonluk turunda bir kase su tazelemesi şart!',
          };
        } else if (mascotId == 'penguin') {
          return {
            'title': isEn ? 'Ice-cold Victory Sip!' : 'Buz gibi bir zafer yudumu!',
            'message': isEn
                ? 'Trophy won, but my beak is dry! Let us revitalize our champion lap with cold water.'
                : 'Kupayı aldık ama gagam kurudu! Şampiyonluk turunu taze bir buzlu suyla canlandıralım.',
          };
        } else if (mascotId == 'panda') {
          return {
            'title': isEn ? 'Panda Wants a New Record!' : 'Panda rekor tazelemek istiyor!',
            'message': isEn
                ? 'The bamboo cup is empty! We did not forget our trophy, let us wet our whistle with water.'
                : 'Bambu fincanı boş kaldı! Şampiyonluğumuzu unutmadık ama bir bardak suyla boğazımızı ıslatalım.',
          };
        } else if (mascotId == 'squirrel') {
          return {
            'title': isEn ? "Don't Let the Trophy Dry!" : 'Fındık kupası boş kalmasın!',
            'message': isEn
                ? 'Trophy secured, but tiny paws are thirsty! Grab a glass of water on your victory lap!'
                : 'Kupayı kaptık ama minik patiler susadı! Şampiyonluk turunda hemen 1 bardak su kap!',
          };
        } else {
          return {
            'title': isEn ? 'Champion Revitalizer!' : 'Şampiyonun can suyu!',
            'message': isEn
                ? 'Goal secured, but time has passed without water. Grab a glass to maintain high vitality!'
                : 'Hedef cepte ama uzun süre su içmedin. Canlılığını korumak için hemen bir bardak su al!',
          };
        }

      case MascotState.streakFire:
        return {
          'title': isEn ? 'Fiery Champion!' : 'Alev alev şampiyon!',
          'message': isEn
              ? '$streakDays days strong and goal completed! You are a true hydration superhero. 🔥🏆'
              : '$streakDays günlük seri korundu ve hedef tamamlandı! Gerçek bir hidrasyon süper kahramanısın. 🔥🏆',
        };

      case MascotState.workFocus:
        return {
          'title': isEn ? 'Champion at the Desk!' : 'Masa başında şampiyon odak!',
          'message': isEn
              ? 'Goal achieved! Keep a fresh glass close at the desk to maintain sharp focus.'
              : 'Hedef tamamlandı! Zihnini keskin tutmak için masa başında suyunu yudumlamaya devam et.',
        };

      case MascotState.lunch:
        return {
          'title': isEn ? 'Champion Lunch Break!' : 'Şampiyonun yemek molası!',
          'message': isEn
              ? 'Goal achieved! Enjoy lunch with a refreshing glass of water. Bon appétit!'
              : 'Hedef tamam! Yemeğin yanında taze bir bardak suyla kutlamaya devam. Afiyet olsun!',
        };

      case MascotState.morning:
        return {
          'title': isEn ? 'Morning Champion!' : 'Sabahın şampiyonu!',
          'message': isEn
              ? 'Starting with championship energy! Keep the momentum going with fresh water.'
              : 'Güne şampiyonluk enerjisiyle başladın! Canlılığını korumak için suyunu ihmal etme.',
        };

      case MascotState.goalReached:
      default:
        return null;
    }
  }

  /// Directly resolves a single routine state for preview dialogs without energy overrides
  static MascotDialogue resolveDialogueForState({
    required String mascotType,
    required MascotState state,
    String lang = 'tr',
    int streakDays = 5,
  }) {
    final isEn = lang == 'en';
    final mascot = MascotCatalog.getById(mascotType);
    final data = getRoutineDialogue(
      mascotId: mascot.id,
      state: state,
      isEn: isEn,
      streakDays: streakDays,
    );
    final emoji = getStateEmoji(mascot.id, state);
    final hexColor = getStateHexColor(state);
    final isAnimal = mascot.id == 'cat' ||
        mascot.id == 'dog' ||
        mascot.id == 'penguin' ||
        mascot.id == 'panda' ||
        mascot.id == 'squirrel';
    final imageAsset = isAnimal
        ? 'assets/mascots/${mascot.id}_${state.assetSuffix}.png'
        : mascot.defaultImageAsset;

    return MascotDialogue(
      title: data['title']!,
      message: data['message']!,
      emoji: emoji,
      imageAsset: imageAsset,
      state: state,
      hexColor: hexColor,
      energyImageAsset: imageAsset,
      energyPercentage: 100,
      energyTitle: data['title']!,
      energyMessage: data['message']!,
      routineImageAsset: imageAsset,
      routineTitle: data['title']!,
      routineMessage: data['message']!,
    );
  }

  /// Directly resolves a single energy ladder tier for preview dialogs
  static MascotDialogue resolveDialogueForEnergyTier({
    required String mascotType,
    required MascotEnergyTier tier,
    String lang = 'tr',
  }) {
    final isEn = lang == 'en';
    final mascot = MascotCatalog.getById(mascotType);
    final energyData = MascotEnergyLadder.getDialogue(
      mascotId: mascot.id,
      tier: tier,
      isEn: isEn,
    );
    final isAnimal = mascot.id == 'cat' ||
        mascot.id == 'dog' ||
        mascot.id == 'penguin' ||
        mascot.id == 'panda' ||
        mascot.id == 'squirrel';
    final imageAsset = isAnimal
        ? 'assets/mascots/${mascot.id}_${tier.fileSuffix}.png'
        : mascot.defaultImageAsset;

    final String hexColor;
    switch (tier) {
      case MascotEnergyTier.energy0:
        hexColor = 'E11D48';
        break;
      case MascotEnergyTier.energy25:
        hexColor = 'F59E0B';
        break;
      case MascotEnergyTier.energy50:
        hexColor = '10B981';
        break;
      case MascotEnergyTier.energy75:
        hexColor = '06B6D4';
        break;
      case MascotEnergyTier.energy100:
        hexColor = '8B5CF6';
        break;
    }

    return MascotDialogue(
      title: energyData['title']!,
      message: energyData['message']!,
      emoji: tier.stepValue >= 100 ? '👑' : (tier.stepValue >= 50 ? '💧' : '🥱'),
      imageAsset: imageAsset,
      state: tier.stepValue >= 100 ? MascotState.goalReached : MascotState.morning,
      hexColor: hexColor,
      energyImageAsset: imageAsset,
      energyPercentage: tier.stepValue,
      energyTitle: energyData['title']!,
      energyMessage: energyData['message']!,
      routineImageAsset: imageAsset,
      routineTitle: energyData['title']!,
      routineMessage: energyData['message']!,
    );
  }
}

