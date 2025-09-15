import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:appinio_swiper/appinio_swiper.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/models/question.dart';
import '../../../shared/widgets/swipeable_card.dart';
import '../../../data/questions_data.dart';
import '../../analysis/personality_analyzer.dart';
import '../../actions/presentation/action_recommendations_view.dart';
import '../../monetization/services/ad_service.dart';
import '../../monetization/services/purchase_service.dart';

class SwipeScreen extends ConsumerStatefulWidget {
  const SwipeScreen({super.key});

  @override
  ConsumerState<SwipeScreen> createState() => _SwipeScreenState();
}

class _SwipeScreenState extends ConsumerState<SwipeScreen> with SingleTickerProviderStateMixin {
  final AppinioSwiperController controller = AppinioSwiperController();
  List<Question> questions = [];
  List<Map<String, dynamic>> responses = [];
  bool isLoading = true;

  // スワイプ進捗を管理する変数
  double swipeProgress = 0.0;
  bool isSwipingRight = false;

  // 分析トリガー関連
  static const int analysisThreshold = 50; // 50個ごとに分析

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  Future<void> _loadQuestions({bool append = false}) async {
    try {
      // アプリ内データからランダムに50問取得
      final questionsList = QuestionsData.getRandomQuestions(50);

      setState(() {
        if (append) {
          // 既存の質問に追加
          questions.addAll(questionsList);
        } else {
          // 新規に設定
          questions = questionsList;
        }
        isLoading = false;
      });
    } catch (e) {
      // エラーログは本番環境では表示しない

      setState(() {
        isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('質問の読み込みに失敗しました: $e'),
            duration: const Duration(seconds: 5),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }


  void _showResults() {
    // プレミアムユーザーでない場合は広告を表示
    final isPremium = ref.read(purchaseServiceProvider).isPremium;
    if (!isPremium) {
      AdService.instance.onBeforeShowingAnalysis();
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.95,
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: AppSpacing.lg),
                decoration: BoxDecoration(
                  color: Colors.grey[400],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // ヘッダー情報をスクロール可能エリアに含める
                      Text(
                        '分析結果',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        '回答数: ${responses.length}個',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                      if (responses.length < analysisThreshold)
                        Text(
                          '※最低$analysisThreshold個の回答で分析が開始されます',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      if (responses.length >= analysisThreshold && responses.length < 100)
                        Text(
                          '※回答が増えるほど分析精度が向上します',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                        ),
                      const SizedBox(height: AppSpacing.lg),
                      // 分析結果コンテンツ
                      _buildAnalysisResults(),
                    ],
                  ),
                ),
              ),
              // 回答数に応じてボタンを表示
              if (responses.length < questions.length)
                Column(
                  children: [
                    const SizedBox(height: AppSpacing.md),  // ボタン上部に16pxのマージン追加
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        // responsesはクリアせず、続きから再開
                      },
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 48),
                      ),
                      child: const Text('さらに続ける'),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnalysisResults() {
    // PersonalityAnalyzerを使用して深い分析を実行
    final analysisResult = PersonalityAnalyzer.analyze(responses);
    final personalityType = PersonalityAnalyzer.personalityTypes[analysisResult.personalityType];

    return Column(
      children: [
        // 50個以上回答した場合は行動提案を表示
        if (responses.length >= analysisThreshold) ...[
          ActionRecommendationsView(
            analysisResult: analysisResult,
            responses: responses,
          ),
          const SizedBox(height: AppSpacing.lg),
          const Divider(),
          const SizedBox(height: AppSpacing.lg),
        ],
        // パーソナリティタイプカード
        Card(
          color: Theme.of(context).colorScheme.primaryContainer,
          elevation: 0,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.psychology,
                      color: Theme.of(context).colorScheme.primary,
                      size: 28,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      'あなたのタイプ',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  personalityType?.name ?? '分析中...',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  personalityType?.description ?? '',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                if (personalityType != null) ...[
                  const SizedBox(height: AppSpacing.md),
                  Wrap(
                    spacing: AppSpacing.xs,
                    runSpacing: AppSpacing.xs,
                    children: personalityType.traits.map((trait) => Chip(
                      label: Text(trait),
                      backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
                    )).toList(),
                  ),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        // 価値観カード
        Card(
          elevation: 0,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.star,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      'あなたの価値観',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                ...analysisResult.primaryValues.map((value) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
                  child: Row(
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: Theme.of(context).colorScheme.secondary,
                        size: 20,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          value,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ),
                    ],
                  ),
                )),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        // 洞察カード
        Card(
          elevation: 0,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.lightbulb,
                      color: Theme.of(context).colorScheme.tertiary,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      '洞察',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                ...analysisResult.insights.map((insight) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.md),
                  child: Text(
                    insight,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                )),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        // 推奨アクションカード
        Card(
          elevation: 0,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.rocket_launch,
                      color: Theme.of(context).colorScheme.error,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      '次のステップ',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                ...analysisResult.recommendations.asMap().entries.map((entry) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.errorContainer,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '${entry.key + 1}',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onErrorContainer,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          entry.value,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ),
                    ],
                  ),
                )),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        // スコア詳細カード（折りたたみ可能）
        Card(
          elevation: 0,
          child: ExpansionTile(
            title: Text(
              '詳細スコア',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            children: [
              Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '基本統計',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text('回答数: ${analysisResult.responseCount}'),
                    Text('ワクワク: ${analysisResult.excitedCount} (${(analysisResult.excitedCount * 100 / analysisResult.responseCount).toStringAsFixed(0)}%)'),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      '自己決定理論スコア',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    _buildScoreBar('自律性', analysisResult.sdtScores['autonomy']!),
                    _buildScoreBar('有能感', analysisResult.sdtScores['competence']!),
                    _buildScoreBar('関係性', analysisResult.sdtScores['relatedness']!),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      'ikigaiスコア',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    _buildScoreBar('好きなこと', analysisResult.ikigaiScores['love']!),
                    _buildScoreBar('得意なこと', analysisResult.ikigaiScores['goodAt']!),
                    _buildScoreBar('世界が求める', analysisResult.ikigaiScores['worldNeeds']!),
                    _buildScoreBar('報酬になる', analysisResult.ikigaiScores['paidFor']!),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }


  // スコアバーを表示するウィジェット
  Widget _buildScoreBar(String label, double score) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label),
              Text('${(score * 100).toStringAsFixed(0)}%'),
            ],
          ),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: score,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(
              score > 0.7
                  ? Colors.green
                  : score > 0.4
                      ? Colors.orange
                      : Colors.red,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    final answeredCount = responses.length;
    final nextAnalysis = ((answeredCount ~/ analysisThreshold) + 1) * analysisThreshold;
    final progress = (answeredCount % analysisThreshold) / analysisThreshold;
    final remaining = nextAnalysis - answeredCount;

    return Container(
      margin: const EdgeInsets.only(top: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '回答数: $answeredCount',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              if (answeredCount < analysisThreshold)
                Text(
                  '初回分析まであと$remaining個',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                )
              else
                Text(
                  '次の分析まであと$remaining個',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
            valueColor: AlwaysStoppedAnimation<Color>(
              answeredCount < analysisThreshold
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.secondary,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).colorScheme.primary.withOpacity(0.1),
              Theme.of(context).colorScheme.secondary.withOpacity(0.1),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Vibe Quest',
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.info_outline),
                          onPressed: () => _showInstructions(),
                        ),
                      ],
                    ),
                    // プログレスバー
                    if (!isLoading && questions.isNotEmpty)
                      _buildProgressBar(),
                  ],
                ),
              ),
              Expanded(
                child: isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : questions.isEmpty
                        ? const Center(child: Text('質問がありません'))
                        : Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.md,
                              vertical: 0,
                            ),
                            child: AppinioSwiper(
                              controller: controller,
                              cardCount: questions.length,
                              threshold: 100,  // デフォルト50から100に増やして、より大きくスワイプが必要に
                              cardBuilder: (BuildContext context, int index) {
                                return SwipeableCard(
                                  question: questions[index],
                                );
                              },
                              onCardPositionChanged: (SwiperPosition position) {
                                // カードの位置に基づいてスワイプ進捗を計算
                                setState(() {
                                  // 水平方向のオフセットを基にスワイプの進捗を計算
                                  double horizontalOffset = position.offset.dx;

                                  // スワイプの方向を判定
                                  isSwipingRight = horizontalOffset > 0;

                                  // 進捗を0.0から1.0の範囲に正規化
                                  // 150ピクセルのスワイプで最大スケールに達するように設定
                                  swipeProgress = (horizontalOffset.abs() / 150).clamp(0.0, 1.0);
                                });
                              },
                              onSwipeEnd: (int previousIndex, int targetIndex, SwiperActivity activity) {
                                // スワイプ終了時に進捗をリセット
                                setState(() {
                                  swipeProgress = 0.0;
                                });
                                if (previousIndex < questions.length) {
                                  final question = questions[previousIndex];
                                  // Swipeアクティビティの場合、directionを確認
                                  bool isExcited = false;
                                  if (activity is Swipe) {
                                    isExcited = activity.direction == AxisDirection.right;
                                  }

                                  responses.add({
                                    'question': question,
                                    'is_excited': isExcited,
                                    'timestamp': DateTime.now(),
                                  });

                                  // プレミアムユーザーでない場合は20問ごとに広告表示
                                  final isPremium = ref.read(purchaseServiceProvider).isPremium;
                                  if (!isPremium) {
                                    AdService.instance.onQuestionAnswered();
                                  }

                                  // 残り10問になったら次の50問を自動取得
                                  final remainingQuestions = questions.length - responses.length;
                                  if (remainingQuestions == 10 && !isLoading) {
                                    _loadQuestions(append: true);
                                  }

                                  // 50個スワイプするごと、または全てのカードをスワイプしたら結果を表示
                                  if (responses.length >= analysisThreshold && responses.length % analysisThreshold == 0) {
                                    Future.delayed(const Duration(milliseconds: 300), () {
                                      _showResults();
                                    });
                                  }
                                }
                              },
                              backgroundCardCount: 2,
                              backgroundCardOffset: const Offset(0, 32),
                              backgroundCardScale: 0.95,
                            ),
                          ),
              ),
              SizedBox(
                height: 120, // 固定の高さを設定
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // 左スワイプ（ワクワクしない）ボタン
                      SizedBox(
                        width: 100, // 固定幅
                        height: 100, // 固定高さ
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            AnimatedScale(
                              scale: !isSwipingRight && swipeProgress > 0
                                  ? 1.0 + (swipeProgress * 0.3)  // 左スワイプ時は最大1.3倍
                                  : 1.0,
                              duration: const Duration(milliseconds: 100),
                              child: AnimatedOpacity(
                                opacity: !isSwipingRight && swipeProgress > 0
                                    ? 0.7 + (swipeProgress * 0.3)  // 透明度も変化
                                    : 0.7,
                                duration: const Duration(milliseconds: 100),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(AppSpacing.md),
                                      decoration: BoxDecoration(
                                        color: Colors.red.withOpacity(
                                          0.1 + (!isSwipingRight && swipeProgress > 0 ? swipeProgress * 0.2 : 0)
                                        ),
                                        shape: BoxShape.circle,
                                        boxShadow: !isSwipingRight && swipeProgress > 0
                                            ? [
                                                BoxShadow(
                                                  color: Colors.red.withOpacity(0.3 * swipeProgress),
                                                  blurRadius: 10 * swipeProgress,
                                                  spreadRadius: 2 * swipeProgress,
                                                )
                                              ]
                                            : [],
                                      ),
                                      child: Icon(
                                        Icons.close,
                                        color: Colors.red,
                                        size: 30,
                                      ),
                                    ),
                                    const SizedBox(height: AppSpacing.sm),
                                    Text(
                                      'ワクワクしない',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: !isSwipingRight && swipeProgress > 0.5
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // 右スワイプ（ワクワクする）ボタン
                      SizedBox(
                        width: 100, // 固定幅
                        height: 100, // 固定高さ
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            AnimatedScale(
                              scale: isSwipingRight && swipeProgress > 0
                                  ? 1.0 + (swipeProgress * 0.3)  // 右スワイプ時は最大1.3倍
                                  : 1.0,
                              duration: const Duration(milliseconds: 100),
                              child: AnimatedOpacity(
                                opacity: isSwipingRight && swipeProgress > 0
                                    ? 0.7 + (swipeProgress * 0.3)  // 透明度も変化
                                    : 0.7,
                                duration: const Duration(milliseconds: 100),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(AppSpacing.md),
                                      decoration: BoxDecoration(
                                        color: Colors.green.withOpacity(
                                          0.1 + (isSwipingRight && swipeProgress > 0 ? swipeProgress * 0.2 : 0)
                                        ),
                                        shape: BoxShape.circle,
                                        boxShadow: isSwipingRight && swipeProgress > 0
                                            ? [
                                                BoxShadow(
                                                  color: Colors.green.withOpacity(0.3 * swipeProgress),
                                                  blurRadius: 10 * swipeProgress,
                                                  spreadRadius: 2 * swipeProgress,
                                                )
                                              ]
                                            : [],
                                      ),
                                      child: Icon(
                                        Icons.favorite,
                                        color: Colors.green,
                                        size: 30,
                                      ),
                                    ),
                                    const SizedBox(height: AppSpacing.sm),
                                    Text(
                                      'ワクワクする',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: isSwipingRight && swipeProgress > 0.5
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showInstructions() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('使い方'),
        content: const Text(
          '表示される質問に対して：\n\n'
          '右スワイプ → ワクワクする\n'
          '左スワイプ → ワクワクしない\n\n'
          'あなたの選択から、本当にやりたいことや理想の自分像を分析します。',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('閉じる'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}