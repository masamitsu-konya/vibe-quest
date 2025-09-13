import '../../shared/models/question.dart';

class PersonalityAnalyzer {
  // パーソナリティタイプの定義
  static const Map<String, PersonalityType> personalityTypes = {
    'explorer': PersonalityType(
      name: '探求者型',
      description: '新しい知識や経験を求め、常に学び続けることに喜びを感じるタイプ',
      traits: ['好奇心旺盛', '学習意欲が高い', '新しいことへの挑戦を恐れない'],
    ),
    'creator': PersonalityType(
      name: '創造者型',
      description: '自己表現や創作活動を通じて、世界に新しい価値を生み出すタイプ',
      traits: ['想像力豊か', '独創的', '美的センスが高い'],
    ),
    'supporter': PersonalityType(
      name: '支援者型',
      description: '他者との関わりや社会貢献を通じて、充実感を得るタイプ',
      traits: ['共感力が高い', '協調性がある', '人の役に立ちたい'],
    ),
    'challenger': PersonalityType(
      name: '挑戦者型',
      description: '高い目標を設定し、自己成長と達成感を追求するタイプ',
      traits: ['目標志向', '競争心が強い', '自己規律が高い'],
    ),
    'harmonizer': PersonalityType(
      name: '調和型',
      description: 'バランスの取れた生活と内面の平和を大切にするタイプ',
      traits: ['安定志向', 'マインドフル', '自己認識が高い'],
    ),
  };

  // 分析結果を生成
  static AnalysisResult analyze(List<Map<String, dynamic>> responses) {
    if (responses.isEmpty) {
      return AnalysisResult.empty();
    }

    final excitedResponses = responses.where((r) => r['is_excited'] == true).toList();
    final questions = excitedResponses.map((r) => r['question'] as Question).toList();

    // 各スコアの平均を計算
    final sdtScores = _calculateSDTScores(questions);
    final ikigaiScores = _calculateIkigaiScores(questions);
    final big5Scores = _calculateBig5Scores(questions);
    final motivationScore = _calculateMotivationScore(questions);

    // パーソナリティタイプを判定
    final personalityType = _determinePersonalityType(
      sdtScores,
      ikigaiScores,
      big5Scores,
      motivationScore,
    );

    // 価値観を分析
    final values = _analyzeValues(questions, sdtScores, ikigaiScores);

    // 洞察を生成
    final insights = _generateInsights(
      personalityType,
      values,
      sdtScores,
      ikigaiScores,
      big5Scores,
      responses.length,
      excitedResponses.length,
    );

    // 推奨アクションを生成
    final recommendations = _generateRecommendations(
      personalityType,
      values,
      questions,
    );

    return AnalysisResult(
      personalityType: personalityType,
      primaryValues: values,
      sdtScores: sdtScores,
      ikigaiScores: ikigaiScores,
      big5Scores: big5Scores,
      motivationScore: motivationScore,
      insights: insights,
      recommendations: recommendations,
      responseCount: responses.length,
      excitedCount: excitedResponses.length,
    );
  }

  // SDTスコアを計算
  static Map<String, double> _calculateSDTScores(List<Question> questions) {
    if (questions.isEmpty) {
      return {'autonomy': 0.5, 'competence': 0.5, 'relatedness': 0.5};
    }

    double autonomySum = 0;
    double competenceSum = 0;
    double relatednessSum = 0;

    for (final q in questions) {
      autonomySum += q.sdtAutonomy;
      competenceSum += q.sdtCompetence;
      relatednessSum += q.sdtRelatedness;
    }

    return {
      'autonomy': autonomySum / questions.length,
      'competence': competenceSum / questions.length,
      'relatedness': relatednessSum / questions.length,
    };
  }

  // ikigaiスコアを計算
  static Map<String, double> _calculateIkigaiScores(List<Question> questions) {
    if (questions.isEmpty) {
      return {
        'love': 0.5,
        'goodAt': 0.5,
        'worldNeeds': 0.5,
        'paidFor': 0.5,
      };
    }

    double loveSum = 0;
    double goodAtSum = 0;
    double worldNeedsSum = 0;
    double paidForSum = 0;

    for (final q in questions) {
      loveSum += q.ikigaiLove;
      goodAtSum += q.ikigaiGoodAt;
      worldNeedsSum += q.ikigaiWorldNeeds;
      paidForSum += q.ikigaiPaidFor;
    }

    return {
      'love': loveSum / questions.length,
      'goodAt': goodAtSum / questions.length,
      'worldNeeds': worldNeedsSum / questions.length,
      'paidFor': paidForSum / questions.length,
    };
  }

