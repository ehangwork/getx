import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

/// 上游 #3480-③：
/// `GetQueue._check()` 只 `on Exception catch`，漏掉 `Error`（AssertionError、
/// 空值断言等）和裸字符串 throw；而且 `_active = false` 写在 try 之后，异常一抛就跳过。
/// 于是 `_active` 永远为 true，队列再也不排空，之后每个 add() 的 future 全部悬着。
///
/// 这条链路以前由 SnackbarController 触发（snackbar 已随浮层移除），
/// 但 GetQueue 仍从 get_utils 导出给下游（如 get_storage 的磁盘 flush）。
///
/// 用例里对「队列冻死」的断言靠 `.timeout` —— 队列一旦卡住，job 的 future 永远
/// 不完成，直接 await 会把整个测试挂死而不是报失败。
void main() {
  const settle = Duration(seconds: 2);

  group('GetQueue', () {
    test('job 抛 AssertionError 后队列仍能继续排空', () async {
      final queue = GetQueue();

      await expectLater(
        queue.add<Object>(() => throw AssertionError('boom')),
        throwsA(isA<AssertionError>()),
      );

      expect(
        await queue.add(() => 42).timeout(settle),
        42,
        reason: '一次失败不该让队列永久卡死',
      );
    });

    test('job 里发生空值断言后队列仍能继续排空', () async {
      final queue = GetQueue();

      await expectLater(
        queue.add<Object>(() {
          final int? nothing = null;
          // ignore: dead_code
          return nothing!;
        }),
        throwsA(isA<TypeError>()),
      );

      expect(
        await queue.add(() => 'still alive').timeout(settle),
        'still alive',
      );
    });

    test('job 抛裸字符串后队列仍能继续排空', () async {
      final queue = GetQueue();

      await expectLater(
        queue.add<Object>(() => throw 'raw string'),
        throwsA(anything),
      );

      expect(await queue.add(() => 'ok').timeout(settle), 'ok');
    });

    test('job 抛 Exception 后队列仍能继续排空', () async {
      final queue = GetQueue();

      await expectLater(
        queue.add<Object>(() => throw Exception('bad')),
        throwsA(isA<Exception>()),
      );

      expect(await queue.add(() => 7).timeout(settle), 7);
    });

    test('排队的多个 job 里前一个失败不阻断后面的', () async {
      final queue = GetQueue();

      final f1 = queue.add<Object>(() => throw StateError('x'));
      final f2 = queue.add(() => 'second');
      final f3 = queue.add(() => 'third');

      await expectLater(f1.timeout(settle), throwsA(isA<StateError>()));
      expect(await f2.timeout(settle), 'second');
      expect(await f3.timeout(settle), 'third');
    });

    test('连续多次失败后队列依然健在', () async {
      final queue = GetQueue();

      for (var i = 0; i < 5; i++) {
        await expectLater(
          queue.add<Object>(() => throw AssertionError('n$i')).timeout(settle),
          throwsA(isA<AssertionError>()),
        );
      }

      expect(await queue.add(() => 'survivor').timeout(settle), 'survivor');
    });

    test('cancelAllJobs 后仍可继续使用', () async {
      final queue = GetQueue();
      queue.cancelAllJobs();
      expect(await queue.add(() => 1).timeout(settle), 1);
    });
  });
}
