/// パーソナリティタイプ判定サービス
class PersonalityDeterminer {
  /// パーソナリティタイプを判定
  static String determinePersonalityType(
    Map<String, double> sdtScores,
    Map<String, double> ikigaiScores,
    Map<String, double> big5Scores,
    double motivationScore,
  ) {
    final openness = big5Scores['openness']!;
    final conscientiousness = big5Scores['conscientiousness']!;
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

  /// 価値観を分析
  static List<String> analyzeValues(
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
}