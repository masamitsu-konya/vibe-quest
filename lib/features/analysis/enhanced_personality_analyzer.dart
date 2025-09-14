import 'dart:math';
import '../../shared/models/question.dart';

class EnhancedPersonalityAnalyzer {
  // メインタイプとサブタイプの組み合わせ
  static const Map<String, Map<String, PersonalityProfile>> personalityProfiles = {
    'explorer_pioneer': PersonalityProfile(
      mainType: '探求者',
      subType: '開拓者',
      description: '未知の領域を恐れず、常に新しい可能性を追求する冒険家タイプ',
      traits: ['先駆的', '独立心旺盛', '革新的思考'],
      strengthArea: '新規開拓・イノベーション',
    ),
    'explorer_scholar': PersonalityProfile(
      mainType: '探求者',
      subType: '学究者',
      description: '知識の深淵を追求し、理論と実践を結びつける研究者タイプ',
      traits: ['分析的', '体系的思考', '知的好奇心'],
      strengthArea: '研究・分析・理論構築',
    ),
    'explorer_wanderer': PersonalityProfile(
      mainType: '探求者',
      subType: '放浪者',
      description: '多様な経験を通じて自己を発見する自由人タイプ',
      traits: ['柔軟性', '適応力', '多角的視点'],
      strengthArea: '異文化理解・適応力',
    ),
    'creator_artist': PersonalityProfile(
      mainType: '創造者',
      subType: '芸術家',
      description: '感性と技術を融合させ、美的価値を生み出すアーティストタイプ',
      traits: ['審美眼', '表現力', '感受性'],
      strengthArea: '芸術・デザイン・美的創造',
    ),
    'creator_innovator': PersonalityProfile(
      mainType: '創造者',
      subType: '革新者',
      description: '既存の枠組みを超えて、新しい価値を創造するイノベータータイプ',
      traits: ['発想力', '実行力', '変革志向'],
      strengthArea: 'イノベーション・問題解決',
    ),
    'creator_builder': PersonalityProfile(
      mainType: '創造者',
      subType: '構築者',
      description: 'アイデアを形にし、持続可能なシステムを作り上げるビルダータイプ',
      traits: ['構築力', '計画性', '実現力'],
      strengthArea: 'システム構築・プロジェクト管理',
    ),
    'supporter_mentor': PersonalityProfile(
      mainType: '支援者',
      subType: '導師',
      description: '他者の成長を導き、潜在能力を引き出すメンタータイプ',
      traits: ['洞察力', '忍耐力', '育成力'],
      strengthArea: '人材育成・コーチング',
    ),
    'supporter_healer': PersonalityProfile(
      mainType: '支援者',
      subType: '癒し手',
      description: '心身の癒しを提供し、他者の回復を支援するヒーラータイプ',
      traits: ['共感力', '包容力', '癒しの力'],
      strengthArea: 'ケア・サポート・癒し',
    ),
    'supporter_connector': PersonalityProfile(
      mainType: '支援者',
      subType: '繋ぎ手',
      description: '人と人を結び、コミュニティを育むコネクタータイプ',
      traits: ['社交性', 'ネットワーク力', '調整力'],
      strengthArea: 'コミュニティ構築・連携',
    ),
    'challenger_warrior': PersonalityProfile(
      mainType: '挑戦者',
      subType: '戦士',
      description: '困難に立ち向かい、限界を突破する戦士タイプ',
      traits: ['勇気', '不屈の精神', '突破力'],
      strengthArea: '困難克服・目標達成',
    ),
    'challenger_strategist': PersonalityProfile(
      mainType: '挑戦者',
      subType: '戦略家',
      description: '長期的視点で計画を立て、着実に目標を達成する戦略家タイプ',
      traits: ['戦略的思考', '計画力', '先見性'],
      strengthArea: '戦略立案・長期計画',
    ),
    'challenger_competitor': PersonalityProfile(
      mainType: '挑戦者',
      subType: '競争者',
      description: '競争を通じて自己を高め、卓越性を追求する競争者タイプ',
      traits: ['競争心', '向上心', '成果志向'],
      strengthArea: '競争・パフォーマンス向上',
    ),
    'harmonizer_mediator': PersonalityProfile(
      mainType: '調和者',
      subType: '調停者',
      description: '対立を解消し、バランスの取れた解決策を見出す調停者タイプ',
      traits: ['公平性', '冷静さ', '調整力'],
      strengthArea: '紛争解決・調整',
    ),
    'harmonizer_philosopher': PersonalityProfile(
      mainType: '調和者',
      subType: '哲学者',
      description: '内省と洞察を通じて、人生の意味を探求する哲学者タイプ',
      traits: ['内省的', '洞察力', '俯瞰的視点'],
      strengthArea: '思索・意味探求',
    ),
    'harmonizer_gardener': PersonalityProfile(
      mainType: '調和者',
      subType: '庭師',
      description: '環境を整え、持続可能な成長を促す庭師タイプ',
      traits: ['育成力', '忍耐力', '環境配慮'],
      strengthArea: '環境整備・持続的成長',
    ),
  };

