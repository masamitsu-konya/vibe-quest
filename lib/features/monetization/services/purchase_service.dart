import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

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
  static const String _entitlementId = 'premium';

  PurchaseService() : super(const PurchaseState());

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

      // Lifetimeパッケージを探す（一回買い切り）
      final package = offering.availablePackages.firstWhere(
        (pkg) => pkg.identifier == '\$rc_lifetime' || pkg.identifier == 'lifetime',
        orElse: () => offering.availablePackages.first,
      );

      // 購入を実行
      final purchaseResult = await Purchases.purchasePackage(package);

      // 購入成功 - PurchaseResultからCustomerInfoを取得
      final customerInfo = purchaseResult.customerInfo;
      final isPremium = customerInfo.entitlements.active.containsKey(_entitlementId);

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