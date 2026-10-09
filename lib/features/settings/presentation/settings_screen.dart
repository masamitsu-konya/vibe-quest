import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../monetization/services/purchase_service.dart';
import '../../monetization/services/ad_service.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final purchaseState = ref.watch(purchaseServiceProvider);
    final purchaseNotifier = ref.read(purchaseServiceProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('設定'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // プレミアム状態の表示
          Card(
            child: ListTile(
              leading: Icon(
                purchaseState.isPremium ? Icons.star : Icons.star_border,
                color: purchaseState.isPremium ? Colors.amber : null,
              ),
              title: Text(
                purchaseState.isPremium ? 'プレミアム会員' : '無料版',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                purchaseState.isPremium
                    ? '広告なし・エクスポート機能が利用可能'
                    : 'プレミアムにアップグレードしましょう',
              ),
            ),
          ),
          const SizedBox(height: 8),

          // マッチングサブスクリプション状態の表示
          Card(
            child: ListTile(
              leading: Icon(
                purchaseState.isMatchingSubscriber
                    ? Icons.favorite
                    : Icons.favorite_border,
                color:
                    purchaseState.isMatchingSubscriber ? Colors.pink : null,
              ),
              title: Text(
                purchaseState.isMatchingSubscriber
                    ? 'マッチングプラン加入中'
                    : 'マッチングプラン未加入',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                purchaseState.isMatchingSubscriber
                    ? '価値観マッチングとチャットが利用可能'
                    : 'マッチング画面から加入できます',
              ),
            ),
          ),
          const SizedBox(height: 16),

          // 購入ボタン
          if (!purchaseState.isPremium) ...[
            ElevatedButton.icon(
              onPressed: purchaseState.isLoading
                  ? null
                  : () async {
                      final success = await purchaseNotifier.purchasePremium();
                      if (context.mounted) {
                        if (success) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('プレミアムへのアップグレードが完了しました！'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        } else if (purchaseState.error != null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('エラー: ${purchaseState.error}'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    },
              icon: purchaseState.isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.upgrade),
              label: const Text('プレミアムにアップグレード (¥200)'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
              ),
            ),
            const SizedBox(height: 8),

            // プレミアム特典の説明
            Card(
              color: Colors.amber.shade50,
              child: const Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'プレミアム特典',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.green, size: 20),
                        SizedBox(width: 8),
                        Text('広告を完全に削除'),
                      ],
                    ),
                    SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.green, size: 20),
                        SizedBox(width: 8),
                        Text('分析結果をCSV/Markdownでエクスポート'),
                      ],
                    ),
                    SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.green, size: 20),
                        SizedBox(width: 8),
                        Text('Apple Reminders連携'),
                      ],
                    ),
                    SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.green, size: 20),
                        SizedBox(width: 8),
                        Text('他のタスク管理アプリと連携'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],

          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 16),

          // 購入の復元
          OutlinedButton.icon(
            onPressed: purchaseState.isLoading
                ? null
                : () async {
                    await purchaseNotifier.restorePurchases();
                    if (context.mounted) {
                      if (purchaseState.isPremium) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('購入が復元されました'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      } else if (purchaseState.error != null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('${purchaseState.error}'),
                            backgroundColor: Colors.orange,
                          ),
                        );
                      }
                    }
                  },
            icon: const Icon(Icons.restore),
            label: const Text('購入を復元'),
          ),

          const SizedBox(height: 32),

          // デバッグ情報
          if (purchaseState.error != null) ...[
            Card(
              color: Colors.red.shade50,
              child: ListTile(
                leading: const Icon(Icons.error_outline, color: Colors.red),
                title: const Text('エラー'),
                subtitle: Text(purchaseState.error!),
              ),
            ),
          ],

          // テスト用：広告表示ボタン
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 16),
          const Text(
            'テスト機能',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: () async {
              await AdService.instance.showInterstitialAd();
            },
            icon: const Icon(Icons.ad_units),
            label: const Text('テスト広告を表示'),
          ),
        ],
      ),
    );
  }
}