  // SDTとIkigaiの組み合わせパターン
  static Map<String, String> generateCombinedInsight(
    Map<String, double> sdtScores,
    Map<String, double> ikigaiScores,
  ) {
    final insights = <String, String>{};

    // 自律性 × 愛
    if (sdtScores['autonomy']! > 0.7 && ikigaiScores['love']! > 0.7) {
      insights['autonomy_love'] = '自分の情熱に従って自由に行動することで、最も充実感を得られます。他者の期待よりも、自分の内なる声に耳を傾けることが重要です。';
    }

    // 有能感 × 得意
    if (sdtScores['competence']! > 0.7 && ikigaiScores['goodAt']! > 0.7) {
      insights['competence_goodAt'] = '既に持っている強みをさらに磨き上げることで、専門性を確立できます。得意分野での卓越性が、あなたの価値を高めます。';
    }

    // 関係性 × 世界のニーズ
    if (sdtScores['relatedness']! > 0.7 && ikigaiScores['worldNeeds']! > 0.7) {
      insights['relatedness_worldNeeds'] = '社会への貢献を通じて深い人間関係を築くことができます。あなたの活動が他者に与える影響が、存在意義を確かなものにします。';
    }

    // 自律性 × 報酬
    if (sdtScores['autonomy']! > 0.7 && ikigaiScores['paidFor']! > 0.7) {
      insights['autonomy_paidFor'] = '経済的独立と自己決定権の両立を重視しています。自分のビジネスや独立したキャリアパスが適している可能性があります。';
    }

    // 有能感 × 世界のニーズ
    if (sdtScores['competence']! > 0.7 && ikigaiScores['worldNeeds']! > 0.7) {
      insights['competence_worldNeeds'] = 'スキルを社会課題の解決に活用することで、大きなインパクトを生み出せます。専門性を活かした社会貢献が天職となるでしょう。';
    }

    // 関係性 × 愛
    if (sdtScores['relatedness']! > 0.7 && ikigaiScores['love']! > 0.7) {
      insights['relatedness_love'] = '人とのつながりの中で情熱を共有することが、最大の喜びです。チームでの創造的な活動があなたを輝かせます。';
    }

    return insights;
  }

  // Big5とSDTの組み合わせによる詳細な特性分析
  static List<String> generateDetailedTraits(
    Map<String, double> big5Scores,
    Map<String, double> sdtScores,
  ) {
    final traits = <String>[];

    // 開放性 × 自律性
    if (big5Scores['openness']! > 0.7 && sdtScores['autonomy']! > 0.7) {
      traits.add('革新的な自由思想家：既存の枠にとらわれず、独自の道を切り開く');
    }

    // 誠実性 × 有能感
    if (big5Scores['conscientiousness']! > 0.7 && sdtScores['competence']! > 0.7) {
      traits.add('卓越した実行者：高い基準を設定し、着実に成果を出す');
    }

    // 外向性 × 関係性
    if (big5Scores['extraversion']! > 0.7 && sdtScores['relatedness']! > 0.7) {
      traits.add('カリスマ的リーダー：人を巻き込み、共に成長する');
    }

    // 協調性 × 関係性
    if (big5Scores['agreeableness']! > 0.7 && sdtScores['relatedness']! > 0.7) {
      traits.add('共感的サポーター：他者の感情を理解し、支援する');
    }

    // 開放性 × 有能感
    if (big5Scores['openness']! > 0.7 && sdtScores['competence']! > 0.7) {
      traits.add('創造的問題解決者：新しいアプローチで課題を克服する');
    }

    // 誠実性 × 自律性
    if (big5Scores['conscientiousness']! > 0.7 && sdtScores['autonomy']! > 0.7) {
      traits.add('自律的達成者：自己管理能力が高く、独立して目標を達成する');
    }

    // 低い神経症傾向 × 高い有能感
    if (big5Scores['neuroticism']! < 0.3 && sdtScores['competence']! > 0.7) {
      traits.add('ストレス耐性リーダー：プレッシャー下でも冷静に対処する');
    }

    return traits;
  }

