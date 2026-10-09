import 'dart:math';
import '../../analysis/models/analysis_result.dart';
import '../models/action_recommendation.dart';

/// 行動提案生成サービス
class ActionGenerator {

  /// 分析結果から行動提案リストを生成
  static WantToDoList generateFromAnalysis(
    AnalysisResult analysis,
    List<Map<String, dynamic>> responses,
  ) {
    // ワクワクした質問を抽出
    final excitedQuestions = responses
        .where((r) => r['is_excited'] == true)
        .map((r) => r['question'])
        .toList();

    // カテゴリ別にグループ化
    final categoryGroups = <String, List<dynamic>>{};
    for (final question in excitedQuestions) {
      final category = question.category as String;
      categoryGroups.putIfAbsent(category, () => []).add(question);
    }

    // 各カテゴリの興味度を計算
    final categoryScores = <String, double>{};
    categoryGroups.forEach((category, questions) {
      categoryScores[category] = questions.length / excitedQuestions.length;
    });

    // 行動提案を生成
    final immediateActions = _generateImmediateActions(
      analysis,
      categoryScores,
      excitedQuestions,
    );

    final shortTermGoals = _generateShortTermGoals(
      analysis,
      categoryScores,
      excitedQuestions,
    );

    final mediumTermGoals = _generateMediumTermGoals(
      analysis,
      categoryScores,
      excitedQuestions,
    );

    final longTermGoals = _generateLongTermGoals(
      analysis,
      categoryScores,
      excitedQuestions,
    );

    final dailyHabits = _generateDailyHabits(
      analysis,
      categoryScores,
      excitedQuestions,
    );

    final weeklyHabits = _generateWeeklyHabits(
      analysis,
      categoryScores,
      excitedQuestions,
    );

    return WantToDoList(
      immediateActions: immediateActions,
      shortTermGoals: shortTermGoals,
      mediumTermGoals: mediumTermGoals,
      longTermGoals: longTermGoals,
      dailyHabits: dailyHabits,
      weeklyHabits: weeklyHabits,
      generatedAt: DateTime.now(),
    );
  }

  /// 今すぐできる行動を生成
  static List<ActionRecommendation> _generateImmediateActions(
    AnalysisResult analysis,
    Map<String, double> categoryScores,
    List<dynamic> excitedQuestions,
  ) {
    final actions = <ActionRecommendation>[];

    // 上位カテゴリから提案を生成
    final topCategories = categoryScores.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    for (var i = 0; i < min(3, topCategories.length); i++) {
      final category = topCategories[i].key;
      final score = topCategories[i].value;

      actions.addAll(_getImmediateActionsForCategory(
        category,
        score,
        analysis,
      ));
    }

    // 関連性スコアでソートして上位を返す
    actions.sort((a, b) => b.relevanceScore.compareTo(a.relevanceScore));
    return actions.take(5).toList();
  }

