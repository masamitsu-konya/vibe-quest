import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../monetization/services/purchase_service.dart';

/// マッチング機能のペイウォール
///
/// 価値観プロファイル（無料で完成）を「出会い」につなげる部分だけを
/// 月額サブスクリプションで解放する。
class MatchingPaywall extends ConsumerStatefulWidget {
  const MatchingPaywall({super.key});

  @override
  ConsumerState<MatchingPaywall> createState() => _MatchingPaywallState();
}

class _MatchingPaywallState extends ConsumerState<MatchingPaywall> {
  String? priceString;

  @override
  void initState() {
    super.initState();
    _loadPrice();
  }

  Future<void> _loadPrice() async {
    final price = await ref
        .read(purchaseServiceProvider.notifier)
        .matchingPriceString();
    if (mounted) {
      setState(() {
        priceString = price;
      });
    }
  }

  Future<void> _purchase() async {
    final notifier = ref.read(purchaseServiceProvider.notifier);
    final success = await notifier.purchaseMatchingSubscription();

    if (!mounted) {
      return;
    }
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('マッチングが解放されました！'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      final error = ref.read(purchaseServiceProvider).error;
      if (error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final purchaseState = ref.watch(purchaseServiceProvider);

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.xl),
      children: [
        const SizedBox(height: AppSpacing.lg),
        const Center(child: Text('💫', style: TextStyle(fontSize: 64))),
        const SizedBox(height: AppSpacing.lg),
        Text(
          '価値観でつながる',
          style: Theme.of(context)
              .textTheme
              .headlineMedium
              ?.copyWith(fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          'スワイプで炙り出されたあなたの価値観プロファイルをもとに、'
          '価値観の近い人と出会えます。',
          style: Theme.of(context).textTheme.bodyLarge,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.xl),
        const _BenefitRow(emoji: '🧭', text: '価値観の一致度順に候補を表示'),
        const _BenefitRow(emoji: '🤝', text: 'お互いが Like したらマッチ成立'),
        const _BenefitRow(emoji: '💬', text: 'マッチした相手とチャット'),
        const _BenefitRow(emoji: '🔒', text: 'プロフィールはマッチング参加者にのみ公開'),
        const SizedBox(height: AppSpacing.xl),
        ElevatedButton(
          onPressed: purchaseState.isLoading ? null : _purchase,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
          ),
          child: purchaseState.isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(
                  priceString == null
                      ? 'マッチングをはじめる'
                      : 'マッチングをはじめる（$priceString/月）',
                  style: const TextStyle(fontSize: 16),
                ),
        ),
        const SizedBox(height: AppSpacing.md),
        TextButton(
          onPressed: purchaseState.isLoading
              ? null
              : () =>
                  ref.read(purchaseServiceProvider.notifier).restorePurchases(),
          child: const Text('購入を復元する'),
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          'サブスクリプションはいつでも解約できます。'
          '解約後もスワイプと価値観プロファイルは無料で使い続けられます。',
          style: Theme.of(context)
              .textTheme
              .bodySmall
              ?.copyWith(color: Colors.grey[600]),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _BenefitRow extends StatelessWidget {
  final String emoji;
  final String text;

  const _BenefitRow({required this.emoji, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(text, style: Theme.of(context).textTheme.bodyLarge),
          ),
        ],
      ),
    );
  }
}