  // カテゴリー別の詳細分析
  static Map<String, CategoryAnalysis> analyzeCategoryPreferences(
    List<Map<String, dynamic>> responses,
  ) {
    final categoryStats = <String, CategoryAnalysis>{};
    final excitedByCategory = <String, List<Question>>{};

    for (final response in responses) {
      final question = response['question'] as Question;
      final isExcited = response['is_excited'] as bool;

      if (isExcited) {
        excitedByCategory.putIfAbsent(question.category, () => []).add(question);
      }
    }

    for (final entry in excitedByCategory.entries) {
      final category = entry.key;
      final questions = entry.value;

      // カテゴリー別の傾向を分析
      final avgGrowthScore = questions.map((q) => q.growthScore).reduce((a, b) => a + b) / questions.length;

      String tendency;
      String recommendation;

      if (category == 'health' && avgGrowthScore > 0.7) {
        tendency = '身体的・精神的な健康への高い意識を持っています';
        recommendation = '定期的な運動習慣とマインドフルネスの実践を組み合わせると効果的です';
      } else if (category == 'career' && avgGrowthScore > 0.7) {
        tendency = 'キャリア発展への強い意欲があります';
        recommendation = 'スキルアップと人脈構築を並行して進めることが成功への鍵です';
      } else if (category == 'creativity' && avgGrowthScore > 0.7) {
        tendency = '創造的表現への強い欲求があります';
        recommendation = '日常的に創作活動の時間を確保し、作品を共有する場を持ちましょう';
      } else if (category == 'relationship' && avgGrowthScore > 0.7) {
        tendency = '人間関係を通じた成長を重視しています';
        recommendation = '深い対話の機会を増やし、相互理解を深めることが充実感につながります';
      } else if (category == 'learning' && avgGrowthScore > 0.7) {
        tendency = '知的探求心が非常に強いです';
        recommendation = '体系的な学習計画を立て、学んだことを実践する機会を作りましょう';
      } else if (category == 'adventure' && avgGrowthScore > 0.7) {
        tendency = '新しい挑戦への意欲が高いです';
        recommendation = '計算されたリスクテイクと振り返りの習慣が成長を加速させます';
      } else if (category == 'service' && avgGrowthScore > 0.7) {
        tendency = '社会貢献への強い関心があります';
        recommendation = '自分のスキルを活かした持続可能な貢献方法を見つけることが重要です';
      } else if (category == 'mindfulness' && avgGrowthScore > 0.7) {
        tendency = '内面の平和と自己認識を大切にしています';
        recommendation = '瞑想や内省の時間を日課にすることで、より深い洞察が得られます';
      } else if (category == 'entertainment' && avgGrowthScore > 0.7) {
        tendency = '楽しみと刺激を通じた充実を求めています';
        recommendation = '娯楽と成長を組み合わせた活動を選ぶことで、両方の価値を得られます';
      } else if (category == 'hobby' && avgGrowthScore > 0.7) {
        tendency = '趣味を通じた自己表現を重視しています';
        recommendation = '趣味を深めてコミュニティに参加することで、新しい可能性が開けます';
      } else {
        tendency = 'バランスの取れた関心を持っています';
        recommendation = '興味の幅を保ちながら、特に惹かれる分野を深めていきましょう';
      }

      categoryStats[category] = CategoryAnalysis(
        category: category,
        excitementRate: questions.length / responses.length,
        averageGrowthScore: avgGrowthScore,
        tendency: tendency,
        recommendation: recommendation,
      );
    }

    return categoryStats;
  }

  // 成長段階の判定
  static String determineGrowthStage(
    int responseCount,
    double excitementRate,
    Map<String, double> scores,
  ) {
    final avgScore = scores.values.reduce((a, b) => a + b) / scores.length;

    if (responseCount < 30) {
      return '探索期：様々な可能性を探っている段階です。多様な経験を積むことが重要です。';
    } else if (responseCount < 100 && excitementRate > 0.6) {
      return '発見期：自分の興味や価値観が明確になってきています。焦点を絞り始める時期です。';
    } else if (avgScore > 0.7 && excitementRate > 0.5) {
      return '成長期：明確な方向性を持ち、着実に前進しています。深化と拡大のバランスが大切です。';
    } else if (avgScore > 0.8) {
      return '成熟期：自己理解が深まり、独自の道を歩んでいます。他者への貢献も視野に入れましょう。';
    } else {
      return '転換期：新しい段階への移行期にいます。変化を恐れず、柔軟に対応することが重要です。';
    }
  }

