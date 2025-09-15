import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// 広告サービス
class AdService {
  static AdService? _instance;
  static AdService get instance => _instance ??= AdService._();

  AdService._();

  // 広告IDの設定（テスト用ID）
  static String get _interstitialAdUnitId {
    if (kDebugMode) {
      // テスト用広告ID
      if (Platform.isAndroid) {
        return 'ca-app-pub-3940256099942544/1033173712';
      } else if (Platform.isIOS) {
        return 'ca-app-pub-3940256099942544/4411468910';
      }
    } else {
      // 本番用広告ID（後で設定）
      if (Platform.isAndroid) {
        return 'YOUR_ANDROID_INTERSTITIAL_AD_UNIT_ID';
      } else if (Platform.isIOS) {
        return 'YOUR_IOS_INTERSTITIAL_AD_UNIT_ID';
      }
    }
    throw UnsupportedError('Unsupported platform');
  }

  InterstitialAd? _interstitialAd;
  bool _isAdLoaded = false;
  int _questionsAnswered = 0;

  /// 広告サービスの初期化
  Future<void> initialize() async {
    await MobileAds.instance.initialize();
    _loadInterstitialAd();
  }

  /// インタースティシャル広告の読み込み
  void _loadInterstitialAd() {
    InterstitialAd.load(
      adUnitId: _interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _isAdLoaded = true;
          _setupAdCallbacks();
        },
        onAdFailedToLoad: (error) {
          _isAdLoaded = false;
          // エラー時は次回のタイミングで再読み込み
          Future.delayed(const Duration(seconds: 30), () {
            _loadInterstitialAd();
          });
        },
      ),
    );
  }

  /// 広告のコールバック設定
  void _setupAdCallbacks() {
    _interstitialAd?.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _interstitialAd = null;
        _isAdLoaded = false;
        // 次の広告を読み込み
        _loadInterstitialAd();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _interstitialAd = null;
        _isAdLoaded = false;
        _loadInterstitialAd();
      },
    );
  }

  /// 質問に回答したときの処理
  void onQuestionAnswered() {
    _questionsAnswered++;

    // 20問ごとに広告表示
    if (_questionsAnswered % 20 == 0) {
      showInterstitialAd();
    }
  }

  /// 分析を見る前の広告表示
  void onBeforeShowingAnalysis() {
    showInterstitialAd();
  }

  /// インタースティシャル広告の表示
  Future<void> showInterstitialAd() async {
    if (_isAdLoaded && _interstitialAd != null) {
      await _interstitialAd!.show();
    }
  }

  /// リソースの解放
  void dispose() {
    _interstitialAd?.dispose();
  }
}