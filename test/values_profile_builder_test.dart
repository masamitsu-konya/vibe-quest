import 'package:flutter_test/flutter_test.dart';

import 'package:vibe_quest/features/profile/models/values_profile.dart';
import 'package:vibe_quest/features/profile/services/values_profile_builder.dart';
import 'package:vibe_quest/shared/models/question.dart';
import 'package:vibe_quest/shared/models/swipe_response.dart';

Question _question(
  String id,
  String category, {
  double growth = 0.5,
  double autonomy = 0.5,
  double love = 0.5,
}) {
  return Question(
    id: id,
    text: 'テスト質問 $id',
    category: category,
    emoji: '⭐',
    growthScore: growth,
    tags: const [],
    sdtAutonomy: autonomy,
    ikigaiLove: love,
  );
}

SwipeResponse _response(String questionId, bool isExcited) {
  return SwipeResponse(
    questionId: questionId,
    isExcited: isExcited,
    timestamp: DateTime(2026, 7, 3),
  );
}

void main() {
  group('ValuesProfileBuilder.build', () {
    test('回答ゼロなら全次元が中立値になる', () {
      final profile = ValuesProfileBuilder.build(const [], const {});

      expect(profile.vector.length, ValuesProfile.dimensionCount);
      expect(profile.answeredCount, 0);
      expect(profile.excitedCount, 0);
      for (final v in profile.vector) {
        expect(v, ValuesProfileBuilder.neutral);
      }
    });

    test('右スワイプした質問のスコア平均がベクトルに反映される', () {
      final questions = {
        'q1': _question('q1', 'health', growth: 1.0, autonomy: 0.8),
        'q2': _question('q2', 'health', growth: 0.5, autonomy: 0.4),
        'q3': _question('q3', 'career', growth: 0.0, autonomy: 0.0),
      };
      final responses = [
        _response('q1', true),
        _response('q2', true),
        _response('q3', false), // 左スワイプはスコア平均に入らない
      ];

      final profile = ValuesProfileBuilder.build(responses, questions);

      expect(profile.scoreOf('growth'), closeTo(0.75, 1e-9));
      expect(profile.scoreOf('sdt_autonomy'), closeTo(0.6, 1e-9));
      expect(profile.answeredCount, 3);
      expect(profile.excitedCount, 2);
    });

    test('カテゴリ親和度は右スワイプ率、未回答カテゴリは中立値', () {
      final questions = {
        'q1': _question('q1', 'health'),
        'q2': _question('q2', 'health'),
        'q3': _question('q3', 'career'),
      };
      final responses = [
        _response('q1', true),
        _response('q2', false),
        _response('q3', false),
      ];

      final profile = ValuesProfileBuilder.build(responses, questions);

      expect(profile.affinityOf('health'), closeTo(0.5, 1e-9));
      expect(profile.affinityOf('career'), closeTo(0.0, 1e-9));
      expect(profile.affinityOf('travel'), ValuesProfileBuilder.neutral);
    });

    test('存在しない質問IDの回答は無視される', () {
      final questions = {'q1': _question('q1', 'health')};
      final responses = [
        _response('q1', true),
        _response('deleted-question', true),
      ];

      final profile = ValuesProfileBuilder.build(responses, questions);

      expect(profile.answeredCount, 1);
    });
  });

  group('ValuesProfileBuilder.cosineSimilarity', () {
    test('同一プロファイルは類似度1.0', () {
      final questions = {
        'q1': _question('q1', 'health', growth: 0.9, love: 0.8),
      };
      final profile =
          ValuesProfileBuilder.build([_response('q1', true)], questions);

      expect(
        ValuesProfileBuilder.cosineSimilarity(profile, profile),
        closeTo(1.0, 1e-9),
      );
    });

    test('異なるプロファイルの類似度は0.0〜1.0に収まる', () {
      final questionsA = {
        'q1': _question('q1', 'health', growth: 1.0, autonomy: 1.0),
      };
      final questionsB = {
        'q2': _question('q2', 'finance', growth: 0.0, autonomy: 0.0),
      };
      final a = ValuesProfileBuilder.build([_response('q1', true)], questionsA);
      final b = ValuesProfileBuilder.build([_response('q2', true)], questionsB);

      final similarity = ValuesProfileBuilder.cosineSimilarity(a, b);
      expect(similarity, inInclusiveRange(0.0, 1.0));
    });

    test('次元数が違うベクトルはエラー', () {
      final profile = ValuesProfileBuilder.build(const [], const {});
      final broken = ValuesProfile(
        version: 1,
        vector: const [0.5, 0.5],
        answeredCount: 0,
        excitedCount: 0,
        updatedAt: DateTime(2026, 7, 3),
      );

      expect(
        () => ValuesProfileBuilder.cosineSimilarity(profile, broken),
        throwsArgumentError,
      );
    });
  });

  group('ValuesProfile JSON round-trip', () {
    test('toJson → fromJson で値が保存される', () {
      final questions = {
        'q1': _question('q1', 'health', growth: 0.9),
      };
      final original =
          ValuesProfileBuilder.build([_response('q1', true)], questions);

      final restored = ValuesProfile.fromJson(original.toJson());

      expect(restored.version, original.version);
      expect(restored.vector, original.vector);
      expect(restored.answeredCount, original.answeredCount);
      expect(restored.excitedCount, original.excitedCount);
    });
  });
}
