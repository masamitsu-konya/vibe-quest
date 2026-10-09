/// スワイプ回答の記録
///
/// 質問本体は静的データ（QuestionsData）に存在するため、
/// 永続化には questionId のみを保持する軽量モデル。
class SwipeResponse {
  final String questionId;
  final bool isExcited;
  final DateTime timestamp;

  const SwipeResponse({
    required this.questionId,
    required this.isExcited,
    required this.timestamp,
  });

  factory SwipeResponse.fromJson(Map<String, dynamic> json) {
    return SwipeResponse(
      questionId: json['question_id'] as String,
      isExcited: json['is_excited'] as bool,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'question_id': questionId,
      'is_excited': isExcited,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}
