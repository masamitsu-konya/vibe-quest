import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../swipe/domain/responses_provider.dart';
import '../constants/value_labels.dart';
import '../models/values_profile.dart';

/// 価値観プロファイル画面
///
/// スワイプ回答から炙り出された価値観を可視化する。
class ValuesProfileScreen extends ConsumerWidget {
  const ValuesProfileScreen({super.key});

  /// プロファイルを表示する最低回答数
  static const int minAnswers = 10;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(valuesProfileProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('価値観プロファイル'),
        centerTitle: true,
      ),
      body: profile.answeredCount < minAnswers
          ? _EmptyState(answeredCount: profile.answeredCount)
          : _ProfileBody(profile: profile),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final int answeredCount;

  const _EmptyState({required this.answeredCount});

  @override
  Widget build(BuildContext context) {
    final remaining = ValuesProfileScreen.minAnswers - answeredCount;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('🧭', style: TextStyle(fontSize: 64)),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'まだ価値観を炙り出せていません',
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'あと$remaining回スワイプすると、あなたの価値観が見えてきます。'
              '深く考えず、直感で答えるのがコツです。',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileBody extends StatelessWidget {
  final ValuesProfile profile;

  const _ProfileBody({required this.profile});

  @override
  Widget build(BuildContext context) {
    final topValues = _topValues(profile, 5);
    final affinities = _sortedAffinities(profile);

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        _SummaryCard(profile: profile),
        const SizedBox(height: AppSpacing.lg),
        Text(
          'あなたの価値観トップ5',
          style: Theme.of(context)
              .textTheme
              .titleLarge
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'ワクワクした質問に共通して流れているもの',
          style: Theme.of(context)
              .textTheme
              .bodySmall
              ?.copyWith(color: Colors.grey[600]),
        ),
        const SizedBox(height: AppSpacing.md),
        ...topValues.asMap().entries.map(
              (entry) => _ValueTile(
                rank: entry.key + 1,
                label: valueDimensionLabels[entry.value.key]!,
                score: entry.value.value,
              ),
            ),
        const SizedBox(height: AppSpacing.xl),
        Text(
          '関心のある領域',
          style: Theme.of(context)
              .textTheme
              .titleLarge
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'カテゴリごとのワクワク率',
          style: Theme.of(context)
              .textTheme
              .bodySmall
              ?.copyWith(color: Colors.grey[600]),
        ),
        const SizedBox(height: AppSpacing.md),
        ...affinities.map(
          (entry) => _AffinityBar(
            label: categoryLabels[entry.key]!,
            affinity: entry.value,
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Text(
          '※ 回答が増えるほどプロファイルの精度が上がります',
          style: Theme.of(context)
              .textTheme
              .bodySmall
              ?.copyWith(color: Colors.grey[500]),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.xl),
      ],
    );
  }

  /// スコア次元を値の降順で上位N件返す
  List<MapEntry<String, double>> _topValues(ValuesProfile profile, int count) {
    final entries = ValuesProfile.scoreDimensions
        .map((dim) => MapEntry(dim, profile.scoreOf(dim)))
        .toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return entries.take(count).toList();
  }

  /// カテゴリ親和度を降順で返す（未回答カテゴリ=中立値は末尾）
  List<MapEntry<String, double>> _sortedAffinities(ValuesProfile profile) {
    final entries = ValuesProfile.categories
        .map((c) => MapEntry(c, profile.affinityOf(c)))
        .toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return entries;
  }
}

class _SummaryCard extends StatelessWidget {
  final ValuesProfile profile;

  const _SummaryCard({required this.profile});

  @override
  Widget build(BuildContext context) {
    final excitedRate = profile.answeredCount == 0
        ? 0
        : (profile.excitedCount / profile.answeredCount * 100).round();

    return Card(
      color: Theme.of(context).colorScheme.primaryContainer,
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _SummaryItem(
              value: '${profile.answeredCount}',
              caption: '回答数',
            ),
            _SummaryItem(
              value: '$excitedRate%',
              caption: 'ワクワク率',
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  final String value;
  final String caption;

  const _SummaryItem({required this.value, required this.caption});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          caption,
          style: Theme.of(context)
              .textTheme
              .bodySmall
              ?.copyWith(color: Colors.grey[600]),
        ),
      ],
    );
  }
}

class _ValueTile extends StatelessWidget {
  final int rank;
  final ValueLabel label;
  final double score;

  const _ValueTile({
    required this.rank,
    required this.label,
    required this.score,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            Text(
              '$rank',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(width: AppSpacing.md),
            Text(label.emoji, style: const TextStyle(fontSize: 28)),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label.name,
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    label.description,
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AffinityBar extends StatelessWidget {
  final ValueLabel label;
  final double affinity;

  const _AffinityBar({required this.label, required this.affinity});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        children: [
          SizedBox(
            width: 32,
            child: Text(label.emoji, style: const TextStyle(fontSize: 20)),
          ),
          SizedBox(
            width: 120,
            child: Text(
              label.name,
              style: Theme.of(context).textTheme.bodyMedium,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: affinity,
                minHeight: 8,
                backgroundColor: Colors.grey[200],
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          SizedBox(
            width: 40,
            child: Text(
              '${(affinity * 100).round()}%',
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}