  // 動機づけプロファイルの生成
  static MotivationProfile generateMotivationProfile(
    List<Question> questions,
  ) {
    int intrinsicCount = 0;
    int extrinsicCount = 0;
    int mixedCount = 0;

    for (final question in questions) {
      switch (question.motivationType) {
        case 'intrinsic':
          intrinsicCount++;
          break;
        case 'extrinsic':
          extrinsicCount++;
          break;
        case 'mixed':
          mixedCount++;
          break;
      }
    }

    final total = questions.length;
    if (total == 0) {
      return MotivationProfile(
        type: 'balanced',
        description: 'バランスの取れた動機づけ',
        advice: '内発的・外発的動機のバランスを保ちましょう',
      );
    }

    final intrinsicRate = intrinsicCount / total;
    final extrinsicRate = extrinsicCount / total;
    final mixedRate = mixedCount / total;

    if (intrinsicRate > 0.6) {
      return MotivationProfile(
        type: 'intrinsic_dominant',
        description: '内発的動機優位：活動そのものに喜びを見出すタイプ',
        advice: '情熱に従うことで最高のパフォーマンスを発揮できます。外的報酬に惑わされず、内なる声に耳を傾けましょう。',
      );
    } else if (extrinsicRate > 0.6) {
      return MotivationProfile(
        type: 'extrinsic_dominant',
        description: '外発的動機優位：明確な目標と報酬を求めるタイプ',
        advice: '具体的な目標設定と達成度の可視化が重要です。小さな成功を積み重ねることでモチベーションを維持できます。',
      );
    } else if (mixedRate > 0.4) {
      return MotivationProfile(
        type: 'hybrid',
        description: 'ハイブリッド型：状況に応じて動機を使い分けるタイプ',
        advice: '柔軟な動機づけスタイルが強みです。状況に応じて内発的・外発的動機を使い分けることで、持続的な成長が可能です。',
      );
    } else {
      return MotivationProfile(
        type: 'balanced',
        description: 'バランス型：多様な動機源から力を得るタイプ',
        advice: '複数の動機源を持つことで、安定した成長が可能です。様々な角度から自己を見つめ、総合的な発展を目指しましょう。',
      );
    }
  }

  // 時系列分析（スワイプパターンの変化）
  static TimeSeriesAnalysis analyzeTemporalPatterns(
    List<Map<String, dynamic>> responses,
  ) {
    if (responses.length < 20) {
      return TimeSeriesAnalysis(
        trend: 'insufficient_data',
        description: 'パターン分析には更に多くのデータが必要です',
        insight: '継続的な利用により、より詳細な傾向が見えてきます',
      );
    }

    // 前半と後半で傾向を比較
    final midPoint = responses.length ~/ 2;
    final firstHalf = responses.sublist(0, midPoint);
    final secondHalf = responses.sublist(midPoint);

    final firstHalfExcitement = firstHalf.where((r) => r['is_excited'] == true).length / firstHalf.length;
    final secondHalfExcitement = secondHalf.where((r) => r['is_excited'] == true).length / secondHalf.length;

    final difference = secondHalfExcitement - firstHalfExcitement;

    if (difference > 0.2) {
      return TimeSeriesAnalysis(
        trend: 'increasing',
        description: '興味の幅が広がっている',
        insight: 'より多くのことに関心を持つようになっています。新しい可能性に開かれた状態です。',
      );
    } else if (difference < -0.2) {
      return TimeSeriesAnalysis(
        trend: 'focusing',
        description: '興味が絞られてきている',
        insight: '本当に重要なことが明確になってきています。選択と集中の段階に入っています。',
      );
    } else {
      return TimeSeriesAnalysis(
        trend: 'stable',
        description: '安定した興味パターン',
        insight: '一貫した価値観を持っています。自己理解が深まっている証拠です。',
      );
    }
  }
}

// サポートクラス
class PersonalityProfile {
  final String mainType;
  final String subType;
  final String description;
  final List<String> traits;
  final String strengthArea;

  const PersonalityProfile({
    required this.mainType,
    required this.subType,
    required this.description,
    required this.traits,
    required this.strengthArea,
  });
}

class CategoryAnalysis {
  final String category;
  final double excitementRate;
  final double averageGrowthScore;
  final String tendency;
  final String recommendation;

  const CategoryAnalysis({
    required this.category,
    required this.excitementRate,
    required this.averageGrowthScore,
    required this.tendency,
    required this.recommendation,
  });
}

class MotivationProfile {
  final String type;
  final String description;
  final String advice;

  const MotivationProfile({
    required this.type,
    required this.description,
    required this.advice,
  });
}

class TimeSeriesAnalysis {
  final String trend;
  final String description;
  final String insight;

  const TimeSeriesAnalysis({
    required this.trend,
    required this.description,
    required this.insight,
  });
}