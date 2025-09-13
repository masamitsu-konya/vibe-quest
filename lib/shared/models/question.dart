class Question {
  final String id;
  final String text;
  final String category;
  final double growthScore;
  final List<String> tags;
  final String? imageUrl;

  const Question({
    required this.id,
    required this.text,
    required this.category,
    required this.growthScore,
    required this.tags,
    this.imageUrl,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id'] as String,
      text: json['text'] as String,
      category: json['category'] as String,
      growthScore: (json['growth_score'] as num).toDouble(),
      tags: List<String>.from(json['tags'] ?? []),
      imageUrl: json['image_url'] as String?,
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