  /// カテゴリ別の即座の行動提案
  static List<ActionRecommendation> _getImmediateActionsForCategory(
    String category,
    double categoryScore,
    AnalysisResult analysis,
  ) {
    final baseScore = categoryScore * 0.8;
    final actions = <ActionRecommendation>[];

    switch (category) {
      case 'health':
        actions.addAll([
          ActionRecommendation(
            id: 'health_immediate_1',
            title: '10分間の散歩に出かける',
            description: '今すぐできる最も簡単な健康習慣。気分転換にも最適です。',
            category: ActionCategory.health,
            timeframe: ActionTimeframe.daily,
            difficulty: ActionDifficulty.easy,
            tags: ['健康', '運動', '気分転換'],
            relevanceScore: baseScore + 0.1,
            emoji: '🚶',
          ),
          ActionRecommendation(
            id: 'health_immediate_2',
            title: '瞑想アプリを試してみる',
            description: '5分間の瞑想で心を落ち着かせましょう。',
            category: ActionCategory.health,
            timeframe: ActionTimeframe.daily,
            difficulty: ActionDifficulty.easy,
            tags: ['瞑想', 'メンタルヘルス', 'リラックス'],
            relevanceScore: baseScore,
            emoji: '🧘',
          ),
        ]);
        break;

      case 'career':
        actions.addAll([
          ActionRecommendation(
            id: 'career_immediate_1',
            title: 'LinkedInプロフィールを更新する',
            description: '最新の経験やスキルを追加して、プロフィールを充実させましょう。',
            category: ActionCategory.career,
            timeframe: ActionTimeframe.daily,
            difficulty: ActionDifficulty.easy,
            tags: ['キャリア', 'ネットワーキング', 'プロフィール'],
            relevanceScore: baseScore + 0.05,
            emoji: '💼',
          ),
          ActionRecommendation(
            id: 'career_immediate_2',
            title: '興味のある技術記事を1つ読む',
            description: '最新の業界トレンドをキャッチアップしましょう。',
            category: ActionCategory.career,
            timeframe: ActionTimeframe.daily,
            difficulty: ActionDifficulty.easy,
            tags: ['学習', '技術', 'トレンド'],
            relevanceScore: baseScore,
            emoji: '📖',
          ),
        ]);
        break;

      case 'creativity':
        actions.addAll([
          ActionRecommendation(
            id: 'creativity_immediate_1',
            title: '5分間のスケッチを描く',
            description: '目の前にあるものを自由に描いてみましょう。',
            category: ActionCategory.creativity,
            timeframe: ActionTimeframe.daily,
            difficulty: ActionDifficulty.easy,
            tags: ['アート', 'スケッチ', '創造性'],
            relevanceScore: baseScore + 0.08,
            emoji: '✏️',
          ),
          ActionRecommendation(
            id: 'creativity_immediate_2',
            title: '写真を3枚撮る',
            description: '日常の中の美しい瞬間を切り取りましょう。',
            category: ActionCategory.creativity,
            timeframe: ActionTimeframe.daily,
            difficulty: ActionDifficulty.easy,
            tags: ['写真', 'アート', '観察'],
            relevanceScore: baseScore,
            emoji: '📸',
          ),
        ]);
        break;

      case 'learning':
        actions.addAll([
          ActionRecommendation(
            id: 'learning_immediate_1',
            title: 'YouTubeで新しいスキルの動画を見る',
            description: '興味のある分野の入門動画を1つ視聴しましょう。',
            category: ActionCategory.learning,
            timeframe: ActionTimeframe.daily,
            difficulty: ActionDifficulty.easy,
            tags: ['学習', '動画', 'スキル'],
            relevanceScore: baseScore + 0.07,
            emoji: '📺',
          ),
          ActionRecommendation(
            id: 'learning_immediate_2',
            title: 'Podcastを1エピソード聞く',
            description: '通勤時間を学習時間に変えましょう。',
            category: ActionCategory.learning,
            timeframe: ActionTimeframe.daily,
            difficulty: ActionDifficulty.easy,
            tags: ['学習', 'Podcast', '教養'],
            relevanceScore: baseScore,
            emoji: '🎧',
          ),
        ]);
        break;

      default:
        // その他のカテゴリ用の汎用的な提案
        actions.add(
          ActionRecommendation(
            id: '${category}_immediate_1',
            title: '$categoryに関する情報を検索する',
            description: '興味のある分野について、まずは情報収集から始めましょう。',
            category: ActionCategory.learning,
            timeframe: ActionTimeframe.daily,
            difficulty: ActionDifficulty.easy,
            tags: [category, '情報収集', '探索'],
            relevanceScore: baseScore,
            emoji: '🔍',
          ),
        );
    }

    return actions;
  }

