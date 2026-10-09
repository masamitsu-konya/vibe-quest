/// 行動提案モデル
class ActionRecommendation {
  final String id;
  final String title;
  final String description;
  final ActionCategory category;
  final ActionTimeframe timeframe;
  final ActionDifficulty difficulty;
  final List<String> tags;
  final double relevanceScore; // 関連性スコア（0.0-1.0）
  final String emoji;

  const ActionRecommendation({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.timeframe,
    required this.difficulty,
    required this.tags,
    required this.relevanceScore,
    required this.emoji,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category.name,
      'timeframe': timeframe.name,
      'difficulty': difficulty.name,
      'tags': tags,
      'relevanceScore': relevanceScore,
      'emoji': emoji,
    };
  }
}

/// 行動カテゴリ
enum ActionCategory {
  health('健康・フィットネス', '💪'),
  career('キャリア・仕事', '💼'),
  creativity('クリエイティブ', '🎨'),
  learning('学習・自己啓発', '📚'),
  relationship('人間関係', '🤝'),
  lifestyle('ライフスタイル', '🌟'),
  finance('金融・投資', '💰'),
  travel('旅行・冒険', '✈️'),
  hobby('趣味・娯楽', '🎮'),
  sports('スポーツ', '⚽');

  final String label;
  final String emoji;
  const ActionCategory(this.label, this.emoji);
}

/// 行動の時間枠
enum ActionTimeframe {
  daily('毎日（5-15分）', '日常習慣'),
  weekly('週1回（1-2時間）', '週末活動'),
  monthly('月1回（半日）', '月次チャレンジ'),
  shortTerm('3ヶ月以内', '短期目標'),
  mediumTerm('1年以内', '中期目標'),
  longTerm('1年以上', '長期目標');

  final String label;
  final String description;
  const ActionTimeframe(this.label, this.description);
}

/// 行動の難易度
enum ActionDifficulty {
  easy('簡単', '今すぐ始められる'),
  medium('普通', '少し準備が必要'),
  hard('難しい', 'しっかりとした計画が必要');

  final String label;
  final String description;
  const ActionDifficulty(this.label, this.description);
}

/// 習慣化提案
class HabitSuggestion {
  final String id;
  final String title;
  final String trigger; // トリガー（いつ行うか）
  final String routine; // ルーティン（何をするか）
  final String reward; // 報酬（どんな良いことがあるか）
  final ActionCategory category;
  final int durationMinutes;
  final String emoji;

  const HabitSuggestion({
    required this.id,
    required this.title,
    required this.trigger,
    required this.routine,
    required this.reward,
    required this.category,
    required this.durationMinutes,
    required this.emoji,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'trigger': trigger,
      'routine': routine,
      'reward': reward,
      'category': category.name,
      'durationMinutes': durationMinutes,
      'emoji': emoji,
    };
  }
}

/// やりたいことリスト
class WantToDoList {
  final List<ActionRecommendation> immediateActions; // 今すぐできること
  final List<ActionRecommendation> shortTermGoals; // 短期目標
  final List<ActionRecommendation> mediumTermGoals; // 中期目標
  final List<ActionRecommendation> longTermGoals; // 長期目標
  final List<HabitSuggestion> dailyHabits; // 毎日の習慣
  final List<HabitSuggestion> weeklyHabits; // 週1の習慣
  final DateTime generatedAt;

  const WantToDoList({
    required this.immediateActions,
    required this.shortTermGoals,
    required this.mediumTermGoals,
    required this.longTermGoals,
    required this.dailyHabits,
    required this.weeklyHabits,
    required this.generatedAt,
  });

  int get totalCount =>
      immediateActions.length +
      shortTermGoals.length +
      mediumTermGoals.length +
      longTermGoals.length +
      dailyHabits.length +
      weeklyHabits.length;
}