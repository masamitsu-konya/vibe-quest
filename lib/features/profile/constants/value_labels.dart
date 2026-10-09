/// 価値観次元・カテゴリの表示用ラベル定義
class ValueLabel {
  final String emoji;
  final String name;
  final String description;

  const ValueLabel({
    required this.emoji,
    required this.name,
    required this.description,
  });
}

/// スコア次元 → 価値観の言語化
const Map<String, ValueLabel> valueDimensionLabels = {
  'growth': ValueLabel(
    emoji: '🌱',
    name: '成長',
    description: '昨日の自分より前に進んでいる感覚を大切にする',
  ),
  'sdt_autonomy': ValueLabel(
    emoji: '🕊️',
    name: '自由と自律',
    description: '自分で選び、自分のやり方で進みたい',
  ),
  'sdt_competence': ValueLabel(
    emoji: '🎯',
    name: '熟達',
    description: 'できることが増えていく手応えを求める',
  ),
  'sdt_relatedness': ValueLabel(
    emoji: '🤝',
    name: 'つながり',
    description: '人との深い関係の中で生きたい',
  ),
  'ikigai_love': ValueLabel(
    emoji: '❤️',
    name: '好きの追求',
    description: '心から好きなことに時間を使いたい',
  ),
  'ikigai_good_at': ValueLabel(
    emoji: '💪',
    name: '強みの発揮',
    description: '得意なことで力を発揮したい',
  ),
  'ikigai_world_needs': ValueLabel(
    emoji: '🌍',
    name: '社会への貢献',
    description: '誰かの役に立つことに意味を感じる',
  ),
  'ikigai_paid_for': ValueLabel(
    emoji: '💎',
    name: '経済的な実り',
    description: '生み出した価値が経済的リターンになることを重視する',
  ),
  'big5_openness': ValueLabel(
    emoji: '🔭',
    name: '探求と創造',
    description: '新しい世界やアイデアに触れていたい',
  ),
  'big5_conscientiousness': ValueLabel(
    emoji: '🧱',
    name: '着実さ',
    description: 'コツコツ積み上げてやり切ることを大切にする',
  ),
  'big5_extraversion': ValueLabel(
    emoji: '⚡',
    name: '活気と交流',
    description: '人と関わることでエネルギーを得る',
  ),
  'big5_agreeableness': ValueLabel(
    emoji: '🍀',
    name: '調和',
    description: '思いやりと協力を大切にする',
  ),
  'big5_neuroticism': ValueLabel(
    emoji: '🌊',
    name: '感受性',
    description: '物事を深く感じ取り、丁寧に向き合う',
  ),
};

/// カテゴリの表示ラベル（絵文字は QuestionsData.categoryEmojis と揃える）
const Map<String, ValueLabel> categoryLabels = {
  'health': ValueLabel(emoji: '💪', name: '健康', description: '心身のコンディション'),
  'career': ValueLabel(emoji: '💼', name: 'キャリア', description: '仕事・働き方'),
  'hobby': ValueLabel(emoji: '🎨', name: '趣味', description: '楽しみ・遊び'),
  'learning': ValueLabel(emoji: '📚', name: '学び', description: '知識・スキル'),
  'relationship': ValueLabel(emoji: '❤️', name: '人間関係', description: '家族・友人・仲間'),
  'lifestyle': ValueLabel(emoji: '🏠', name: '暮らし', description: '生活スタイル'),
  'finance': ValueLabel(emoji: '💰', name: 'お金', description: '資産・経済'),
  'creativity': ValueLabel(emoji: '💡', name: '創造', description: 'ものづくり・表現'),
  'sports': ValueLabel(emoji: '⚽', name: 'スポーツ', description: '運動・競技'),
  'travel': ValueLabel(emoji: '✈️', name: '旅', description: '新しい場所との出会い'),
  'adventure': ValueLabel(emoji: '🚀', name: '冒険', description: '挑戦・スリル'),
  'service': ValueLabel(emoji: '🤝', name: '奉仕', description: '人を支えること'),
  'mindfulness': ValueLabel(emoji: '🧘', name: 'マインドフルネス', description: '内省・心の静けさ'),
  'entertainment': ValueLabel(emoji: '🎬', name: 'エンタメ', description: '観る・聴く楽しみ'),
};