  /// 短期目標（3ヶ月以内）を生成
  static List<ActionRecommendation> _generateShortTermGoals(
    AnalysisResult analysis,
    Map<String, double> categoryScores,
    List<dynamic> excitedQuestions,
  ) {
    final goals = <ActionRecommendation>[];

    // パーソナリティタイプに基づいた目標
    if (analysis.personalityType.contains('創造')) {
      goals.add(
        ActionRecommendation(
          id: 'short_creative_1',
          title: '個人プロジェクトを完成させる',
          description: 'アプリ、アート作品、文章など、何か一つ作品を完成させましょう。',
          category: ActionCategory.creativity,
          timeframe: ActionTimeframe.shortTerm,
          difficulty: ActionDifficulty.medium,
          tags: ['創造', 'プロジェクト', '達成'],
          relevanceScore: 0.85,
          emoji: '🎯',
        ),
      );
    }

    if (analysis.personalityType.contains('成長')) {
      goals.add(
        ActionRecommendation(
          id: 'short_growth_1',
          title: '新しいスキルの基礎を習得する',
          description: 'オンラインコースを1つ完了して、証明書を取得しましょう。',
          category: ActionCategory.learning,
          timeframe: ActionTimeframe.shortTerm,
          difficulty: ActionDifficulty.medium,
          tags: ['学習', 'スキル', '成長'],
          relevanceScore: 0.88,
          emoji: '📚',
        ),
      );
    }

    // カテゴリスコアに基づいた目標
    final topCategory = categoryScores.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;

    if (topCategory == 'health') {
      goals.add(
        ActionRecommendation(
          id: 'short_health_1',
          title: '5kmランを達成する',
          description: '3ヶ月かけて徐々に距離を伸ばし、5km走れるようになりましょう。',
          category: ActionCategory.health,
          timeframe: ActionTimeframe.shortTerm,
          difficulty: ActionDifficulty.medium,
          tags: ['健康', 'ランニング', '目標'],
          relevanceScore: 0.82,
          emoji: '🏃',
        ),
      );
    }

    return goals.take(3).toList();
  }

  /// 中期目標（1年以内）を生成
  static List<ActionRecommendation> _generateMediumTermGoals(
    AnalysisResult analysis,
    Map<String, double> categoryScores,
    List<dynamic> excitedQuestions,
  ) {
    final goals = <ActionRecommendation>[];

    // SDTスコアに基づいた目標
    if (analysis.sdtScores['autonomy']! > 0.7) {
      goals.add(
        ActionRecommendation(
          id: 'medium_autonomy_1',
          title: 'フリーランスプロジェクトを始める',
          description: '副業として、自分のペースで働けるプロジェクトを立ち上げましょう。',
          category: ActionCategory.career,
          timeframe: ActionTimeframe.mediumTerm,
          difficulty: ActionDifficulty.hard,
          tags: ['自律性', 'フリーランス', 'キャリア'],
          relevanceScore: 0.78,
          emoji: '💻',
        ),
      );
    }

    if (analysis.sdtScores['competence']! > 0.7) {
      goals.add(
        ActionRecommendation(
          id: 'medium_competence_1',
          title: '専門資格を取得する',
          description: 'キャリアに役立つ資格試験に合格しましょう。',
          category: ActionCategory.career,
          timeframe: ActionTimeframe.mediumTerm,
          difficulty: ActionDifficulty.hard,
          tags: ['資格', '専門性', 'キャリア'],
          relevanceScore: 0.80,
          emoji: '🏆',
        ),
      );
    }

    return goals.take(3).toList();
  }

