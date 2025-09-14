import '../../shared/models/question.dart';
import 'models/personality_type.dart';
import 'models/enhanced_models.dart';
import 'constants/personality_constants.dart';
import 'services/category_analyzer.dart';
import 'services/motivation_analyzer.dart';
import 'services/growth_stage_analyzer.dart';
import 'services/time_series_analyzer.dart';
import 'insights/combined_insight_generator.dart';

/// リファクタリング版の拡張パーソナリティ分析クラス
class EnhancedPersonalityAnalyzer {
  // パーソナリティプロファイルへの参照
  static const personalityProfiles = PersonalityConstants.personalityProfiles;

  /// 拡張分析の実行
  static Map<String, dynamic> performEnhancedAnalysis(
    List<Map<String, dynamic>> responses,
    Map<String, double> sdtScores,
    Map<String, double> ikigaiScores,
    Map<String, double> big5Scores,
  ) {
    // ワクワクした質問の抽出
    final excitedResponses = responses.where((r) => r['is_excited'] == true).toList();
    final questions = excitedResponses.map((r) => r['question'] as Question).toList();
    final excitementRate = excitedResponses.length / responses.length;

    // 各分析の実行（サービスに委譲）
    final categoryAnalysis = CategoryAnalyzer.analyzeCategoryPreferences(responses);
    final motivationProfile = MotivationAnalyzer.generateMotivationProfile(questions);
    final growthStage = GrowthStageAnalyzer.determineGrowthStage(
      responses.length,
      excitementRate,
      {...sdtScores, ...ikigaiScores, ...big5Scores},
    );
    final timeSeriesAnalysis = TimeSeriesAnalyzer.analyzeTemporalPatterns(responses);

    // 組み合わせ洞察の生成（ジェネレーターに委譲）
    final combinedInsights = CombinedInsightGenerator.generateCombinedInsight(
      sdtScores,
      ikigaiScores,
    );
    final detailedTraits = CombinedInsightGenerator.generateDetailedTraits(
      big5Scores,
      sdtScores,
    );

    return {
      'categoryAnalysis': categoryAnalysis,
      'motivationProfile': motivationProfile,
      'growthStage': growthStage,
      'timeSeriesAnalysis': timeSeriesAnalysis,
      'combinedInsights': combinedInsights,
      'detailedTraits': detailedTraits,
    };
  }

  /// サブタイプの判定
  static PersonalityProfile? determineSubtype(
    String mainType,
    Map<String, double> sdtScores,
    Map<String, double> ikigaiScores,
    Map<String, double> big5Scores,
  ) {
    final openness = big5Scores['openness']!;
    final conscientiousness = big5Scores['conscientiousness']!;
    final extraversion = big5Scores['extraversion']!;
    final agreeableness = big5Scores['agreeableness']!;

    final autonomy = sdtScores['autonomy']!;
    final competence = sdtScores['competence']!;
    final relatedness = sdtScores['relatedness']!;

    final love = ikigaiScores['love']!;
    final goodAt = ikigaiScores['goodAt']!;
    final worldNeeds = ikigaiScores['worldNeeds']!;

    // メインタイプに基づくサブタイプの判定
    switch (mainType) {
      case 'explorer':
        if (autonomy > 0.8 && openness > 0.8) {
          return personalityProfiles['explorer_pioneer'];
        } else if (competence > 0.8 && conscientiousness > 0.7) {
          return personalityProfiles['explorer_scholar'];
        } else {
          return personalityProfiles['explorer_wanderer'];
        }

      case 'creator':
        if (love > 0.8 && openness > 0.8) {
          return personalityProfiles['creator_artist'];
        } else if (competence > 0.8 && worldNeeds > 0.7) {
          return personalityProfiles['creator_innovator'];
        } else {
          return personalityProfiles['creator_builder'];
        }

      case 'supporter':
        if (relatedness > 0.8 && competence > 0.7) {
          return personalityProfiles['supporter_mentor'];
        } else if (agreeableness > 0.8 && love > 0.7) {
          return personalityProfiles['supporter_healer'];
        } else {
          return personalityProfiles['supporter_connector'];
        }

      case 'challenger':
        if (competence > 0.8 && autonomy > 0.7) {
          return personalityProfiles['challenger_warrior'];
        } else if (conscientiousness > 0.8 && goodAt > 0.7) {
          return personalityProfiles['challenger_strategist'];
        } else {
          return personalityProfiles['challenger_competitor'];
        }

      case 'harmonizer':
        if (agreeableness > 0.8 && relatedness > 0.7) {
          return personalityProfiles['harmonizer_mediator'];
        } else if (openness > 0.7 && autonomy > 0.7) {
          return personalityProfiles['harmonizer_philosopher'];
        } else {
          return personalityProfiles['harmonizer_gardener'];
        }

      default:
        return null;
    }
  }
}