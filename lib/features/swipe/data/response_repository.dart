import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../shared/models/swipe_response.dart';

/// スワイプ回答のローカル永続化リポジトリ
///
/// shared_preferences に JSON 配列として保存する。
/// 将来の Supabase 同期はこのリポジトリの背後に追加する。
class ResponseRepository {
  static const String _storageKey = 'swipe_responses_v1';

  final SharedPreferences _prefs;

  ResponseRepository(this._prefs);

  /// 保存済みの全回答を読み込む
  List<SwipeResponse> loadAll() {
    final raw = _prefs.getString(_storageKey);
    if (raw == null || raw.isEmpty) {
      return const [];
    }

    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      return decoded
          .map((e) => SwipeResponse.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      // 破損データは捨てて空から再開する（クラッシュさせない）
      return const [];
    }
  }

  /// 回答を追記して保存する
  Future<void> add(SwipeResponse response) async {
    final all = [...loadAll(), response];
    await _save(all);
  }

  /// 全回答を消去する
  Future<void> clear() async {
    await _prefs.remove(_storageKey);
  }

  /// 回答済みの質問IDセット
  Set<String> answeredQuestionIds() {
    return loadAll().map((r) => r.questionId).toSet();
  }

  Future<void> _save(List<SwipeResponse> responses) async {
    final encoded = jsonEncode(responses.map((r) => r.toJson()).toList());
    await _prefs.setString(_storageKey, encoded);
  }
}

/// SharedPreferences インスタンスの Provider（main.dart で override する）
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('main.dart で override してください');
});

final responseRepositoryProvider = Provider<ResponseRepository>((ref) {
  return ResponseRepository(ref.watch(sharedPreferencesProvider));
});
