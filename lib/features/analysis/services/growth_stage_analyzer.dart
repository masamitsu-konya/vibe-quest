/// 成長段階分析サービス
class GrowthStageAnalyzer {
  /// 成長段階の判定
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
}