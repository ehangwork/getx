import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:material_ui/material_ui.dart';

import '../navigation/utils/wrapper.dart';

/// 上游 #3480-⑤：
/// `offAllNamed` / `offNamedUntil` 用 `_activePages.removeLast()` 直接丢弃页面，
/// 而 `GetDelegate` 里其它所有回退路径都走 `_popWithResult()`。
/// 被丢弃页面的 route completer 因此永远不完成 —— 先前 `await Get.toNamed(...)`
/// 的调用方会永久挂起，而且不会有任何报错。
///
/// 测试写法上的两个坑：
/// 1. 这些导航方法返回的 future 要等对应页面被 pop 才完成，
///    所以测试里不能 await 它们本身，只能把结果挂到变量上断言。
/// 2. testWidgets 跑在 fake-async 里，`Future.timeout` / `Future.delayed` 的
///    Timer 不会随测试推进，所以也不能靠超时来「证明它没完成」；
///    只能用 pumpAndSettle 冲干净微任务后直接断言标志位。
void main() {
  tearDown(Get.reset);

  testWidgets('offAllNamed 应完成被它丢弃的页面的 future', (tester) async {
    await tester.pumpWidget(
      Wrapper(
        namedRoutes: [
          GetPage(name: '/first', page: First.new),
          GetPage(name: '/second', page: Second.new),
          GetPage(name: '/third', page: Third.new),
        ],
        initialRoute: '/first',
      ),
    );
    await tester.pumpAndSettle();

    final pending = Get.toNamed<String>('/second');
    await tester.pumpAndSettle();
    expect(find.byType(Second), findsOneWidget);

    var secondSettled = false;
    unawaited(pending?.then((_) => secondSettled = true));

    // 换页前后都还没完成，说明断言是有效的
    await tester.pumpAndSettle();
    expect(secondSettled, isFalse);

    // offAllNamed 把 /second 整个丢掉（不能 await 它自己）
    unawaited(Get.offAllNamed<String>('/third'));
    await tester.pumpAndSettle();

    expect(find.byType(Third), findsOneWidget);
    expect(find.byType(Second), findsNothing);

    // 关键断言：/second 的 future 必须在 offAllNamed 之后收敛
    expect(secondSettled, isTrue, reason: '被丢弃页面的 future 必须完成');
  });

  testWidgets('offNamedUntil 应完成被它丢弃的页面的 future', (tester) async {
    await tester.pumpWidget(
      Wrapper(
        namedRoutes: [
          GetPage(name: '/first', page: First.new),
          GetPage(name: '/second', page: Second.new),
          GetPage(name: '/third', page: Third.new),
          GetPage(name: '/fourth', page: Fourth.new),
        ],
        initialRoute: '/first',
      ),
    );
    await tester.pumpAndSettle();

    unawaited(Get.toNamed('/second'));
    await tester.pumpAndSettle();

    final pending = Get.toNamed<String>('/third');
    await tester.pumpAndSettle();
    expect(find.byType(Third), findsOneWidget);

    var thirdSettled = false;
    unawaited(pending?.then((_) => thirdSettled = true));

    // 谓词恒 false —— 于是 /third 之前的页面（含 /second）都会被丢弃
    unawaited(Get.offNamedUntil<String>('/fourth', (_) => false));
    await tester.pumpAndSettle();

    expect(find.byType(Fourth), findsOneWidget);
    expect(find.byType(Third), findsNothing);
    expect(thirdSettled, isTrue, reason: '被丢弃页面的 future 必须完成');
  });

  testWidgets('offAll（函数式）同样应完成被丢弃页面的 future', (tester) async {
    await tester.pumpWidget(
      Wrapper(
        namedRoutes: [
          GetPage(name: '/first', page: First.new),
          GetPage(name: '/second', page: Second.new),
        ],
        initialRoute: '/first',
      ),
    );
    await tester.pumpAndSettle();

    // 这里刻意不带泛型：GetPage.copyWith<T> 目前在混用带/不带泛型的跳转时会
    // 抛 _TypeError，那是另一个独立缺陷，不在本用例的验证范围内。
    final pending = Get.toNamed('/second');
    await tester.pumpAndSettle();
    expect(find.byType(Second), findsOneWidget);

    var settled = false;
    unawaited(pending?.then((_) => settled = true));
    await tester.pumpAndSettle();
    expect(settled, isFalse);

    unawaited(Get.offAll(() => const Third()));
    await tester.pumpAndSettle();

    expect(settled, isTrue, reason: '被丢弃页面的 future 必须完成');
  });

  testWidgets('仍在栈上的页面 future 不应被提前完成', (tester) async {
    await tester.pumpWidget(
      Wrapper(
        namedRoutes: [
          GetPage(name: '/first', page: First.new),
          GetPage(name: '/second', page: Second.new),
        ],
        initialRoute: '/first',
      ),
    );
    await tester.pumpAndSettle();

    var settled = false;
    String? result;
    final pending = Get.toNamed<String>('/second')?.then((v) {
      settled = true;
      result = v;
      return v;
    });
    await tester.pumpAndSettle();

    // /second 还挂在栈上，它的 future 必须仍未完成
    expect(settled, isFalse, reason: '仍在栈上的页面 future 不该被完成');

    Get.back(result: 'done');
    await tester.pumpAndSettle();

    expect(settled, isTrue);
    expect(result, 'done');
    expect(pending, isNotNull);
  });
}

class First extends StatelessWidget {
  const First({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('first')),
        body: const Text('first'),
      );
}

class Second extends StatelessWidget {
  const Second({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('second')),
        body: const Text('second'),
      );
}

class Third extends StatelessWidget {
  const Third({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('third')),
        body: const Text('third'),
      );
}

class Fourth extends StatelessWidget {
  const Fourth({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('fourth')),
        body: const Text('fourth'),
      );
}
