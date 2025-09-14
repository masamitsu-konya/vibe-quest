import '../../../shared/models/question.dart';
import '../models/analysis_result.dart';

/// カテゴリー別分析サービス
class CategoryAnalyzer {
  /// カテゴリー別の詳細分析
  static Map<String, CategoryAnalysis> analyzeCategoryPreferences(
    List<Map<String, dynamic>> responses,
  ) {
    final categoryStats = <String, CategoryAnalysis>{};
    final excitedByCategory = <String, List<Question>>{};

    for (final response in responses) {
      final question = response['question'] as Question;
      final isExcited = response['is_excited'] as bool;

      if (isExcited) {
        excitedByCategory.putIfAbsent(question.category, () => []).add(question);
      }
    }

    for (final entry in excitedByCategory.entries) {
      final category = entry.key;
      final questions = entry.value;

      // カテゴリー別の傾向を分析
      final avgGrowthScore = questions.isEmpty
          ? 0.0
          : questions.map((q) => q.growthScore).reduce((a, b) => a + b) / questions.length;

      String tendency;
      String recommendation;

      switch (category) {
        case 'health':
          if (avgGrowthScore > 0.7) {
            tendency = '身体的・精神的な健康への高い意識を持っています';
            recommendation = '定期的な運動習慣とマインドフルネスの実践を組み合わせると効果的です';
          } else {
            tendency = '健康への関心が見られます';
            recommendation = '小さな習慣から始めて、徐々に健康的なライフスタイルを構築しましょう';
          }
          break;

        case 'career':
          if (avgGrowthScore > 0.7) {
            tendency = 'キャリア発展への強い意欲があります';
            recommendation = 'スキルアップと人脈構築を並行して進めることが成功への鍵です';
          } else {
            tendency = 'キャリアについて探索中です';
            recommendation = '自分の強みと興味を明確にすることから始めましょう';
          }
          break;

        case 'creativity':
          if (avgGrowthScore > 0.7) {
            tendency = '創造的表現への強い欲求があります';
            recommendation = '日常的に創作活動の時間を確保し、作品を共有する場を持ちましょう';
          } else {
            tendency = '創造性への興味が芽生えています';
            recommendation = '気軽に始められる創作活動から試してみましょう';
          }
          break;

        case 'relationship':
          if (avgGrowthScore > 0.7) {
            tendency = '人間関係を通じた成長を重視しています';
            recommendation = '深い対話の機会を増やし、相互理解を深めることが充実感につながります';
          } else {
            tendency = '人間関係の価値を認識しています';
            recommendation = '自分に合った人間関係のスタイルを見つけていきましょう';
          }
          break;

        case 'learning':
          if (avgGrowthScore > 0.7) {
            tendency = '知的探求心が非常に強いです';
            recommendation = '体系的な学習計画を立て、学んだことを実践する機会を作りましょう';
          } else {
            tendency = '学習への関心が見られます';
            recommendation = '興味のある分野から少しずつ学習を始めてみましょう';
          }
          break;

        case 'adventure':
          if (avgGrowthScore > 0.7) {
            tendency = '新しい挑戦への意欲が高いです';
            recommendation = '計算されたリスクテイクと振り返りの習慣が成長を加速させます';
          } else {
            tendency = '冒険心が芽生えています';
            recommendation = '小さな挑戦から始めて、徐々に快適圏を広げていきましょう';
          }
          break;

        case 'service':
          if (avgGrowthScore > 0.7) {
            tendency = '社会貢献への強い関心があります';
            recommendation = '自分のスキルを活かした持続可能な貢献方法を見つけることが重要です';
          } else {
            tendency = '社会貢献への意識が育っています';
            recommendation = '身近なところから始められる貢献活動を探してみましょう';
          }
          break;

        case 'mindfulness':
          if (avgGrowthScore > 0.7) {
            tendency = '内面の平和と自己認識を大切にしています';
            recommendation = '瞑想や内省の時間を日課にすることで、より深い洞察が得られます';
          } else {
            tendency = 'マインドフルネスへの関心があります';
            recommendation = '簡単な呼吸法から始めて、徐々に実践を深めていきましょう';
          }
          break;

        case 'entertainment':
          if (avgGrowthScore > 0.7) {
            tendency = '楽しみと刺激を通じた充実を求めています';
            recommendation = '娯楽と成長を組み合わせた活動を選ぶことで、両方の価値を得られます';
          } else {
            tendency = 'エンターテインメントを楽しんでいます';
            recommendation = '新しいジャンルにも挑戦して、楽しみの幅を広げてみましょう';
          }
          break;

        case 'hobby':
          if (avgGrowthScore > 0.7) {
            tendency = '趣味を通じた自己表現を重視しています';
            recommendation = '趣味を深めてコミュニティに参加することで、新しい可能性が開けます';
          } else {
            tendency = '趣味への関心が見られます';
            recommendation = '様々な趣味を試して、自分に合うものを見つけていきましょう';
          }
          break;

        default:
          tendency = 'バランスの取れた関心を持っています';
          recommendation = '興味の幅を保ちながら、特に惹かれる分野を深めていきましょう';
      }

      categoryStats[category] = CategoryAnalysis(
        category: category,
        excitementRate: questions.length.toDouble() / responses.length,
        averageGrowthScore: avgGrowthScore,
        tendency: tendency,
        recommendation: recommendation,
      );
    }

    return categoryStats;
  }
}