  // Big 5スコアを計算
  static Map<String, double> _calculateBig5Scores(List<Question> questions) {
    if (questions.isEmpty) {
      return {
        'openness': 0.5,
        'conscientiousness': 0.5,
        'extraversion': 0.5,
        'agreeableness': 0.5,
        'neuroticism': 0.5,
      };
    }

    double opennessSum = 0;
    double conscientiousnessSum = 0;
    double extraversionSum = 0;
    double agreeablenessSum = 0;
    double neuroticismSum = 0;

    for (final q in questions) {
      opennessSum += q.big5Openness;
      conscientiousnessSum += q.big5Conscientiousness;
      extraversionSum += q.big5Extraversion;
      agreeablenessSum += q.big5Agreeableness;
      neuroticismSum += q.big5Neuroticism;
    }

    return {
      'openness': opennessSum / questions.length,
      'conscientiousness': conscientiousnessSum / questions.length,
      'extraversion': extraversionSum / questions.length,
      'agreeableness': agreeablenessSum / questions.length,
      'neuroticism': neuroticismSum / questions.length,
    };
  }

  // 動機付けスコアを計算
  static double _calculateMotivationScore(List<Question> questions) {
    if (questions.isEmpty) return 0.5;

    int intrinsicCount = 0;
    for (final q in questions) {
      if (q.motivationType == 'intrinsic') intrinsicCount++;
    }

    return intrinsicCount / questions.length;
  }

  // パーソナリティタイプを判定
  static String _determinePersonalityType(
    Map<String, double> sdtScores,
    Map<String, double> ikigaiScores,
    Map<String, double> big5Scores,
    double motivationScore,
  ) {
    // スコアに基づいてタイプを判定
    final openness = big5Scores['openness']!;
    final conscientiousness = big5Scores['conscientiousness']!;
    final extraversion = big5Scores['extraversion']!;
    final agreeableness = big5Scores['agreeableness']!;

    final autonomy = sdtScores['autonomy']!;
    final competence = sdtScores['competence']!;
    final relatedness = sdtScores['relatedness']!;

    final worldNeeds = ikigaiScores['worldNeeds']!;
    final love = ikigaiScores['love']!;

    // 最も高いスコアに基づいてタイプを決定
    if (openness > 0.7 && autonomy > 0.6) {
      return 'explorer';
    } else if (openness > 0.6 && love > 0.7) {
      return 'creator';
    } else if (agreeableness > 0.7 && relatedness > 0.7 && worldNeeds > 0.6) {
      return 'supporter';
    } else if (conscientiousness > 0.7 && competence > 0.7) {
      return 'challenger';
    } else {
      return 'harmonizer';
    }
  }

  // 価値観を分析
  static List<String> _analyzeValues(
    List<Question> questions,
    Map<String, double> sdtScores,
    Map<String, double> ikigaiScores,
  ) {
    final values = <String>[];

    // SDTベースの価値観
    if (sdtScores['autonomy']! > 0.7) {
      values.add('自己決定と自由');
    }
    if (sdtScores['competence']! > 0.7) {
      values.add('成長と達成');
    }
    if (sdtScores['relatedness']! > 0.7) {
      values.add('つながりと協力');
    }

    // ikigaiベースの価値観
    if (ikigaiScores['love']! > 0.7) {
      values.add('情熱と楽しさ');
    }
    if (ikigaiScores['worldNeeds']! > 0.7) {
      values.add('社会貢献と意義');
    }
    if (ikigaiScores['goodAt']! > 0.7) {
      values.add('専門性と強み');
    }

    // 値観が少ない場合はデフォルトを追加
    if (values.isEmpty) {
      values.add('バランスと調和');
    }

    return values;
  }

  // 洞察を生成
  static List<String> _generateInsights(
    String personalityType,
    List<String> values,
    Map<String, double> sdtScores,
    Map<String, double> ikigaiScores,
    Map<String, double> big5Scores,
    int totalResponses,
    int excitedCount,
  ) {
    final insights = <String>[];
    final excitementRate = excitedCount / totalResponses;

    // 基本的な傾向
    if (excitementRate > 0.7) {
      insights.add('あなたは多くのことに興味を持ち、積極的に新しい挑戦を受け入れる傾向があります。');
    } else if (excitementRate > 0.4) {
      insights.add('あなたは選択的に興味を持ち、本当に価値があると感じることに集中する傾向があります。');
    } else {
      insights.add('あなたは慎重で、じっくりと考えてから行動する傾向があります。');
    }

    // SDTベースの洞察
    final autonomy = sdtScores['autonomy']!;
    final competence = sdtScores['competence']!;
    final relatedness = sdtScores['relatedness']!;

    if (autonomy > competence && autonomy > relatedness) {
      insights.add('自分で決定し、自分のペースで進めることが最も重要です。管理されることを好まず、創造的な自由を求めます。');
    } else if (competence > autonomy && competence > relatedness) {
      insights.add('スキルの向上と目標達成が原動力です。困難な課題に挑戦し、成長を実感することで充実感を得ます。');
    } else if (relatedness > autonomy && relatedness > competence) {
      insights.add('人とのつながりが活力の源です。チームで協力し、互いに支え合いながら目標を達成することを好みます。');
    }

    // ikigaiベースの洞察
    final love = ikigaiScores['love']!;
    final worldNeeds = ikigaiScores['worldNeeds']!;

    if (love > 0.7 && worldNeeds > 0.7) {
      insights.add('情熱と社会貢献の両立を求めています。好きなことで世界に価値を提供することが理想です。');
    } else if (love > 0.7) {
      insights.add('心から楽しめることを追求しています。内なる情熱に従うことで最高のパフォーマンスを発揮します。');
    } else if (worldNeeds > 0.7) {
      insights.add('社会的な意義を重視しています。自分の行動が他者や社会に良い影響を与えることに喜びを感じます。');
    }

    return insights;
  }

