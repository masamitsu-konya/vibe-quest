/// 分析結果のモデル
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
      personalityType: 'harmonizer',
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
      insights: ['まだ十分なデータがありません。もう少しスワイプを続けてください。'],
      recommendations: ['様々な質問に答えて、自己理解を深めましょう。'],
      responseCount: 0,
      excitedCount: 0,
    );
  }
}

/// カテゴリー分析結果
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

/// 動機づけプロファイル
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

/// 時系列分析
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