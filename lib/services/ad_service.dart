import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdHelper {
  static const String _androidBannerId =
      'ca-app-pub-3940256099942544/6300978111';
  static const String _androidInterstitialId =
      'ca-app-pub-3940256099942544/1033173712';
  static const String _androidRewardedId =
      'ca-app-pub-3940256099942544/5224354917';

  static bool get _isSupportedPlatform {
    if (kIsWeb) {
      return false;
    }
    return defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS;
  }

  static bool get isSupported => _isSupportedPlatform;

  static BannerAd? getBannerAd({VoidCallback? onAdLoaded}) {
    if (!_isSupportedPlatform) {
      return null;
    }

    final banner = BannerAd(
      adUnitId: _androidBannerId,
      request: const AdRequest(),
      size: AdSize.mediumRectangle,
      listener: BannerAdListener(
        onAdLoaded: (ad) => onAdLoaded?.call(),
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
        },
      ),
    )..load();

    return banner;
  }

  static Future<InterstitialAd?> loadInterstitial() async {
    if (!_isSupportedPlatform) {
      return null;
    }

    final completer = Completer<InterstitialAd?>();

    await InterstitialAd.load(
      adUnitId: _androidInterstitialId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) => completer.complete(ad),
        onAdFailedToLoad: (error) => completer.complete(null),
      ),
    );

    return completer.future;
  }

  static Future<bool> loadRewardedAd({required VoidCallback onReward}) async {
    if (!_isSupportedPlatform) {
      debugPrint('Rewarded ads not supported on this platform.');
      return false;
    }

    var loaded = false;
    try {
      await RewardedAd.load(
        adUnitId: _androidRewardedId,
        request: const AdRequest(),
        rewardedAdLoadCallback: RewardedAdLoadCallback(
          onAdLoaded: (ad) {
            loaded = true;
            ad.fullScreenContentCallback = FullScreenContentCallback(
              onAdDismissedFullScreenContent: (ad) => ad.dispose(),
              onAdFailedToShowFullScreenContent: (ad, error) {
                debugPrint('Rewarded ad show error: ${error.message}');
                ad.dispose();
              },
            );

            ad.show(
              onUserEarnedReward: (_, _) {
                try {
                  onReward();
                } catch (callbackError) {
                  debugPrint('Reward callback threw: $callbackError');
                }
              },
            );
          },
          onAdFailedToLoad: (error) {
            debugPrint('Rewarded ad failed to load: ${error.message}');
          },
        ),
      );
    } catch (error) {
      debugPrint('Rewarded ad exception: $error');
      return false;
    }

    return loaded;
  }
}
