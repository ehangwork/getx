import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:material_ui/material_ui.dart';

import '../navigation/utils/wrapper.dart';

/// `_replace` / `_replaceNamed` 在栈深只剩 1 项时，会用
/// `_activePages[index] = activePage` 直接覆盖那一项 —— 被顶掉的旧项
/// 连同它的 completer 一起消失，既不完成也没人持有。
///
/// 于是 `await Get.offAllNamed('/a')` 在紧接一次 `Get.offAllNamed('/b')`
/// 之后永久挂起，无报错无日志。真实场景就是登录态切换 / 401 拦截里
/// 连续两次重定向跳转。
///
/// 测试里不能直接 await 那个 future（挂起会拖死整个测试），
/// 所以断言的是「它有没有在有限轮内收敛」。
void main() {
  tearDown(Get.reset);

  Future<void> boot(WidgetTester tester) async {
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
  }

  testWidgets('连续两次 offAllNamed：第一次的 future 必须收敛', (tester) async {
    await boot(tester);

    final first = Get.offAllNamed('/second');
    await tester.pumpAndSettle();
    expect(find.byType(Second), findsOneWidget);

    var firstSettled = false;
    unawaited(first?.then((_) => firstSettled = true));
    await tester.pumpAndSettle();
    expect(firstSettled, isFalse, reason: '/second 还在栈上，future 不该完成');

    // 栈深为 1，再来一次 offAllNamed —— 会直接覆盖掉 /second
    unawaited(Get.offAllNamed('/third'));
    await tester.pumpAndSettle();
    expect(find.byType(Third), findsOneWidget);

    expect(
      firstSettled,
      isTrue,
      reason: '被覆盖掉的那一项的 future 必须被完成，否则调用方永久挂起',
    );

    Get.back();
    await tester.pumpAndSettle();
  });

  testWidgets('连续两次 off（函数式）：第一次的 future 必须收敛',
      (tester) async {
    await boot(tester);

    final first = Get.off(() => const Second());
    await tester.pumpAndSettle();
    expect(find.byType(Second), findsOneWidget);

    var firstSettled = false;
    unawaited(first?.then((_) => firstSettled = true));
    await tester.pumpAndSettle();
    expect(firstSettled, isFalse);

    unawaited(Get.off(() => const Third()));
    await tester.pumpAndSettle();
    expect(find.byType(Third), findsOneWidget);

    expect(firstSettled, isTrue);

    Get.back();
    await tester.pumpAndSettle();
  });

  testWidgets('offAll 与 offAllNamed 交替：被覆盖的那一项也要收敛',
      (tester) async {
    await boot(tester);

    final first = Get.offAllNamed('/second');
    await tester.pumpAndSettle();
    expect(find.byType(Second), findsOneWidget);

    var settled = false;
    unawaited(first?.then((_) => settled = true));
    await tester.pumpAndSettle();
    expect(settled, isFalse);

    unawaited(Get.offAll(() => const Fourth()));
    await tester.pumpAndSettle();
    expect(find.byType(Fourth), findsOneWidget);

    expect(settled, isTrue);

    Get.back();
    await tester.pumpAndSettle();
  });

  testWidgets('栈深大于 1 时只完成栈顶那一个，不误伤更深的', (tester) async {
    await boot(tester);

    final first = Get.toNamed('/second');
    await tester.pumpAndSettle();

    final second = Get.toNamed('/third');
    await tester.pumpAndSettle();
    expect(find.byType(Third), findsOneWidget);

    var firstSettled = false;
    var secondSettled = false;
    unawaited(first?.then((_) => firstSettled = true));
    unawaited(second?.then((_) => secondSettled = true));
    await tester.pumpAndSettle();

    // offNamed 只弹一层，/second 应当仍在栈上
    unawaited(Get.offNamed('/fourth'));
    await tester.pumpAndSettle();
    expect(find.byType(Fourth), findsOneWidget);

    expect(secondSettled, isTrue, reason: '栈顶 /third 被替换，应完成');
    expect(
      firstSettled,
      isFalse,
      reason: '/second 仍在栈上，不应被提前完成',
    );

    Get.back();
    await tester.pumpAndSettle();
    Get.back();
    await tester.pumpAndSettle();
    await first;
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
