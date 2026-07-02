import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../auth/services/auth_service.dart';
import '../models/match_candidate.dart';
import '../models/value_match.dart';

/// マッチング API クライアント
///
/// 候補取得・Like/Skip・マッチ一覧・チャットはすべて Supabase の
/// RPC / RLS 保護されたテーブル経由で行う。他ユーザーのプロファイルに
/// 直接アクセスする経路はない（セキュリティは DB 側で担保）。
class MatchingService {
  final SupabaseClient _client;
  final AuthService _auth;

  MatchingService(this._client, this._auth);

  String? get myUserId => _auth.currentUserId;

  /// マッチング参加登録（ニックネーム・自己紹介の設定）
  Future<void> enableMatching({
    required String nickname,
    String? bio,
  }) async {
    final userId = _auth.currentUserId;
    if (userId == null) {
      throw StateError('未サインインです');
    }

    await _client.from('values_profiles').update({
      'nickname': nickname,
      'bio': bio,
      'is_matching_enabled': true,
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    }).eq('user_id', userId);
  }

  /// 自分のマッチング用プロフィールを取得（未登録なら null）
  Future<Map<String, dynamic>?> fetchMyProfile() async {
    final userId = _auth.currentUserId;
    if (userId == null) {
      return null;
    }

    return _client
        .from('values_profiles')
        .select('nickname, bio, is_matching_enabled, answered_count')
        .eq('user_id', userId)
        .maybeSingle();
  }

  /// 価値観が近い順のマッチング候補を取得
  Future<List<MatchCandidate>> fetchCandidates({int limit = 20}) async {
    final rows = await _client.rpc(
      'get_match_candidates',
      params: {'limit_count': limit},
    ) as List<dynamic>;

    return rows
        .map((row) => MatchCandidate.fromJson(row as Map<String, dynamic>))
        .toList();
  }

  /// Like / Skip を決定する
  ///
  /// 相互 Like でマッチが成立した場合は match_id を返す。
  Future<int?> decide(String targetUserId, {required bool isLike}) async {
    final result = await _client.rpc(
      'decide_match',
      params: {'target': targetUserId, 'is_like': isLike},
    );
    return result as int?;
  }

  /// 成立済みマッチの一覧
  Future<List<ValueMatch>> fetchMatches() async {
    final rows = await _client.rpc('get_my_matches') as List<dynamic>;
    return rows
        .map((row) => ValueMatch.fromJson(row as Map<String, dynamic>))
        .toList();
  }

  /// マッチのメッセージをリアルタイム購読する（新着含む全件、昇順）
  Stream<List<ChatMessage>> messagesStream(int matchId) {
    return _client
        .from('messages')
        .stream(primaryKey: ['id'])
        .eq('match_id', matchId)
        .order('created_at', ascending: true)
        .map((rows) => rows.map(ChatMessage.fromJson).toList());
  }

  /// メッセージ送信
  Future<void> sendMessage(int matchId, String content) async {
    final userId = _auth.currentUserId;
    if (userId == null) {
      throw StateError('未サインインです');
    }

    await _client.from('messages').insert({
      'match_id': matchId,
      'sender_id': userId,
      'content': content,
    });
  }
}

final matchingServiceProvider = Provider<MatchingService>((ref) {
  return MatchingService(
    Supabase.instance.client,
    ref.watch(authServiceProvider),
  );
});
