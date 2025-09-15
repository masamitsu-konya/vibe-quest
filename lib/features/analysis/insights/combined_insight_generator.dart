/// SDTとIkigaiの組み合わせによる洞察生成サービス
class CombinedInsightGenerator {
  /// SDTとIkigaiの組み合わせパターンからの洞察生成
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

  /// Big5とSDTの組み合わせによる詳細な特性分析
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
}