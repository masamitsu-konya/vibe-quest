import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../monetization/services/purchase_service.dart';
import '../../swipe/domain/responses_provider.dart';
import '../../sync/services/sync_service.dart';
import '../models/match_candidate.dart';
import '../services/matching_service.dart';
import 'matches_screen.dart';
import 'paywall_screen.dart';
import 'profile_setup_view.dart';

/// マッチングのホーム画面
///
/// ゲート順序: 回答数 → サブスクリプション → プロフィール登録 → 候補一覧
/// （課金を求める前に、無料でできる体験を先に完成させる）
class MatchingHomeScreen extends ConsumerStatefulWidget {
  const MatchingHomeScreen({super.key});

  /// マッチング参加に必要な最低回答数
  static const int minAnswersForMatching = 50;

  @override
  ConsumerState<MatchingHomeScreen> createState() =>
      _MatchingHomeScreenState();
}

class _MatchingHomeScreenState extends ConsumerState<MatchingHomeScreen> {
  Map<String, dynamic>? myProfile;
  bool profileLoading = true;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    // 最新プロファイルをサーバーへ反映してから参加状態を取得
    await ref.read(syncServiceProvider).maybeSync(
          ref.read(responsesProvider),
          ref.read(valuesProfileProvider),
          force: true,
        );
    await _loadMyProfile();
  }

  Future<void> _loadMyProfile() async {
    try {
      final profile = await ref.read(matchingServiceProvider).fetchMyProfile();
      if (mounted) {
        setState(() {
          myProfile = profile;
          profileLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          profileLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final purchaseState = ref.watch(purchaseServiceProvider);
    final valuesProfile = ref.watch(valuesProfileProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('価値観マッチング'),
        centerTitle: true,
        actions: [
          if (purchaseState.isMatchingSubscriber)
            IconButton(
              icon: const Icon(Icons.chat_bubble_outline),
              tooltip: 'マッチ一覧',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MatchesScreen(),
                  ),
                );
              },
            ),
        ],
      ),
      body: _buildBody(purchaseState, valuesProfile.answeredCount),
    );
  }

  Widget _buildBody(PurchaseState purchaseState, int answeredCount) {
    // ゲート1: 回答数（プロファイルの精度を担保）
    if (answeredCount < MatchingHomeScreen.minAnswersForMatching) {
      return _NeedMoreAnswers(answeredCount: answeredCount);
    }

    // ゲート2: 月額サブスクリプション
    if (!purchaseState.isMatchingSubscriber) {
      return const MatchingPaywall();
    }

    // ゲート3: マッチング用プロフィール登録
    if (profileLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    final registered = myProfile != null &&
        myProfile!['nickname'] != null &&
        (myProfile!['is_matching_enabled'] as bool? ?? false);
    if (!registered) {
      return ProfileSetupView(
        onCompleted: () {
          setState(() {
            profileLoading = true;
          });
          _loadMyProfile();
        },
      );
    }

    // 本体: 候補一覧
    return const _CandidatesView();
  }
}

class _NeedMoreAnswers extends StatelessWidget {
  final int answeredCount;

  const _NeedMoreAnswers({required this.answeredCount});

  @override
  Widget build(BuildContext context) {
    final remaining =
        MatchingHomeScreen.minAnswersForMatching - answeredCount;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('🧩', style: TextStyle(fontSize: 64)),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'まずは価値観プロファイルを育てよう',
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'マッチングにはあと$remaining回のスワイプが必要です。\n'
              'プロファイルが正確なほど、価値観の合う人に出会えます。',
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.lg),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('スワイプに戻る'),
            ),
          ],
        ),
      ),
    );
  }
}

class _CandidatesView extends ConsumerStatefulWidget {
  const _CandidatesView();

  @override
  ConsumerState<_CandidatesView> createState() => _CandidatesViewState();
}

class _CandidatesViewState extends ConsumerState<_CandidatesView> {
  List<MatchCandidate> candidates = [];
  bool loading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _loadCandidates();
  }

  Future<void> _loadCandidates() async {
    setState(() {
      loading = true;
      error = null;
    });

    try {
      final result =
          await ref.read(matchingServiceProvider).fetchCandidates();
      if (mounted) {
        setState(() {
          candidates = result;
          loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          error = e.toString();
          loading = false;
        });
      }
    }
  }

  Future<void> _decide(MatchCandidate candidate, {required bool isLike}) async {
    // 楽観的にリストから除去（イミュータブルに再構築）
    setState(() {
      candidates =
          candidates.where((c) => c.userId != candidate.userId).toList();
    });

    try {
      final matchId = await ref
          .read(matchingServiceProvider)
          .decide(candidate.userId, isLike: isLike);

      if (matchId != null && mounted) {
        _showMatchDialog(candidate);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('送信に失敗しました: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showMatchDialog(MatchCandidate candidate) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('🎉 マッチ成立！'),
        content: Text(
          '${candidate.nickname}さんと価値観マッチしました。'
          'チャットで話してみましょう。',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('あとで'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const MatchesScreen(),
                ),
              );
            },
            child: const Text('マッチ一覧へ'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('候補の取得に失敗しました',
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: AppSpacing.md),
              ElevatedButton(
                onPressed: _loadCandidates,
                child: const Text('再読み込み'),
              ),
            ],
          ),
        ),
      );
    }

    if (candidates.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('🌱', style: TextStyle(fontSize: 64)),
              const SizedBox(height: AppSpacing.lg),
              Text(
                '今は表示できる候補がいません',
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                '新しい参加者が増えると候補が表示されます。\nまた後で覗いてみてください。',
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.lg),
              ElevatedButton(
                onPressed: _loadCandidates,
                child: const Text('更新する'),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadCandidates,
      child: ListView.builder(
        padding: const EdgeInsets.all(AppSpacing.md),
        itemCount: candidates.length,
        itemBuilder: (context, index) {
          final candidate = candidates[index];
          return _CandidateCard(
            candidate: candidate,
            onLike: () => _decide(candidate, isLike: true),
            onSkip: () => _decide(candidate, isLike: false),
          );
        },
      ),
    );
  }
}

class _CandidateCard extends StatelessWidget {
  final MatchCandidate candidate;
  final VoidCallback onLike;
  final VoidCallback onSkip;

  const _CandidateCard({
    required this.candidate,
    required this.onLike,
    required this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor:
                      Theme.of(context).colorScheme.primaryContainer,
                  child: Text(
                    candidate.nickname.characters.first,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    candidate.nickname,
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    '一致度 ${candidate.similarityPercent}%',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            if (candidate.bio != null && candidate.bio!.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.md),
              Text(
                candidate.bio!,
                style: Theme.of(context).textTheme.bodyMedium,
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            const SizedBox(height: AppSpacing.md),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton(
                  onPressed: onSkip,
                  child: const Text('スキップ'),
                ),
                const SizedBox(width: AppSpacing.md),
                ElevatedButton.icon(
                  onPressed: onLike,
                  icon: const Icon(Icons.favorite, size: 18),
                  label: const Text('Like'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
