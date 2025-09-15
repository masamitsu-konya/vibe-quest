import '../../shared/models/question.dart';
import 'models/analysis_result.dart';
import 'models/personality_type.dart';
import 'constants/personality_constants.dart';
import 'services/score_calculator.dart';
import 'services/personality_determiner.dart';
import 'insights/insight_generator.dart';

/// リファクタリング版のパーソナリティ分析クラス
class PersonalityAnalyzer {
  // 定数への参照
  static const personalityTypes = PersonalityConstants.personalityTypes;

  /// 分析結果を生成
  static AnalysisResult analyze(List<Map<String, dynamic>> responses) {
    if (responses.isEmpty) {
      return AnalysisResult.empty();
    }

    // ワクワクした質問だけを抽出
    final excitedResponses = responses.where((r) => r['is_excited'] == true).toList();
    final questions = excitedResponses.map((r) => r['question'] as Question).toList();

    // 各スコアの計算（サービスに委譲）
    final sdtScores = ScoreCalculator.calculateSDTScores(questions);
    final ikigaiScores = ScoreCalculator.calculateIkigaiScores(questions);
    final big5Scores = ScoreCalculator.calculateBig5Scores(questions);
    final motivationScore = ScoreCalculator.calculateMotivationScore(questions);

    // パーソナリティタイプの判定（サービスに委譲）
    final personalityType = PersonalityDeterminer.determinePersonalityType(
      sdtScores,
      ikigaiScores,
      big5Scores,
      motivationScore,
    );

    // 価値観の分析（サービスに委譲）
    final values = PersonalityDeterminer.analyzeValues(sdtScores, ikigaiScores);

    // 洞察の生成（ジェネレーターに委譲）
    final insights = _generateAllInsights(
      personalityType,
      values,
      sdtScores,
      ikigaiScores,
      big5Scores,
      responses.length,
      excitedResponses.length,
    );

    // 推奨アクションの生成
    final recommendations = _generateRecommendations(personalityType, values);

    return AnalysisResult(
      personalityType: personalityType,
      primaryValues: values,
      sdtScores: sdtScores,
      ikigaiScores: ikigaiScores,
      big5Scores: big5Scores,
      motivationScore: motivationScore,
      insights: insights,
      recommendations: recommendations,
      responseCount: responses.length,
      excitedCount: excitedResponses.length,
    );
  }

  /// すべての洞察を統合
  static List<String> _generateAllInsights(
    String personalityType,
    List<String> values,
    Map<String, double> sdtScores,
    Map<String, double> ikigaiScores,
    Map<String, double> big5Scores,
    int totalResponses,
    int excitedCount,
  ) {
    final insights = <String>[];
    final excitementRate = excitedCount / totalResponses;

    // 基本傾向
    insights.add(InsightGenerator.generateBasicTendencyInsight(excitementRate));

    // SDTベース
    insights.addAll(InsightGenerator.generateSDTInsights(sdtScores));

    // 生きがいベース
    insights.addAll(InsightGenerator.generateIkigaiInsights(ikigaiScores));

    // ビッグファイブベース
    insights.addAll(InsightGenerator.generateBig5Insights(big5Scores));

    return insights;
  }

  /// 推奨アクションを生成
  static List<String> _generateRecommendations(
    String personalityType,
    List<String> values,
  ) {
    final recommendations = <String>[];

    // パーソナリティタイプに基づく推奨
    switch (personalityType) {
      case 'explorer':
        recommendations.add('新しいスキルや知識を学ぶオンラインコースを始めてみましょう');
        recommendations.add('異なる分野の本を月に2冊読む習慣をつけましょう');
        recommendations.add('未経験の活動やワークショップに参加してみましょう');
        break;
      case 'creator':
        recommendations.add('創作活動のための定期的な時間を確保しましょう');
        recommendations.add('作品を共有できるコミュニティに参加しましょう');
        recommendations.add('日記やスケッチなど、日常的な創造的表現を始めましょう');
        break;
      case 'supporter':
        recommendations.add('ボランティア活動やコミュニティ活動に参加しましょう');
        recommendations.add('メンタリングやコーチングのスキルを学びましょう');
        recommendations.add('チームプロジェクトでリーダーシップを発揮してみましょう');
        break;
      case 'challenger':
        recommendations.add('具体的で測定可能な目標を設定し、進捗を記録しましょう');
        recommendations.add('新しい挑戦や競技に参加してみましょう');
        recommendations.add('自己改善のためのフィードバックを積極的に求めましょう');
        break;
      case 'harmonizer':
        recommendations.add('瞑想やヨガなど、心身のバランスを整える習慣を作りましょう');
        recommendations.add('自然の中で過ごす時間を増やしましょう');
        recommendations.add('ジャーナリングで自己理解を深めましょう');
        break;
    }

    // 価値観に基づく推奨
    if (values.contains('自己決定と自由')) {
      recommendations.add('自分のペースで進められる個人プロジェクトを始めましょう');
    }
    if (values.contains('成長と達成')) {
      recommendations.add('スキルアップのための具体的な学習計画を立てましょう');
    }
    if (values.contains('つながりと協力')) {
      recommendations.add('志を同じくする仲間とのコミュニティを見つけましょう');
    }

    return recommendations;
  }
}