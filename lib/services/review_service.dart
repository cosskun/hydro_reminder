import 'package:flutter/foundation.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ReviewService {
  static final ReviewService _instance = ReviewService._internal();
  factory ReviewService() => _instance;
  ReviewService._internal();

  static const String _keyHasRated = 'has_rated_app_v1';
  static const String _keyLastPromptDate = 'last_review_prompt_date_v1';
  static const String _keyPromptCount = 'review_prompt_count_v1';

  // HydroSoft iOS App Store ID (Allocated on Apple App Store Connect)
  static const String appStoreId = '6743126744';

  final InAppReview _inAppReview = InAppReview.instance;

  // Check if user has already rated/reviewed the app
  Future<bool> hasRated() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_keyHasRated) ?? false;
    } catch (_) {
      return false;
    }
  }

  // Permanently flag that the user has rated the app (so no popup ever shows again)
  Future<void> markAsRated() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_keyHasRated, true);
    } catch (_) {}
  }

  // Determine if it is appropriate to prompt for review
  Future<bool> shouldPromptReview() async {
    if (kIsWeb) return false;
    try {
      final prefs = await SharedPreferences.getInstance();
      final hasAlreadyRated = prefs.getBool(_keyHasRated) ?? false;
      if (hasAlreadyRated) return false;

      final lastPromptStr = prefs.getString(_keyLastPromptDate);
      if (lastPromptStr != null) {
        final lastPrompt = DateTime.tryParse(lastPromptStr);
        if (lastPrompt != null) {
          // Never re-prompt within 30 days
          if (DateTime.now().difference(lastPrompt).inDays < 30) {
            return false;
          }
        }
      }
      return true;
    } catch (_) {
      return false;
    }
  }

  // High-impact trigger check: 3-day streak reached OR new badge unlocked
  Future<bool> checkAndPromptIfEligible({
    required int streak,
    bool isNewBadgeUnlocked = false,
  }) async {
    if (!await shouldPromptReview()) return false;

    // Condition 1: 3-day streak or more
    // Condition 2: New badge unlocked
    final isEligible = streak >= 3 || isNewBadgeUnlocked;
    if (!isEligible) return false;

    await promptReview();
    return true;
  }

  // Prompt native in-app review dialog (StoreKit on iOS / Google Play In-App Review on Android)
  Future<void> promptReview() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyLastPromptDate, DateTime.now().toIso8601String());
      final count = (prefs.getInt(_keyPromptCount) ?? 0) + 1;
      await prefs.setInt(_keyPromptCount, count);

      if (await _inAppReview.isAvailable()) {
        await _inAppReview.requestReview();
      } else {
        await openStore();
      }
    } catch (_) {}
  }

  // Directly navigate to platform store (iOS App Store or Google Play)
  Future<void> openStore() async {
    try {
      await markAsRated(); // Mark as rated so future prompts are completely suppressed
      if (defaultTargetPlatform == TargetPlatform.iOS) {
        await _inAppReview.openStoreListing(appStoreId: appStoreId);
      } else if (defaultTargetPlatform == TargetPlatform.android) {
        await _inAppReview.openStoreListing();
      }
    } catch (_) {}
  }
}
