/// 拡張分析用のモデル定義

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