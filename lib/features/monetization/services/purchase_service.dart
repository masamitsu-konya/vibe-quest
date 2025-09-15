import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// 課金状態を管理するProvider
final purchaseServiceProvider = StateNotifierProvider<PurchaseService, PurchaseState>((ref) {
  return PurchaseService();
});

/// 課金状態
class PurchaseState {
  final bool isPremium;
  final bool isLoading;
  final String? error;

  const PurchaseState({
    this.isPremium = false,
    this.isLoading = false,
    this.error,
  });

  PurchaseState copyWith({
    bool? isPremium,
    bool? isLoading,
    String? error,
  }) {
    return PurchaseState(
      isPremium: isPremium ?? this.isPremium,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

/// 課金サービス
class PurchaseService extends StateNotifier<PurchaseState> {
  // RevenueCat APIキー（環境変数から取得）
  static String get _revenueCatApiKey {
    if (Platform.isIOS) {
      return dotenv.env['REVENUECAT_API_KEY_IOS'] ?? '';
    } else if (Platform.isAndroid) {
      return dotenv.env['REVENUECAT_API_KEY_ANDROID'] ?? '';
    }
    throw UnsupportedError('Unsupported platform');
  }

  static const String _entitlementId = 'premium';
  static const String _productId = 'vibe_quest_premium_500';

  PurchaseService() : super(const PurchaseState());

  /// RevenueCatの初期化
  Future<void> initialize() async {
    state = state.copyWith(isLoading: true);

    try {
      await Purchases.setLogLevel(LogLevel.debug);

      final configuration = PurchasesConfiguration(_revenueCatApiKey);
      await Purchases.configure(configuration);

      // 現在の課金状態を確認
      await checkPurchaseStatus();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// 課金状態の確認
  Future<void> checkPurchaseStatus() async {
    try {
      final customerInfo = await Purchases.getCustomerInfo();
      final isPremium = customerInfo.entitlements.active.containsKey(_entitlementId);

      state = state.copyWith(
        isPremium: isPremium,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// プレミアム版の購入
  Future<bool> purchasePremium() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // 利用可能な商品を取得
      final offerings = await Purchases.getOfferings();
      final offering = offerings.current;

      if (offering == null || offering.availablePackages.isEmpty) {
        throw Exception('商品が見つかりません');
      }

      // 商品を購入
      final package = offering.availablePackages.first;
      final purchaserInfo = await Purchases.purchasePackage(package);

      // 購入成功
      final isPremium = purchaserInfo.entitlements.active.containsKey(_entitlementId);

      state = state.copyWith(
        isPremium: isPremium,
        isLoading: false,
      );

      return isPremium;
    } on PlatformException catch (e) {
      // 購入がキャンセルされた場合
      if (e.code == PurchasesErrorCode.purchaseCancelledError.name) {
        state = state.copyWith(
          isLoading: false,
          error: '購入がキャンセルされました',
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          error: e.message,
        );
      }
      return false;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  /// 購入の復元
  Future<void> restorePurchases() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final customerInfo = await Purchases.restorePurchases();
      final isPremium = customerInfo.entitlements.active.containsKey(_entitlementId);

      state = state.copyWith(
        isPremium: isPremium,
        isLoading: false,
      );

      if (!isPremium) {
        state = state.copyWith(
          error: '復元する購入が見つかりませんでした',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }
}