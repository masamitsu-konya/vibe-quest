import 'dart:math';
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

  // 洞察を生成（拡張版）
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
    final random = Random();

    // 基本的な傾向（より多様なパターン）
    if (excitementRate > 0.8) {
      final patterns = [
        'あなたは世界に対して開かれた心を持ち、あらゆる可能性を探求する情熱的な探求者です。',
        '強い好奇心と行動力を併せ持ち、常に新しい地平線を目指して前進しています。',
        '多様な興味が交差する地点で、独自の価値を生み出すマルチポテンシャライトです。',
      ];
      insights.add(patterns[random.nextInt(patterns.length)]);
    } else if (excitementRate > 0.6) {
      final patterns = [
        'バランスの取れた好奇心を持ち、意味のある挑戦を選択的に受け入れる賢明な探求者です。',
        '本質を見極める力があり、真に価値のあることに時間とエネルギーを投資しています。',
        '広い視野を保ちながら、核となる関心事に深くコミットする戦略的思考の持ち主です。',
      ];
      insights.add(patterns[random.nextInt(patterns.length)]);
    } else if (excitementRate > 0.4) {
      final patterns = [
        '慎重な選択と深い探求を重視し、質の高い経験を積み重ねています。',
        '自分の価値観に忠実で、本当に大切なことに集中する力を持っています。',
        '選択的な関心により、専門性と深い理解を築き上げる職人気質があります。',
      ];
      insights.add(patterns[random.nextInt(patterns.length)]);
    } else {
      final patterns = [
        '深い内省と慎重な判断により、確実な成長を遂げるタイプです。',
        '量より質を重視し、一つ一つの選択に意味を見出す哲学的思考の持ち主です。',
        '静かな観察者として、本質を見極めてから行動する賢者タイプです。',
      ];
      insights.add(patterns[random.nextInt(patterns.length)]);
    }

    // SDTベースの洞察（拡張版）
    final autonomy = sdtScores['autonomy']!;
    final competence = sdtScores['competence']!;
    final relatedness = sdtScores['relatedness']!;

    // より詳細なSDTパターン
    if (autonomy > 0.8 && competence > 0.7 && relatedness < 0.5) {
      insights.add('独立した達成者：自分の道を切り開き、個人の力で高みを目指すソロクライマータイプです。');
    } else if (autonomy > 0.7 && relatedness > 0.7) {
      insights.add('自律的協調者：自分らしさを保ちながら、他者と深く繋がる稀有なバランス感覚の持ち主です。');
    } else if (competence > 0.8 && relatedness > 0.7) {
      insights.add('実力派リーダー：高い専門性と人望を兼ね備え、チームを成功に導く天性のリーダーです。');
    } else if (autonomy > competence && autonomy > relatedness) {
      final patterns = [
        '自由な精神の持ち主：既存の枠組みにとらわれず、独自の価値観で人生を設計しています。',
        '独創的な思考者：他者の意見に左右されず、自分の内なる声に従って行動します。',
        '自己決定の達人：外部からの圧力に屈せず、自分の信念を貫く強さがあります。',
      ];
      insights.add(patterns[random.nextInt(patterns.length)]);
    } else if (competence > autonomy && competence > relatedness) {
      final patterns = [
        '卓越性の追求者：常により高い水準を目指し、自己の限界に挑戦し続けています。',
        'マスタリー志向：深い専門性と技術の習得に喜びを見出し、職人的な完璧さを求めます。',
        '成長の体現者：昨日の自分を超えることが最大の動機となる、進化し続ける存在です。',
      ];
      insights.add(patterns[random.nextInt(patterns.length)]);
    } else if (relatedness > autonomy && relatedness > competence) {
      final patterns = [
        '共感の達人：他者の感情を深く理解し、心の架け橋を築く天賦の才能があります。',
        'コミュニティビルダー：人々を結びつけ、共に成長する環境を創造します。',
        '関係性の紡ぎ手：深い信頼関係を基盤に、意味のある人生を構築しています。',
      ];
      insights.add(patterns[random.nextInt(patterns.length)]);
    }

    // ikigaiベースの洞察（拡張版）
    final love = ikigaiScores['love']!;
    final worldNeeds = ikigaiScores['worldNeeds']!;
    final goodAt = ikigaiScores['goodAt']!;
    final paidFor = ikigaiScores['paidFor']!;

    // 4要素の完全な組み合わせ
    if (love > 0.7 && worldNeeds > 0.7 && goodAt > 0.7 && paidFor > 0.7) {
      final patterns = [
        '生きがいの完全体：4つの要素が見事に調和し、充実した人生の羅針盤を手にしています。',
        '理想的な統合：情熱、才能、社会貢献、経済的価値が一体となり、持続可能な幸福を実現しています。',
        '生きがいマスター：全ての要素が高次元で融合し、自己実現と社会貢献を両立させています。',
      ];
      insights.add(patterns[random.nextInt(patterns.length)]);
    }
    // 3要素の組み合わせ
    else if (love > 0.7 && worldNeeds > 0.7 && goodAt > 0.7) {
      insights.add('使命の実現者：情熱と才能を社会のために活かす、真の意味での天職に近づいています。');
    } else if (love > 0.7 && goodAt > 0.7 && paidFor > 0.7) {
      insights.add('プロフェッショナルアーティスト：好きなことを仕事にし、それで生計を立てる理想を実現しています。');
    } else if (worldNeeds > 0.7 && goodAt > 0.7 && paidFor > 0.7) {
      insights.add('社会的成功者：スキルを社会のために活かし、適切な報酬を得ています。');
    } else if (love > 0.7 && worldNeeds > 0.7 && paidFor > 0.7) {
      insights.add('情熱的起業家：愛することで社会に貢献し、収入も得ています。');
    }
    // 2要素の組み合わせ
    else if (love > 0.7 && worldNeeds > 0.7) {
      final patterns = [
        '使命感の体現者：情熱と社会貢献が一致し、意義深い活動に従事しています。',
        '理想主義的実践者：愛と奉仕の精神で、世界をより良くすることに喜びを見出しています。',
        'パッションドリブン：心からの情熱が社会価値を生み出す原動力となっています。',
      ];
      insights.add(patterns[random.nextInt(patterns.length)]);
    } else if (goodAt > 0.7 && paidFor > 0.7) {
      final patterns = [
        'プロフェッショナル：専門性を経済価値に変換する能力に優れています。',
        'スキルマネタイザー：才能を適切に収益化し、安定した基盤を築いています。',
        '実務的達成者：能力と市場価値が一致し、キャリアの成功を収めています。',
      ];
      insights.add(patterns[random.nextInt(patterns.length)]);
    } else if (love > 0.7 && goodAt > 0.7) {
      final patterns = [
        '情熱的な職人：好きなことに才能を発揮し、充実感を得ています。',
        'フロー状態の達人：愛と能力が融合し、時間を忘れて没頭できる活動があります。',
        '天性の才能：自然な興味と能力が一致し、努力を努力と感じない境地にいます。',
      ];
      insights.add(patterns[random.nextInt(patterns.length)]);
    }
    // 単一要素が突出
    else if (love > 0.8) {
      insights.add('純粋な情熱家：心から愛することを追求する、真正性の高い生き方をしています。');
    } else if (worldNeeds > 0.8) {
      insights.add('利他的奉仕者：他者と社会のニーズを優先し、貢献に生きがいを見出しています。');
    } else if (goodAt > 0.8) {
      insights.add('卓越した実力者：並外れた能力を持ち、その分野でのエクセレンスを追求しています。');
    } else if (paidFor > 0.8) {
      insights.add('経済的実現者：価値を収益に変える優れた能力を持ち、経済的自立を達成しています。');
    }

    // Big5ベースの洞察（新規追加）
    final openness = big5Scores['openness']!;
    final conscientiousness = big5Scores['conscientiousness']!;
    final extraversion = big5Scores['extraversion']!;
    final agreeableness = big5Scores['agreeableness']!;
    final neuroticism = big5Scores['neuroticism']!;

    // 複合的なBig5パターン
    if (openness > 0.8 && conscientiousness > 0.7) {
      final patterns = [
        '革新的実行者：創造性と実行力を兼ね備え、アイデアを現実に変える力があります。',
        'ビジョナリー実践者：大きな視野と細部への注意力を併せ持つ、稀有な才能の持ち主です。',
        '創造的達成者：イノベーションを体系的に実現する、理想と現実のバランサーです。',
      ];
      insights.add(patterns[random.nextInt(patterns.length)]);
    } else if (extraversion > 0.8 && agreeableness > 0.7) {
      final patterns = [
        'カリスマ的協調者：人を惹きつけ、調和を保ちながらグループを導く天性のリーダーです。',
        '社交的調和者：活発なコミュニケーションと思いやりで、温かい人間関係を築きます。',
        '人間関係の達人：外向性と協調性の絶妙なバランスで、誰とでも良好な関係を築けます。',
      ];
      insights.add(patterns[random.nextInt(patterns.length)]);
    } else if (conscientiousness > 0.8 && agreeableness > 0.7) {
      final patterns = [
        '信頼の体現者：責任感と思いやりを併せ持ち、周囲から厚い信頼を得ています。',
        '堅実な支援者：確実な実行力と優しさで、チームの要となる存在です。',
        '誠実なリーダー：高い倫理観と実行力で、模範となる行動を示します。',
      ];
      insights.add(patterns[random.nextInt(patterns.length)]);
    } else if (openness > 0.8 && extraversion > 0.7) {
      final patterns = [
        '創造的表現者：豊かな想像力と表現力で、新しい世界を切り開きます。',
        'イノベーティブコミュニケーター：斬新なアイデアを魅力的に伝える才能があります。',
        '冒険的創造者：新しい経験と創造性を融合させ、独自の道を切り開きます。',
      ];
      insights.add(patterns[random.nextInt(patterns.length)]);
    }

    // 低い神経症傾向の特別な洞察
    if (neuroticism < 0.3) {
      final patterns = [
        '感情的安定性の達人：どんな状況でも冷静さを保ち、最適な判断ができます。',
        'ストレス耐性の持ち主：プレッシャーを成長の機会に変える強さがあります。',
        '心理的レジリエンス：困難から素早く回復し、前向きに進む力を持っています。',
      ];
      insights.add(patterns[random.nextInt(patterns.length)]);
    }

    // 単一のBig5特性が突出している場合
    if (openness > 0.85) {
      final patterns = [
        '無限の可能性を見る人：既存の枠を超えて、新しい世界を想像できます。',
        '知的探求者：あらゆる分野に興味を持ち、学びを楽しむ生涯学習者です。',
        'アイデアの泉：創造的な発想が次々と湧き出る、イノベーションの源です。',
      ];
      insights.add(patterns[random.nextInt(patterns.length)]);
    } else if (conscientiousness > 0.85) {
      final patterns = [
        '完璧主義的達成者：高い基準と強い意志で、卓越した成果を生み出します。',
        '自己規律の体現者：目標に向かって着実に前進する、不屈の精神の持ち主です。',
        '信頼性の象徴：約束を必ず守り、期待を超える成果を出す実行者です。',
      ];
      insights.add(patterns[random.nextInt(patterns.length)]);
    } else if (extraversion > 0.85) {
      final patterns = [
        'エネルギーの発信源：周囲を活気づけ、ポジティブな雰囲気を作り出します。',
        '社交界の中心：人々を結びつけ、活発なコミュニケーションを生み出します。',
        '行動派リーダー：積極的な姿勢で、グループを前進させる推進力となります。',
      ];
      insights.add(patterns[random.nextInt(patterns.length)]);
    } else if (agreeableness > 0.85) {
      final patterns = [
        '共感の達人：他者の感情を深く理解し、心に寄り添うことができます。',
        '調和の創造者：対立を解消し、皆が幸せになる解決策を見出します。',
        '利他的奉仕者：他者の幸福を自分の喜びとする、純粋な優しさの持ち主です。',
      ];
      insights.add(patterns[random.nextInt(patterns.length)]);
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