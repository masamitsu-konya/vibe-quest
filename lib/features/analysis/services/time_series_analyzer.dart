import '../models/enhanced_models.dart';

/// 時系列パターン分析サービス
class TimeSeriesAnalyzer {
  /// 時系列分析（スワイプパターンの変化）
  static TimeSeriesAnalysis analyzeTemporalPatterns(
    List<Map<String, dynamic>> responses,
  ) {
    if (responses.length < 20) {
      return const TimeSeriesAnalysis(
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
      return const TimeSeriesAnalysis(
        trend: 'increasing',
        description: '興味の幅が広がっている',
        insight: 'より多くのことに関心を持つようになっています。新しい可能性に開かれた状態です。',
      );
    } else if (difference < -0.2) {
      return const TimeSeriesAnalysis(
        trend: 'focusing',
        description: '興味が絞られてきている',
        insight: '本当に重要なことが明確になってきています。選択と集中の段階に入っています。',
      );
    } else {
      return const TimeSeriesAnalysis(
        trend: 'stable',
        description: '安定した興味パターン',
        insight: '一貫した価値観を持っています。自己理解が深まっている証拠です。',
      );
    }
  }
}