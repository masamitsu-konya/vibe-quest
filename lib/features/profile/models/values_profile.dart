/// 価値観プロファイル
///
/// スワイプ回答から生成される、その人の価値観の数値表現。
/// マッチングの類似度計算とプロファイル画面の表示に使う。
///
/// ベクトル構造（23次元、順序固定）:
/// - [0..12] スコア次元: 右スワイプした質問の各スコア平均
///   growth, sdtAutonomy, sdtCompetence, sdtRelatedness,
///   ikigaiLove, ikigaiGoodAt, ikigaiWorldNeeds, ikigaiPaidFor,
///   big5Openness, big5Conscientiousness, big5Extraversion,
///   big5Agreeableness, big5Neuroticism
/// - [13..26] カテゴリ親和度: カテゴリごとの右スワイプ率
///   health, career, hobby, learning, relationship, lifestyle,
///   finance, creativity, sports, travel, adventure, service,
///   mindfulness, entertainment
class ValuesProfile {
  /// ベクトルのスキーマバージョン（次元構成を変えたら上げる）
  static const int currentVersion = 1;

  static const List<String> scoreDimensions = [
    'growth',
    'sdt_autonomy',
    'sdt_competence',
    'sdt_relatedness',
    'ikigai_love',
    'ikigai_good_at',
    'ikigai_world_needs',
    'ikigai_paid_for',
    'big5_openness',
    'big5_conscientiousness',
    'big5_extraversion',
    'big5_agreeableness',
    'big5_neuroticism',
  ];

  static const List<String> categories = [
    'health',
    'career',
    'hobby',
    'learning',
    'relationship',
    'lifestyle',
    'finance',
    'creativity',
    'sports',
    'travel',
    'adventure',
    'service',
    'mindfulness',
    'entertainment',
  ];

  static int get dimensionCount =>
      scoreDimensions.length + categories.length;

  final int version;
  final List<double> vector;
  final int answeredCount;
  final int excitedCount;
  final DateTime updatedAt;

  const ValuesProfile({
    required this.version,
    required this.vector,
    required this.answeredCount,
    required this.excitedCount,
    required this.updatedAt,
  });

  /// スコア次元の値を名前で取得
  double scoreOf(String dimension) {
    final index = scoreDimensions.indexOf(dimension);
    if (index < 0) {
      throw ArgumentError('未知のスコア次元: $dimension');
    }
    return vector[index];
  }

  /// カテゴリ親和度を名前で取得
  double affinityOf(String category) {
    final index = categories.indexOf(category);
    if (index < 0) {
      throw ArgumentError('未知のカテゴリ: $category');
    }
    return vector[scoreDimensions.length + index];
  }

  factory ValuesProfile.fromJson(Map<String, dynamic> json) {
    return ValuesProfile(
      version: json['version'] as int,
      vector: (json['vector'] as List<dynamic>)
          .map((e) => (e as num).toDouble())
          .toList(),
      answeredCount: json['answered_count'] as int,
      excitedCount: json['excited_count'] as int,
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'version': version,
      'vector': vector,
      'answered_count': answeredCount,
      'excited_count': excitedCount,
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
