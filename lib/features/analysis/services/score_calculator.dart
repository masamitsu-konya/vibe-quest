import '../../../shared/models/question.dart';

/// スコア計算サービス
class ScoreCalculator {
  /// SDTスコアを計算
  static Map<String, double> calculateSDTScores(List<Question> questions) {
    if (questions.isEmpty) {
      return {'autonomy': 0.5, 'competence': 0.5, 'relatedness': 0.5};
    }

    double autonomySum = 0;
    double competenceSum = 0;
    double relatednessSum = 0;

    for (final question in questions) {
      autonomySum += question.sdtAutonomy;
      competenceSum += question.sdtCompetence;
      relatednessSum += question.sdtRelatedness;
    }

    final count = questions.length.toDouble();
    return {
      'autonomy': autonomySum / count,
      'competence': competenceSum / count,
      'relatedness': relatednessSum / count,
    };
  }

  /// 生きがいスコアを計算
  static Map<String, double> calculateIkigaiScores(List<Question> questions) {
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

    for (final question in questions) {
      loveSum += question.ikigaiLove;
      goodAtSum += question.ikigaiGoodAt;
      worldNeedsSum += question.ikigaiWorldNeeds;
      paidForSum += question.ikigaiPaidFor;
    }

    final count = questions.length.toDouble();
    return {
      'love': loveSum / count,
      'goodAt': goodAtSum / count,
      'worldNeeds': worldNeedsSum / count,
      'paidFor': paidForSum / count,
    };
  }

  /// ビッグファイブスコアを計算
  static Map<String, double> calculateBig5Scores(List<Question> questions) {
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

    for (final question in questions) {
      opennessSum += question.big5Openness;
      conscientiousnessSum += question.big5Conscientiousness;
      extraversionSum += question.big5Extraversion;
      agreeablenessSum += question.big5Agreeableness;
      neuroticismSum += question.big5Neuroticism;
    }

    final count = questions.length.toDouble();
    return {
      'openness': opennessSum / count,
      'conscientiousness': conscientiousnessSum / count,
      'extraversion': extraversionSum / count,
      'agreeableness': agreeablenessSum / count,
      'neuroticism': neuroticismSum / count,
    };
  }

  /// モチベーションスコアを計算
  static double calculateMotivationScore(List<Question> questions) {
    if (questions.isEmpty) return 0.5;

    double intrinsicCount = 0;
    double mixedCount = 0;

    for (final question in questions) {
      if (question.motivationType == 'intrinsic') {
        intrinsicCount++;
      } else if (question.motivationType == 'mixed') {
        mixedCount++;
      }
    }

    final total = questions.length.toDouble();
    return (intrinsicCount + mixedCount * 0.5) / total;
  }
}