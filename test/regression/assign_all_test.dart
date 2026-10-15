import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

/// 上游 #3480-④：
/// `RxList.assignAll` 先 `value.clear()` 再 `addAll(items)`。
/// 如果传进来的 `items` 是派生自自身的懒视图（`list.where(...)` / `list.map(...)`），
/// 视图读到的是已经被清空的列表，整个赋值丢空；
/// 迭代中途抛异常还会留下一个清空或半填的列表。
void main() {
  group('RxList.assignAll', () {
    test('传入派生自自身的 where 懒视图不应丢空', () {
      final list = [1, 2, 3, 4].obs;

      list.assignAll(list.where((e) => e.isEven));

      expect(list, [2, 4]);
    });

    test('传入派生自自身的 map 懒视图不应丢空', () {
      final list = [1, 2, 3].obs;

      list.assignAll(list.map((e) => e * 10));

      expect(list, [10, 20, 30]);
    });

    test('传入普通 List 仍正常工作', () {
      final list = [1, 2, 3].obs;

      list.assignAll([9, 8]);

      expect(list, [9, 8]);
    });

    test('赋值后 Rx 仍会通知订阅者', () async {
      final list = [1, 2, 3].obs;
      var notified = 0;
      list.listen((_) => notified++);

      list.assignAll([4, 5, 6]);
      // stream 投递是异步的，让出一次事件循环
      await Future<void>.delayed(Duration.zero);

      expect(list, [4, 5, 6]);
      expect(notified, greaterThan(0));
    });

    test('迭代中途抛异常时列表不应变成清空/半填的残骸', () {
      final list = [1, 2, 3, 4].obs;

      Iterable<int> exploding() sync* {
        yield 100;
        yield 200;
        throw StateError('boom');
      }

      expect(() => list.assignAll(exploding()), throwsStateError);

      // 源没能完整物化就不该动原列表，否则会退化成空列表或半截列表
      expect(
        list,
        [1, 2, 3, 4],
        reason: '赋值中途失败时列表应保持原样',
      );
    });

    test('空迭代器赋值把列表清空是预期行为', () {
      final list = [1, 2, 3].obs;

      list.assignAll(const <int>[]);

      expect(list, isEmpty);
    });

    test('从另一个集合派生的懒视图也能正常赋值', () {
      final source = [1, 2, 3];
      final list = <int>[].obs;

      list.assignAll(source.where((e) => e > 1));

      expect(list, [2, 3]);
      expect(source, [1, 2, 3], reason: '源集合不该被改动');
    });
  });
}
