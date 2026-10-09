import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:vibe_quest/features/swipe/data/response_repository.dart';
import 'package:vibe_quest/shared/models/swipe_response.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ResponseRepository', () {
    late ResponseRepository repository;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      repository = ResponseRepository(prefs);
    });

    test('初期状態は空', () {
      expect(repository.loadAll(), isEmpty);
    });

    test('add した回答が loadAll で復元される', () async {
      final response = SwipeResponse(
        questionId: 'q1',
        isExcited: true,
        timestamp: DateTime(2026, 7, 3, 12, 0),
      );

      await repository.add(response);
      final loaded = repository.loadAll();

      expect(loaded.length, 1);
      expect(loaded.first.questionId, 'q1');
      expect(loaded.first.isExcited, true);
      expect(loaded.first.timestamp, DateTime(2026, 7, 3, 12, 0));
    });

    test('複数回答の順序が保持される', () async {
      await repository.add(SwipeResponse(
        questionId: 'q1',
        isExcited: true,
        timestamp: DateTime(2026, 7, 3),
      ));
      await repository.add(SwipeResponse(
        questionId: 'q2',
        isExcited: false,
        timestamp: DateTime(2026, 7, 3),
      ));

      final loaded = repository.loadAll();
      expect(loaded.map((r) => r.questionId).toList(), ['q1', 'q2']);
    });

    test('answeredQuestionIds が回答済みIDを返す', () async {
      await repository.add(SwipeResponse(
        questionId: 'q1',
        isExcited: true,
        timestamp: DateTime(2026, 7, 3),
      ));

      expect(repository.answeredQuestionIds(), {'q1'});
    });

    test('clear で全消去される', () async {
      await repository.add(SwipeResponse(
        questionId: 'q1',
        isExcited: true,
        timestamp: DateTime(2026, 7, 3),
      ));

      await repository.clear();
      expect(repository.loadAll(), isEmpty);
    });

    test('破損データは空として扱う', () async {
      SharedPreferences.setMockInitialValues({
        'swipe_responses_v1': '{broken json',
      });
      final prefs = await SharedPreferences.getInstance();
      final broken = ResponseRepository(prefs);

      expect(broken.loadAll(), isEmpty);
    });
  });
}
