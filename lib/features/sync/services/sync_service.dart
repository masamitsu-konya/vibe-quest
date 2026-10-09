import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../shared/models/swipe_response.dart';
import '../../auth/services/auth_service.dart';
import '../../profile/models/values_profile.dart';
import '../../swipe/data/response_repository.dart';

/// スワイプ回答と価値観プロファイルの Supabase 同期
///
/// ローカルファースト設計: 同期は best-effort で、失敗してもアプリの
/// 動作には影響しない（オフラインでもスワイプ・分析は完結する）。
/// 回答リストは追記専用のため、同期済み件数だけ記録して差分を送る。
class SyncService {
  /// この件数以上の未同期回答が溜まったら同期する
  static const int syncBatchThreshold = 10;

  static const String _syncedCountKey = 'synced_response_count_v1';

  final SupabaseClient _client;
  final AuthService _auth;
  final SharedPreferences _prefs;

  bool _syncing = false;

  SyncService(this._client, this._auth, this._prefs);

  int get syncedCount => _prefs.getInt(_syncedCountKey) ?? 0;

  /// 未同期の回答が閾値を超えていれば同期する
  ///
  /// [force] が true なら件数に関わらず同期する（アプリ起動時・
  /// プロファイル画面表示時など）。
  Future<void> maybeSync(
    List<SwipeResponse> responses,
    ValuesProfile profile, {
    bool force = false,
  }) async {
    if (_syncing) {
      return;
    }

    final pending = responses.length - syncedCount;
    if (!force && pending < syncBatchThreshold) {
      return;
    }
    if (responses.isEmpty) {
      return;
    }

    _syncing = true;
    try {
      final signedIn = await _auth.ensureSignedIn();
      if (!signedIn) {
        return;
      }
      final userId = _auth.currentUserId;
      if (userId == null) {
        return;
      }

      await _pushResponses(userId, responses);
      await _pushProfile(userId, profile);

      await _prefs.setInt(_syncedCountKey, responses.length);
    } catch (e) {
      // 同期失敗は次回の maybeSync で差分ごと再送されるため無視してよい
      debugPrint('同期失敗（次回リトライ）: $e');
    } finally {
      _syncing = false;
    }
  }

  Future<void> _pushResponses(
    String userId,
    List<SwipeResponse> responses,
  ) async {
    final unsynced = responses.skip(syncedCount).toList();
    if (unsynced.isEmpty) {
      return;
    }

    final rows = unsynced
        .map((r) => {
              'user_id': userId,
              'question_id': r.questionId,
              'is_excited': r.isExcited,
              'answered_at': r.timestamp.toUtc().toIso8601String(),
            })
        .toList();

    await _client
        .from('swipe_responses')
        .upsert(rows, onConflict: 'user_id,question_id');
  }

  Future<void> _pushProfile(String userId, ValuesProfile profile) async {
    await _client.from('values_profiles').upsert({
      'user_id': userId,
      'vector': profile.vector,
      'vector_version': profile.version,
      'answered_count': profile.answeredCount,
      'excited_count': profile.excitedCount,
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    });
  }
}

final syncServiceProvider = Provider<SyncService>((ref) {
  return SyncService(
    Supabase.instance.client,
    ref.watch(authServiceProvider),
    ref.watch(sharedPreferencesProvider),
  );
});