  /// 長期目標（1年以上）を生成
  static List<ActionRecommendation> _generateLongTermGoals(
    AnalysisResult analysis,
    Map<String, double> categoryScores,
    List<dynamic> excitedQuestions,
  ) {
    final goals = <ActionRecommendation>[];

    // Ikigaiスコアに基づいた目標
    if (analysis.ikigaiScores['love']! > 0.7 &&
        analysis.ikigaiScores['worldNeeds']! > 0.7) {
      goals.add(
        ActionRecommendation(
          id: 'long_ikigai_1',
          title: '社会的インパクトのあるビジネスを立ち上げる',
          description: '情熱と社会貢献を両立させるビジネスを創造しましょう。',
          category: ActionCategory.career,
          timeframe: ActionTimeframe.longTerm,
          difficulty: ActionDifficulty.hard,
          tags: ['起業', '社会貢献', 'ikigai'],
          relevanceScore: 0.85,
          emoji: '🚀',
        ),
      );
    }

    return goals.take(2).toList();
  }

  /// 毎日の習慣を生成
  static List<HabitSuggestion> _generateDailyHabits(
    AnalysisResult analysis,
    Map<String, double> categoryScores,
    List<dynamic> excitedQuestions,
  ) {
    final habits = <HabitSuggestion>[];

    // 上位カテゴリから習慣を提案
    final topCategory = categoryScores.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;

    switch (topCategory) {
      case 'health':
        habits.add(
          HabitSuggestion(
            id: 'daily_health_1',
            title: '朝のストレッチ',
            trigger: '起床後すぐ',
            routine: '5分間の全身ストレッチ',
            reward: '体が軽くなり、1日を気持ちよくスタートできる',
            category: ActionCategory.health,
            durationMinutes: 5,
            emoji: '🧘',
          ),
        );
        break;

      case 'creativity':
        habits.add(
          HabitSuggestion(
            id: 'daily_creative_1',
            title: 'モーニングページ',
            trigger: '朝のコーヒーを飲みながら',
            routine: '思いついたことを3ページ書く',
            reward: '創造性が高まり、アイデアが湧きやすくなる',
            category: ActionCategory.creativity,
            durationMinutes: 15,
            emoji: '✍️',
          ),
        );
        break;

      case 'learning':
        habits.add(
          HabitSuggestion(
            id: 'daily_learning_1',
            title: '1日1記事',
            trigger: '昼休みの最初の10分',
            routine: '興味のある分野の記事を1つ読む',
            reward: '知識が蓄積され、話題が豊富になる',
            category: ActionCategory.learning,
            durationMinutes: 10,
            emoji: '📖',
          ),
        );
        break;

      default:
        habits.add(
          HabitSuggestion(
            id: 'daily_general_1',
            title: '感謝日記',
            trigger: '就寝前',
            routine: '今日感謝したこと3つを書く',
            reward: 'ポジティブな気持ちで1日を終えられる',
            category: ActionCategory.lifestyle,
            durationMinutes: 5,
            emoji: '📝',
          ),
        );
    }

    return habits;
  }

  /// 週1回の習慣を生成
  static List<HabitSuggestion> _generateWeeklyHabits(
    AnalysisResult analysis,
    Map<String, double> categoryScores,
    List<dynamic> excitedQuestions,
  ) {
    final habits = <HabitSuggestion>[];

    // 関係性スコアが高い場合
    if (analysis.sdtScores['relatedness']! > 0.7) {
      habits.add(
        HabitSuggestion(
          id: 'weekly_social_1',
          title: '友人との定期的な交流',
          trigger: '週末の午後',
          routine: '友人と会って話す、または電話する',
          reward: '人間関係が深まり、心が満たされる',
          category: ActionCategory.relationship,
          durationMinutes: 120,
          emoji: '☕',
        ),
      );
    }

    // 上位カテゴリに基づく習慣
    final topCategory = categoryScores.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;

    if (topCategory == 'sports') {
      habits.add(
        HabitSuggestion(
          id: 'weekly_sports_1',
          title: 'スポーツアクティビティ',
          trigger: '土曜日の朝',
          routine: '好きなスポーツを2時間楽しむ',
          reward: '体力がつき、ストレス解消になる',
          category: ActionCategory.sports,
          durationMinutes: 120,
          emoji: '🏃',
        ),
      );
    }

    return habits;
  }
}