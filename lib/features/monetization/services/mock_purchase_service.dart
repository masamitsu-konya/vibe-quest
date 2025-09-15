import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 開発用のモック課金サービス（RevenueCatなし）
final mockPurchaseServiceProvider = StateNotifierProvider<MockPurchaseService, MockPurchaseState>((ref) {
  return MockPurchaseService();
});

/// モック課金状態
class MockPurchaseState {
  final bool isPremium;
  final bool isLoading;
  final String? error;

  const MockPurchaseState({
    this.isPremium = false, // 開発中は常に無料版として動作
    this.isLoading = false,
    this.error,
  });

  MockPurchaseState copyWith({
    bool? isPremium,
    bool? isLoading,
    String? error,
  }) {
    return MockPurchaseState(
      isPremium: isPremium ?? this.isPremium,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

/// モック課金サービス
class MockPurchaseService extends StateNotifier<MockPurchaseState> {
  MockPurchaseService() : super(const MockPurchaseState());

  /// 初期化（何もしない）
  Future<void> initialize() async {
    print('MockPurchaseService: 開発モードで動作中（課金機能は無効）');
  }

  /// 課金状態の確認（常に無料版）
  Future<void> checkPurchaseStatus() async {
    state = state.copyWith(isPremium: false);
  }

  /// プレミアム版の購入（開発中はシミュレーション）
  Future<bool> purchasePremium() async {
    state = state.copyWith(isLoading: true);

    // 2秒待機してから成功をシミュレート
    await Future.delayed(const Duration(seconds: 2));

    state = state.copyWith(
      isPremium: true,
      isLoading: false,
    );

    print('MockPurchaseService: プレミアム購入をシミュレート');
    return true;
  }

  /// 購入の復元（開発中は何もしない）
  Future<void> restorePurchases() async {
    state = state.copyWith(
      error: '開発モードでは購入の復元はできません',
    );
  }
}