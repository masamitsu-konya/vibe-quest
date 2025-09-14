import '../../../shared/models/question.dart';
import '../models/enhanced_models.dart';

/// 動機づけプロファイル分析サービス
class MotivationAnalyzer {
  /// 動機づけプロファイルの生成
  static MotivationProfile generateMotivationProfile(
    List<Question> questions,
  ) {
    int intrinsicCount = 0;
    int extrinsicCount = 0;
    int mixedCount = 0;

    for (final question in questions) {
      switch (question.motivationType) {
        case 'intrinsic':
          intrinsicCount++;
          break;
        case 'extrinsic':
          extrinsicCount++;
          break;
        case 'mixed':
          mixedCount++;
          break;
      }
    }

    final total = questions.length;
    if (total == 0) {
      return const MotivationProfile(
        type: 'balanced',
        description: 'バランスの取れた動機づけ',
        advice: '内発的・外発的動機のバランスを保ちましょう',
      );
    }

    final intrinsicRate = intrinsicCount / total;
    final extrinsicRate = extrinsicCount / total;
    final mixedRate = mixedCount / total;

    if (intrinsicRate > 0.6) {
      return const MotivationProfile(
        type: 'intrinsic_dominant',
        description: '内発的動機優位：活動そのものに喜びを見出すタイプ',
        advice: '情熱に従うことで最高のパフォーマンスを発揮できます。外的報酬に惑わされず、内なる声に耳を傾けましょう。',
      );
    } else if (extrinsicRate > 0.6) {
      return const MotivationProfile(
        type: 'extrinsic_dominant',
        description: '外発的動機優位：明確な目標と報酬を求めるタイプ',
        advice: '具体的な目標設定と達成度の可視化が重要です。小さな成功を積み重ねることでモチベーションを維持できます。',
      );
    } else if (mixedRate > 0.4) {
      return const MotivationProfile(
        type: 'hybrid',
        description: 'ハイブリッド型：状況に応じて動機を使い分けるタイプ',
        advice: '柔軟な動機づけスタイルが強みです。状況に応じて内発的・外発的動機を使い分けることで、持続的な成長が可能です。',
      );
    } else {
      return const MotivationProfile(
        type: 'balanced',
        description: 'バランス型：多様な動機源から力を得るタイプ',
        advice: '複数の動機源を持つことで、安定した成長が可能です。様々な角度から自己を見つめ、総合的な発展を目指しましょう。',
      );
    }
  }
}