import 'dart:math';

/// 洞察生成クラス
class InsightGenerator {
  static final _random = Random();

  /// 基本傾向の洞察を生成
  static String generateBasicTendencyInsight(double excitementRate) {
    if (excitementRate > 0.8) {
      final patterns = [
        'あなたは世界に対して開かれた心を持ち、あらゆる可能性を探求する情熱的な探求者です。',
        '強い好奇心と行動力を併せ持ち、常に新しい地平線を目指して前進しています。',
        '多様な興味が交差する地点で、独自の価値を生み出すマルチポテンシャライトです。',
      ];
      return patterns[_random.nextInt(patterns.length)];
    } else if (excitementRate > 0.6) {
      final patterns = [
        'バランスの取れた好奇心を持ち、意味のある挑戦を選択的に受け入れる賢明な探求者です。',
        '本質を見極める力があり、真に価値のあることに時間とエネルギーを投資しています。',
        '広い視野を保ちながら、核となる関心事に深くコミットする戦略的思考の持ち主です。',
      ];
      return patterns[_random.nextInt(patterns.length)];
    } else if (excitementRate > 0.4) {
      final patterns = [
        '慎重な選択と深い探求を重視し、質の高い経験を積み重ねています。',
        '自分の価値観に忠実で、本当に大切なことに集中する力を持っています。',
        '選択的な関心により、専門性と深い理解を築き上げる職人気質があります。',
      ];
      return patterns[_random.nextInt(patterns.length)];
    } else {
      final patterns = [
        '深い内省と慎重な判断により、確実な成長を遂げるタイプです。',
        '量より質を重視し、一つ一つの選択に意味を見出す哲学的思考の持ち主です。',
        '静かな観察者として、本質を見極めてから行動する賢者タイプです。',
      ];
      return patterns[_random.nextInt(patterns.length)];
    }
  }

  /// SDTベースの洞察を生成
  static List<String> generateSDTInsights(Map<String, double> sdtScores) {
    final insights = <String>[];
    final autonomy = sdtScores['autonomy']!;
    final competence = sdtScores['competence']!;
    final relatedness = sdtScores['relatedness']!;

    // 複合パターン
    if (autonomy > 0.8 && competence > 0.7 && relatedness < 0.5) {
      insights.add('独立した達成者：自分の道を切り開き、個人の力で高みを目指すソロクライマータイプです。');
    } else if (autonomy > 0.7 && relatedness > 0.7) {
      insights.add('自律的協調者：自分らしさを保ちながら、他者と深く繋がる稀有なバランス感覚の持ち主です。');
    } else if (competence > 0.8 && relatedness > 0.7) {
      insights.add('実力派リーダー：高い専門性と人望を兼ね備え、チームを成功に導く天性のリーダーです。');
    }

    // 単一優位パターン
    if (autonomy > competence && autonomy > relatedness) {
      final patterns = [
        '自由な精神の持ち主：既存の枠組みにとらわれず、独自の価値観で人生を設計しています。',
        '独創的な思考者：他者の意見に左右されず、自分の内なる声に従って行動します。',
        '自己決定の達人：外部からの圧力に屈せず、自分の信念を貫く強さがあります。',
      ];
      insights.add(patterns[_random.nextInt(patterns.length)]);
    } else if (competence > autonomy && competence > relatedness) {
      final patterns = [
        '卓越性の追求者：常により高い水準を目指し、自己の限界に挑戦し続けています。',
        'マスタリー志向：深い専門性と技術の習得に喜びを見出し、職人的な完璧さを求めます。',
        '成長の体現者：昨日の自分を超えることが最大の動機となる、進化し続ける存在です。',
      ];
      insights.add(patterns[_random.nextInt(patterns.length)]);
    } else if (relatedness > autonomy && relatedness > competence) {
      final patterns = [
        '共感の達人：他者の感情を深く理解し、心の架け橋を築く天賦の才能があります。',
        'コミュニティビルダー：人々を結びつけ、共に成長する環境を創造します。',
        '関係性の紡ぎ手：深い信頼関係を基盤に、意味のある人生を構築しています。',
      ];
      insights.add(patterns[_random.nextInt(patterns.length)]);
    }

    return insights;
  }

  /// 生きがいベースの洞察を生成
  static List<String> generateIkigaiInsights(Map<String, double> ikigaiScores) {
    final insights = <String>[];
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
      insights.add(patterns[_random.nextInt(patterns.length)]);
    }
    // 3要素の組み合わせ
    else if (love > 0.7 && worldNeeds > 0.7 && goodAt > 0.7) {
      insights.add('使命の実現者：情熱と才能を社会のために活かす、真の意味での天職に近づいています。');
    } else if (love > 0.7 && goodAt > 0.7 && paidFor > 0.7) {
      insights.add('プロフェッショナルアーティスト：好きなことを仕事にし、それで生計を立てる理想を実現しています。');
    }
    // 2要素の組み合わせ
    else if (love > 0.7 && worldNeeds > 0.7) {
      final patterns = [
        '使命感の体現者：情熱と社会貢献が一致し、意義深い活動に従事しています。',
        '理想主義的実践者：愛と奉仕の精神で、世界をより良くすることに喜びを見出しています。',
        'パッションドリブン：心からの情熱が社会価値を生み出す原動力となっています。',
      ];
      insights.add(patterns[_random.nextInt(patterns.length)]);
    }

    return insights;
  }

  /// ビッグファイブベースの洞察を生成
  static List<String> generateBig5Insights(Map<String, double> big5Scores) {
    final insights = <String>[];
    final openness = big5Scores['openness']!;
    final conscientiousness = big5Scores['conscientiousness']!;
    final extraversion = big5Scores['extraversion']!;
    final agreeableness = big5Scores['agreeableness']!;
    final neuroticism = big5Scores['neuroticism']!;

    // 複合パターン
    if (openness > 0.8 && conscientiousness > 0.7) {
      final patterns = [
        '革新的実行者：創造性と実行力を兼ね備え、アイデアを現実に変える力があります。',
        'ビジョナリー実践者：大きな視野と細部への注意力を併せ持つ、稀有な才能の持ち主です。',
        '創造的達成者：イノベーションを体系的に実現する、理想と現実のバランサーです。',
      ];
      insights.add(patterns[_random.nextInt(patterns.length)]);
    }

    // 低い神経症傾向
    if (neuroticism < 0.3) {
      final patterns = [
        '感情的安定性の達人：どんな状況でも冷静さを保ち、最適な判断ができます。',
        'ストレス耐性の持ち主：プレッシャーを成長の機会に変える強さがあります。',
        '心理的レジリエンス：困難から素早く回復し、前向きに進む力を持っています。',
      ];
      insights.add(patterns[_random.nextInt(patterns.length)]);
    }

    // 単一特性が突出
    if (openness > 0.85) {
      final patterns = [
        '無限の可能性を見る人：既存の枠を超えて、新しい世界を想像できます。',
        '知的探求者：あらゆる分野に興味を持ち、学びを楽しむ生涯学習者です。',
        'アイデアの泉：創造的な発想が次々と湧き出る、イノベーションの源です。',
      ];
      insights.add(patterns[_random.nextInt(patterns.length)]);
    }

    return insights;
  }
}