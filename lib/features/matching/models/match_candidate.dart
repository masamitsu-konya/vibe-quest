/// マッチング候補（get_match_candidates RPC の1行）
class MatchCandidate {
  final String userId;
  final String nickname;
  final String? bio;
  final double similarity;
  final int answeredCount;

  const MatchCandidate({
    required this.userId,
    required this.nickname,
    this.bio,
    required this.similarity,
    required this.answeredCount,
  });

  factory MatchCandidate.fromJson(Map<String, dynamic> json) {
    return MatchCandidate(
      userId: json['user_id'] as String,
      nickname: json['nickname'] as String? ?? '名無しさん',
      bio: json['bio'] as String?,
      similarity: (json['similarity'] as num?)?.toDouble() ?? 0,
      answeredCount: json['answered_count'] as int? ?? 0,
    );
  }

  /// 価値観一致度（%表示用、0〜100）
  int get similarityPercent => (similarity * 100).round().clamp(0, 100);
}
