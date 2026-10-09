import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/questions_data.dart';
import '../../../shared/models/swipe_response.dart';
import '../../profile/models/values_profile.dart';
import '../../profile/services/values_profile_builder.dart';
import '../data/response_repository.dart';

/// スワイプ回答の状態管理
///
/// アプリ起動時に永続化済みの回答を復元し、
/// 回答のたびにローカルへ保存する。
class ResponsesNotifier extends StateNotifier<List<SwipeResponse>> {
  final ResponseRepository _repository;

  ResponsesNotifier(this._repository) : super(_repository.loadAll());

  /// 回答を追加して永続化する
  Future<void> add(SwipeResponse response) async {
    state = [...state, response];
    await _repository.add(response);
  }

  /// 全回答をリセットする
  Future<void> reset() async {
    state = const [];
    await _repository.clear();
  }

  /// 回答済み質問IDのセット
  Set<String> get answeredQuestionIds =>
      state.map((r) => r.questionId).toSet();
}

final responsesProvider =
    StateNotifierProvider<ResponsesNotifier, List<SwipeResponse>>((ref) {
  return ResponsesNotifier(ref.watch(responseRepositoryProvider));
});

/// 現在の回答から生成した価値観プロファイル
final valuesProfileProvider = Provider<ValuesProfile>((ref) {
  final responses = ref.watch(responsesProvider);
  return ValuesProfileBuilder.build(responses, QuestionsData.questionById);
});
