import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:appinio_swiper/appinio_swiper.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/models/question.dart';
import '../../../shared/widgets/swipeable_card.dart';
import '../domain/question_provider.dart';

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

  Future<void> _loadQuestions() async {
    try {
      final response = await ref
          .read(supabaseClientProvider)
          .from('questions')
          .select()
          .limit(50);

      setState(() {
        questions = (response as List)
            .map((json) => Question.fromJson(json))
            .toList();
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('質問の読み込みに失敗しました: $e'),
            duration: const Duration(seconds: 3),
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
        height: MediaQuery.of(context).size.height * 0.8,
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
              Column(
                children: [
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
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              Expanded(
                child: _buildAnalysisResults(),
              ),
              // 回答数に応じてボタンを表示
              if (responses.length < questions.length)
                Column(
                  children: [
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
    final excitedCount = responses.where((r) => r['is_excited'] == true).length;
    final notExcitedCount = responses.length - excitedCount;

    final excitedQuestions = responses
        .where((r) => r['is_excited'] == true)
        .map((r) => r['question'] as Question)
        .toList();

    final categoryCount = <String, int>{};
    double totalGrowthScore = 0;

    for (final question in excitedQuestions) {
      categoryCount[question.category] = (categoryCount[question.category] ?? 0) + 1;
      totalGrowthScore += question.growthScore;
    }

    final avgGrowthScore = excitedQuestions.isEmpty ? 0.0 : totalGrowthScore / excitedQuestions.length;

    return ListView(
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '基本統計',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text('ワクワクした: $excitedCount個'),
                Text('ワクワクしなかった: $notExcitedCount個'),
                Text('成長スコア平均: ${avgGrowthScore.toStringAsFixed(2)}'),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'カテゴリー別傾向',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: AppSpacing.sm),
                ...categoryCount.entries.map((entry) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(_getCategoryLabel(entry.key)),
                      Text('${entry.value}個'),
                    ],
                  ),
                )),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'あなたの傾向',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(_getPersonalityAnalysis(avgGrowthScore, categoryCount)),
              ],
            ),
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

  String _getPersonalityAnalysis(double avgGrowthScore, Map<String, int> categoryCount) {
    String analysis = '';

    if (avgGrowthScore >= 0.7) {
      analysis += '成長志向が非常に強く、常に自分を高めたいと考えています。';
    } else if (avgGrowthScore >= 0.5) {
      analysis += 'バランスの取れた成長意識を持っています。';
    } else {
      analysis += '楽しみを重視する傾向があります。';
    }

    if (categoryCount.isNotEmpty) {
      final topCategory = categoryCount.entries.reduce((a, b) => a.value > b.value ? a : b);
      analysis += '\n\n特に「${_getCategoryLabel(topCategory.key)}」への関心が高いようです。';
    }

    return analysis;
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