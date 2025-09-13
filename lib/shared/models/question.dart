class Question {
  final String id;
  final String text;
  final String category;
  final double growthScore;
  final List<String> tags;
  final String? imageUrl;

  // Self-Determination Theory (自己決定理論)
  final double sdtAutonomy;     // 自律性
  final double sdtCompetence;   // 有能感
  final double sdtRelatedness;  // 関係性

  // ikigai（生きがい）の4要素
  final double ikigaiLove;       // 好きなこと
  final double ikigaiGoodAt;     // 得意なこと
  final double ikigaiWorldNeeds; // 世界が求めること
  final double ikigaiPaidFor;    // お金になること

  // 動機付けタイプ
  final String motivationType;   // intrinsic, extrinsic, mixed

  // Big Five パーソナリティ特性
  final double big5Openness;          // 開放性
  final double big5Conscientiousness; // 誠実性
  final double big5Extraversion;      // 外向性
  final double big5Agreeableness;     // 協調性
  final double big5Neuroticism;       // 神経症傾向

  const Question({
    required this.id,
    required this.text,
    required this.category,
    required this.growthScore,
    required this.tags,
    this.imageUrl,
    this.sdtAutonomy = 0.5,
    this.sdtCompetence = 0.5,
    this.sdtRelatedness = 0.5,
    this.ikigaiLove = 0.5,
    this.ikigaiGoodAt = 0.5,
    this.ikigaiWorldNeeds = 0.5,
    this.ikigaiPaidFor = 0.5,
    this.motivationType = 'mixed',
    this.big5Openness = 0.5,
    this.big5Conscientiousness = 0.5,
    this.big5Extraversion = 0.5,
    this.big5Agreeableness = 0.5,
    this.big5Neuroticism = 0.5,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id'] as String,
      text: json['text'] as String,
      category: json['category'] as String,
      growthScore: (json['growth_score'] as num).toDouble(),
      tags: List<String>.from(json['tags'] ?? []),
      imageUrl: json['image_url'] as String?,
      sdtAutonomy: (json['sdt_autonomy'] as num?)?.toDouble() ?? 0.5,
      sdtCompetence: (json['sdt_competence'] as num?)?.toDouble() ?? 0.5,
      sdtRelatedness: (json['sdt_relatedness'] as num?)?.toDouble() ?? 0.5,
      ikigaiLove: (json['ikigai_love'] as num?)?.toDouble() ?? 0.5,
      ikigaiGoodAt: (json['ikigai_good_at'] as num?)?.toDouble() ?? 0.5,
      ikigaiWorldNeeds: (json['ikigai_world_needs'] as num?)?.toDouble() ?? 0.5,
      ikigaiPaidFor: (json['ikigai_paid_for'] as num?)?.toDouble() ?? 0.5,
      motivationType: json['motivation_type'] as String? ?? 'mixed',
      big5Openness: (json['big5_openness'] as num?)?.toDouble() ?? 0.5,
      big5Conscientiousness: (json['big5_conscientiousness'] as num?)?.toDouble() ?? 0.5,
      big5Extraversion: (json['big5_extraversion'] as num?)?.toDouble() ?? 0.5,
      big5Agreeableness: (json['big5_agreeableness'] as num?)?.toDouble() ?? 0.5,
      big5Neuroticism: (json['big5_neuroticism'] as num?)?.toDouble() ?? 0.5,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'category': category,
      'growth_score': growthScore,
      'tags': tags,
      'image_url': imageUrl,
      'sdt_autonomy': sdtAutonomy,
      'sdt_competence': sdtCompetence,
      'sdt_relatedness': sdtRelatedness,
      'ikigai_love': ikigaiLove,
      'ikigai_good_at': ikigaiGoodAt,
      'ikigai_world_needs': ikigaiWorldNeeds,
      'ikigai_paid_for': ikigaiPaidFor,
      'motivation_type': motivationType,
      'big5_openness': big5Openness,
      'big5_conscientiousness': big5Conscientiousness,
      'big5_extraversion': big5Extraversion,
      'big5_agreeableness': big5Agreeableness,
      'big5_neuroticism': big5Neuroticism,
    };
  }
}

class QuestionCategory {
  static const String health = 'health';
  static const String career = 'career';
  static const String hobby = 'hobby';
  static const String learning = 'learning';
  static const String relationship = 'relationship';
  static const String lifestyle = 'lifestyle';
  static const String finance = 'finance';
  static const String creativity = 'creativity';
  static const String sports = 'sports';
  static const String travel = 'travel';
}