import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

/// 上游 #3480-① / #3338：
/// `GetListenable.subject` 把 `addListener(_streamListener)` 当成 `onCancel` 传进去，
/// 而 `addListener` 是立即求值的 —— 建 controller 的瞬间就挂上了监听并返回摘除器。
/// 于是最后一个 stream 订阅者取消时监听被摘掉，而 controller 已存在不会重建，
/// `addListener` 再也不会被调用。之后的 ever/listen/once 拿到的是「活着但永久静默」的流。
/// `Obx` 走 ListNotifier 那条路，完全不受影响，所以这个缺陷平时看不出来。
///
/// 注意：stream 投递是异步的，每次改值后都要让出一次事件循环才能断言。
void main() {
  group('Rx stream bridge', () {
    test('最后一个 stream 订阅者取消后，ever 仍能收到后续变更', () async {
      final rx = 0.obs;

      final firstRound = <int>[];
      final worker1 = ever(rx, firstRound.add);
      rx.value = 1;
      await Future<void>.delayed(Duration.zero);
      expect(firstRound, [1], reason: '第一轮订阅应当正常收到');

      // 最后一个订阅者取消 —— 旧实现在这里把流监听永久摘掉
      worker1.dispose();

      rx.value = 2;

      final secondRound = <int>[];
      final worker2 = ever(rx, secondRound.add);
      rx.value = 3;
      await Future<void>.delayed(Duration.zero);

      expect(
        secondRound,
        [3],
        reason: '重新订阅后必须还能收到值，而不是一个永久静默的流',
      );

      worker2.dispose();
    });

    test('反复订阅/取消不应让流逐渐失聪', () async {
      final rx = 0.obs;

      for (var round = 0; round < 5; round++) {
        final seen = <int>[];
        final worker = ever(rx, seen.add);
        rx.value = round + 1;
        await Future<void>.delayed(Duration.zero);
        expect(
          seen,
          [round + 1],
          reason: '第 $round 轮订阅应当收到值',
        );
        worker.dispose();
      }
    });

    test('listen 取消后重新 listen 仍能收到值', () async {
      final rx = 0.obs;

      final seen = <int>[];
      final sub1 = rx.listen(seen.add);
      rx.value = 1;
      await Future<void>.delayed(Duration.zero);
      await sub1.cancel();

      rx.value = 2;

      final sub2 = rx.listen(seen.add);
      rx.value = 3;
      await Future<void>.delayed(Duration.zero);

      expect(seen, [1, 3]);
      await sub2.cancel();
    });

    test('once 在曾经有过订阅取消的 Rx 上仍能触发', () async {
      final rx = 0.obs;

      final worker1 = ever(rx, (_) {});
      worker1.dispose();

      final fired = <int>[];
      final worker2 = once(rx, fired.add);
      rx.value = 42;
      await Future<void>.delayed(Duration.zero);

      expect(fired, [42]);
      worker2.dispose();
    });

    test('多个并发订阅者时，取消其中一个不应影响另一个', () async {
      final rx = 0.obs;

      final a = <int>[];
      final b = <int>[];

      final w1 = ever(rx, a.add);
      final w2 = ever(rx, b.add);

      w1.dispose();

      rx.value = 7;
      await Future<void>.delayed(Duration.zero);
      expect(b, [7], reason: '仍有活跃订阅者时流必须继续工作');

      w2.dispose();

      // 全部取消后重新订阅，依然要能收到
      final c = <int>[];
      final w3 = ever(rx, c.add);
      rx.value = 8;
      await Future<void>.delayed(Duration.zero);
      expect(c, [8]);
      w3.dispose();
    });

    test('Rx 销毁后不再向已关闭的流投递', () async {
      final rx = 0.obs;

      final seen = <int>[];
      final worker = ever(rx, seen.add);
      rx.value = 1;
      await Future<void>.delayed(Duration.zero);
      expect(seen, [1]);

      worker.dispose();
      rx.close();
    });
  });
}
