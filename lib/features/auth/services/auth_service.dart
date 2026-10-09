import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// 認証サービス
///
/// サインアップ障壁ゼロでスワイプ体験に直行させるため、匿名認証を使う。
/// セッションは supabase_flutter がローカルに永続化するため、
/// アプリ再起動後も同じ匿名ユーザーとして継続する。
class AuthService {
  final SupabaseClient _client;

  AuthService(this._client);

  /// 現在のユーザーID（未サインインなら null）
  String? get currentUserId => _client.auth.currentUser?.id;

  /// サインイン済みかどうか
  bool get isSignedIn => _client.auth.currentSession != null;

  /// 未サインインなら匿名サインインする
  ///
  /// オフライン等で失敗してもアプリはローカルだけで動作できるため、
  /// 例外は握りつぶして false を返す（呼び出し側でリトライ判断）。
  Future<bool> ensureSignedIn() async {
    if (isSignedIn) {
      return true;
    }

    try {
      await _client.auth.signInAnonymously();
      return true;
    } catch (e) {
      debugPrint('匿名サインイン失敗（オフライン時は正常）: $e');
      return false;
    }
  }
}

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService(Supabase.instance.client);
});
