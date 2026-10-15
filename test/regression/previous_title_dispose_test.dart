import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:material_ui/material_ui.dart';

import '../navigation/utils/wrapper.dart';

/// Flutter 3.47 没有公开的 `ValueNotifier.debugDisposed`，
/// 但 `ChangeNotifier.debugAssertNotDisposed` 在已 dispose 时会抛 FlutterError。
bool _isDisposed(ChangeNotifier notifier) {
  try {
    ChangeNotifier.debugAssertNotDisposed(notifier);
    return false;
  } on FlutterError {
    return true;
  }
}

/// 上游 #3377：
/// `GetPageRouteTransitionMixin.didChangePrevious` 会建一个 `_previousTitle`
/// （ValueNotifier），但整个 mixin 从头到尾没有 dispose 过它 —— 每条路由泄漏一个。
/// 修法是在 mixin 上覆写 `Route.dispose()`，把 notifier 释放掉。
void main() {
  tearDown(Get.reset);

  testWidgets('路由销毁后 previousTitle 的 ValueNotifier 应被 dispose',
      (tester) async {
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

    // 进入第二页，并把它装到导航器上（装上之后才会创建 _previousTitle）
    final pending = Get.toNamed('/second');
    await tester.pumpAndSettle();
    expect(find.byType(Second), findsOneWidget);

    final route = ModalRoute.of(tester.element(find.byType(Second)));
    expect(route, isNotNull);

    final notifier =
        (route! as dynamic).previousTitle as ValueNotifier<String?>;

    // 路由还在栈上时不该被 dispose
    expect(_isDisposed(notifier), isFalse);

    // 弹栈 → 路由被销毁
    Get.back();
    await tester.pumpAndSettle();

    expect(
      _isDisposed(notifier),
      isTrue,
      reason: '路由销毁后必须释放 previousTitle，否则每个路由泄漏一个 notifier',
    );

    // pending 在页面被 pop 后才完成，这里兜底避免未处理异常
    await pending;
  });

  testWidgets('previousTitle 在多次进出后不会累积未释放的 notifier',
      (tester) async {
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

    final captured = <ValueNotifier<String?>>[];

    for (var i = 0; i < 3; i++) {
      final pending = Get.toNamed('/second');
      await tester.pumpAndSettle();

      final route = ModalRoute.of(tester.element(find.byType(Second)));
      captured.add((route! as dynamic).previousTitle as ValueNotifier<String?>);

      Get.back();
      await tester.pumpAndSettle();
      await pending;
    }

    expect(captured, hasLength(3));
    for (final notifier in captured) {
      expect(
        _isDisposed(notifier),
        isTrue,
        reason: '每轮创建的 previousTitle 都应在路由销毁时被释放',
      );
    }
  });

  testWidgets('未 pop 的页面其 previousTitle 不应被提前 dispose', (tester) async {
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

    final pending = Get.toNamed('/second');
    await tester.pumpAndSettle();

    final route = ModalRoute.of(tester.element(find.byType(Second)));
    final notifier = (route! as dynamic).previousTitle as ValueNotifier<String?>;

    await tester.pumpAndSettle();

    expect(_isDisposed(notifier), isFalse);

    Get.back();
    await tester.pumpAndSettle();
    await pending;
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
