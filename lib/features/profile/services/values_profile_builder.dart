import 'dart:math';

import '../../../shared/models/question.dart';
import '../../../shared/models/swipe_response.dart';
import '../models/values_profile.dart';

/// スワイプ回答から価値観プロファイルを生成する
class ValuesProfileBuilder {
  /// データが無い次元に入れる中立値
  static const double neutral = 0.5;

  /// 回答リストと質問ルックアップからプロファイルを構築する
  ///
  /// [questionById] に存在しない questionId の回答は無視する
  /// （質問データの改訂で消えた質問への耐性）。
  static ValuesProfile build(
    List<SwipeResponse> responses,
    Map<String, Question> questionById, {
    DateTime? now,
  }) {
    final valid = responses
        .where((r) => questionById.containsKey(r.questionId))
        .toList();

    final excited = valid
        .where((r) => r.isExcited)
        .map((r) => questionById[r.questionId]!)
        .toList();

    // [0..12] スコア次元: 右スワイプした質問の平均
    final scoreVector = _averageScores(excited);

    // [13..22] カテゴリ親和度: カテゴリごとの右スワイプ率
    final affinityVector = _categoryAffinities(valid, questionById);

    return ValuesProfile(
      version: ValuesProfile.currentVersion,
      vector: [...scoreVector, ...affinityVector],
      answeredCount: valid.length,
      excitedCount: excited.length,
      updatedAt: now ?? DateTime.now(),
    );
  }

  /// 2つのプロファイルのコサイン類似度（0.0〜1.0）
  ///
  /// ベクトルは全次元 0〜1 のため内積は非負になり、類似度も 0〜1 に収まる。
  /// Supabase 側の SQL 関数（マッチング RPC）と同一のロジックであること。
  static double cosineSimilarity(ValuesProfile a, ValuesProfile b) {
    if (a.vector.length != b.vector.length) {
      throw ArgumentError(
          'ベクトル次元が不一致: ${a.vector.length} vs ${b.vector.length}');
    }

    double dot = 0;
    double normA = 0;
    double normB = 0;
    for (var i = 0; i < a.vector.length; i++) {
      dot += a.vector[i] * b.vector[i];
      normA += a.vector[i] * a.vector[i];
      normB += b.vector[i] * b.vector[i];
    }

    if (normA == 0 || normB == 0) {
      return 0;
    }
    return dot / (sqrt(normA) * sqrt(normB));
  }

  static List<double> _averageScores(List<Question> excited) {
    if (excited.isEmpty) {
      return List.filled(ValuesProfile.scoreDimensions.length, neutral);
    }

    final count = excited.length.toDouble();
    final sums = <String, double>{};
    for (final q in excited) {
      final scores = _scoresOf(q);
      scores.forEach((dim, value) {
        sums[dim] = (sums[dim] ?? 0) + value;
      });
    }

    return ValuesProfile.scoreDimensions
        .map((dim) => (sums[dim] ?? 0) / count)
        .toList();
  }

  static List<double> _categoryAffinities(
    List<SwipeResponse> valid,
    Map<String, Question> questionById,
  ) {
    final answered = <String, int>{};
    final excited = <String, int>{};

    for (final r in valid) {
      final category = questionById[r.questionId]!.category;
      answered[category] = (answered[category] ?? 0) + 1;
      if (r.isExcited) {
        excited[category] = (excited[category] ?? 0) + 1;
      }
    }

    return ValuesProfile.categories.map((category) {
      final total = answered[category] ?? 0;
      if (total == 0) {
        return neutral;
      }
      return (excited[category] ?? 0) / total;
    }).toList();
  }

  static Map<String, double> _scoresOf(Question q) {
    return {
      'growth': q.growthScore,
      'sdt_autonomy': q.sdtAutonomy,
      'sdt_competence': q.sdtCompetence,
      'sdt_relatedness': q.sdtRelatedness,
      'ikigai_love': q.ikigaiLove,
      'ikigai_good_at': q.ikigaiGoodAt,
      'ikigai_world_needs': q.ikigaiWorldNeeds,
      'ikigai_paid_for': q.ikigaiPaidFor,
      'big5_openness': q.big5Openness,
      'big5_conscientiousness': q.big5Conscientiousness,
      'big5_extraversion': q.big5Extraversion,
      'big5_agreeableness': q.big5Agreeableness,
      'big5_neuroticism': q.big5Neuroticism,
    };
  }
}