  // 推奨アクションを生成
  static List<String> _generateRecommendations(
    String personalityType,
    List<String> values,
    List<Question> questions,
  ) {
    final recommendations = <String>[];

    // パーソナリティタイプに基づく推奨
    switch (personalityType) {
      case 'explorer':
        recommendations.add('新しいスキルや知識を学ぶオンラインコースを始めてみましょう');
        recommendations.add('異なる分野の本を月に2冊読む習慣をつけましょう');
        recommendations.add('未経験の活動やワークショップに参加してみましょう');
        break;
      case 'creator':
        recommendations.add('創作活動のための定期的な時間を確保しましょう');
        recommendations.add('作品を共有できるコミュニティに参加しましょう');
        recommendations.add('日記やスケッチなど、日常的な創造的表現を始めましょう');
        break;
      case 'supporter':
        recommendations.add('ボランティア活動やコミュニティ活動に参加しましょう');
        recommendations.add('メンタリングやコーチングのスキルを学びましょう');
        recommendations.add('チームプロジェクトでリーダーシップを発揮してみましょう');
        break;
      case 'challenger':
        recommendations.add('具体的で測定可能な目標を設定し、進捗を記録しましょう');
        recommendations.add('新しい挑戦や競技に参加してみましょう');
        recommendations.add('自己改善のためのフィードバックを積極的に求めましょう');
        break;
      case 'harmonizer':
        recommendations.add('瞑想やヨガなど、心身のバランスを整える習慣を作りましょう');
        recommendations.add('自然の中で過ごす時間を増やしましょう');
        recommendations.add('生活のルーティンを見直し、より充実した日常を作りましょう');
        break;
    }

    // カテゴリー別の推奨
    final categoryCount = <String, int>{};
    for (final q in questions) {
      categoryCount[q.category] = (categoryCount[q.category] ?? 0) + 1;
    }

    if (categoryCount.isNotEmpty) {
      final topCategory = categoryCount.entries.reduce((a, b) => a.value > b.value ? a : b);
      recommendations.add(_getCategoryRecommendation(topCategory.key));
    }

    return recommendations;
  }

  static String _getCategoryRecommendation(String category) {
    switch (category) {
      case 'health':
        return '健康習慣を1つ選んで、21日間続けてみましょう';
      case 'career':
        return 'キャリアの5年計画を立て、最初の一歩を踏み出しましょう';
      case 'hobby':
        return '趣味の時間を週に最低3時間確保しましょう';
      case 'learning':
        return '興味のある分野の専門書を1冊読破しましょう';
      case 'relationship':
        return '大切な人との時間を意識的に作りましょう';
      case 'lifestyle':
        return '理想の1日のスケジュールを作成し、実践してみましょう';
      case 'finance':
        return '資産形成の基礎を学び、小さく始めてみましょう';
      case 'creativity':
        return '毎日15分、創造的な活動に取り組みましょう';
      case 'sports':
        return '新しいスポーツに挑戦し、3ヶ月続けてみましょう';
      case 'travel':
        return '次の冒険の計画を立て、実現への第一歩を踏み出しましょう';
      default:
        return '興味のある分野で小さな一歩を踏み出してみましょう';
    }
  }
}

// パーソナリティタイプのデータクラス
class PersonalityType {
  final String name;
  final String description;
  final List<String> traits;

  const PersonalityType({
    required this.name,
    required this.description,
    required this.traits,
  });
}

// 分析結果のデータクラス
class AnalysisResult {
  final String personalityType;
  final List<String> primaryValues;
  final Map<String, double> sdtScores;
  final Map<String, double> ikigaiScores;
  final Map<String, double> big5Scores;
  final double motivationScore;
  final List<String> insights;
  final List<String> recommendations;
  final int responseCount;
  final int excitedCount;

  const AnalysisResult({
    required this.personalityType,
    required this.primaryValues,
    required this.sdtScores,
    required this.ikigaiScores,
    required this.big5Scores,
    required this.motivationScore,
    required this.insights,
    required this.recommendations,
    required this.responseCount,
    required this.excitedCount,
  });

  factory AnalysisResult.empty() {
    return AnalysisResult(
      personalityType: 'unknown',
      primaryValues: [],
      sdtScores: {'autonomy': 0.5, 'competence': 0.5, 'relatedness': 0.5},
      ikigaiScores: {'love': 0.5, 'goodAt': 0.5, 'worldNeeds': 0.5, 'paidFor': 0.5},
      big5Scores: {
        'openness': 0.5,
        'conscientiousness': 0.5,
        'extraversion': 0.5,
        'agreeableness': 0.5,
        'neuroticism': 0.5,
      },
      motivationScore: 0.5,
      insights: [],
      recommendations: [],
      responseCount: 0,
      excitedCount: 0,
    );
  }
}