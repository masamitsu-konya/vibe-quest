import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:appinio_swiper/appinio_swiper.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/models/question.dart';
import '../../../shared/widgets/swipeable_card.dart';
import '../domain/question_provider.dart';
import '../../analysis/personality_analyzer.dart';

class SwipeScreen extends ConsumerStatefulWidget {
  const SwipeScreen({super.key});

  @override
  ConsumerState<SwipeScreen> createState() => _SwipeScreenState();
}

class _SwipeScreenState extends ConsumerState<SwipeScreen> {
  final AppinioSwiperController controller = AppinioSwiperController();
  List<Question> questions = [];
  List<Map<String, dynamic>> responses = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  Future<void> _loadQuestions({bool append = false}) async {
    try {
      // まず全質問を取得してクライアント側でランダムに選択
      final response = await ref
          .read(supabaseClientProvider)
          .from('questions')
          .select();

      // クライアント側でシャッフルして50問選択
      final random = Random();
      final allQuestions = (response as List)
          .map((json) => Question.fromJson(json))
          .toList();
      allQuestions.shuffle(random);

      // 50問だけ取得
      final questionsList = allQuestions.take(50).toList();

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
    } catch (e, stackTrace) {
      print('Error loading questions: $e');
      print('Stack trace: $stackTrace');

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
                      if (responses.length < 30)
                        Text(
                          '※回答が増えるほど分析精度が向上します',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
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
                    const SizedBox(height: AppSpacing.sm),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        setState(() {
                          responses.clear();
                        });
                        _loadQuestions();
                      },
                      child: const Text('最初からやり直す'),
                    ),
                  ],
                )
              else
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    setState(() {
                      responses.clear();
                    });
                    _loadQuestions();
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 48),
                  ),
                  child: const Text('もう一度チャレンジ'),
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
        // パーソナリティタイプカード
        Card(
          color: Theme.of(context).colorScheme.primaryContainer,
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

  String _getCategoryLabel(String category) {
    switch (category) {
      case 'health': return '健康・フィットネス';
      case 'career': return 'キャリア・仕事';
      case 'hobby': return '趣味・娯楽';
      case 'learning': return '学習・自己啓発';
      case 'relationship': return '人間関係';
      case 'lifestyle': return 'ライフスタイル';
      case 'finance': return '金融・投資';
      case 'creativity': return 'クリエイティブ';
      case 'sports': return 'スポーツ';
      case 'travel': return '旅行・冒険';
      default: return category;
    }
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
                child: Row(
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
                              cardBuilder: (BuildContext context, int index) {
                                return SwipeableCard(
                                  question: questions[index],
                                );
                              },
                              onSwipeEnd: (int previousIndex, int targetIndex, SwiperActivity activity) {
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

                                  // 残り10問になったら次の50問を自動取得
                                  final remainingQuestions = questions.length - responses.length;
                                  if (remainingQuestions == 10 && !isLoading) {
                                    _loadQuestions(append: true);
                                  }

                                  // 10個スワイプするごと、または全てのカードをスワイプしたら結果を表示
                                  if (responses.length % 10 == 0 || targetIndex >= questions.length) {
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
              Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(AppSpacing.md),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close,
                            color: Colors.red,
                            size: 30,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        const Text('ワクワクしない'),
                      ],
                    ),
                    Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(AppSpacing.md),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.favorite,
                            color: Colors.green,
                            size: 30,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        const Text('ワクワクする'),
                      ],
                    ),
                  ],
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