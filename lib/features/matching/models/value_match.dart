/// 成立したマッチ（get_my_matches RPC の1行）
class ValueMatch {
  final int matchId;
  final String partnerId;
  final String partnerNickname;
  final String? partnerBio;
  final double similarity;
  final DateTime matchedAt;

  const ValueMatch({
    required this.matchId,
    required this.partnerId,
    required this.partnerNickname,
    this.partnerBio,
    required this.similarity,
    required this.matchedAt,
  });

  factory ValueMatch.fromJson(Map<String, dynamic> json) {
    return ValueMatch(
      matchId: json['match_id'] as int,
      partnerId: json['partner_id'] as String,
      partnerNickname: json['partner_nickname'] as String? ?? '名無しさん',
      partnerBio: json['partner_bio'] as String?,
      similarity: (json['similarity'] as num?)?.toDouble() ?? 0,
      matchedAt: DateTime.parse(json['matched_at'] as String),
    );
  }

  int get similarityPercent => (similarity * 100).round().clamp(0, 100);
}

/// チャットメッセージ
class ChatMessage {
  final int id;
  final int matchId;
  final String senderId;
  final String content;
  final DateTime createdAt;

  const ChatMessage({
    required this.id,
    required this.matchId,
    required this.senderId,
    required this.content,
    required this.createdAt,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] as int,
      matchId: json['match_id'] as int,
      senderId: json['sender_id'] as String,
      content: json['content'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}
