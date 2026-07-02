// 質問データベースの整合性テスト
//
// アプリ内に保持している質問データ（QuestionsData）が
// スワイプ分析・価値観プロファイル生成の前提を満たしていることを検証する。

import 'package:flutter_test/flutter_test.dart';

import 'package:vibe_quest/data/questions_data.dart';

void main() {
  group('QuestionsData', () {
    test('質問が十分な数存在する', () {
      expect(QuestionsData.allQuestions.length, greaterThanOrEqualTo(100));
    });

    test('質問IDが一意である', () {
      final ids = QuestionsData.allQuestions.map((q) => q.id).toList();
      expect(ids.toSet().length, ids.length);
    });

    test('全質問が本文とカテゴリを持つ', () {
      for (final q in QuestionsData.allQuestions) {
        expect(q.text, isNotEmpty, reason: 'id=${q.id} の本文が空');
        expect(q.category, isNotEmpty, reason: 'id=${q.id} のカテゴリが空');
      }
    });

    test('スコア系フィールドが0.0〜1.0の範囲に収まる', () {
      for (final q in QuestionsData.allQuestions) {
        final scores = {
          'growthScore': q.growthScore,
          'sdtAutonomy': q.sdtAutonomy,
          'sdtCompetence': q.sdtCompetence,
          'sdtRelatedness': q.sdtRelatedness,
          'ikigaiLove': q.ikigaiLove,
          'ikigaiGoodAt': q.ikigaiGoodAt,
          'ikigaiWorldNeeds': q.ikigaiWorldNeeds,
          'ikigaiPaidFor': q.ikigaiPaidFor,
          'big5Openness': q.big5Openness,
          'big5Conscientiousness': q.big5Conscientiousness,
          'big5Extraversion': q.big5Extraversion,
          'big5Agreeableness': q.big5Agreeableness,
          'big5Neuroticism': q.big5Neuroticism,
        };
        scores.forEach((name, value) {
          expect(value, inInclusiveRange(0.0, 1.0),
              reason: 'id=${q.id} の $name=$value が範囲外');
        });
      }
    });
  });
}
