import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:material_ui/material_ui.dart';

import '../navigation/utils/wrapper.dart';

/// `GetPage.copyWith<T>` 的类型安全。
///
/// copyWith 原本自带一个方法级类型参数 T，返回 `GetPage<T>`。它会把 `this` 上的
/// `completer`（`Completer<T?>`）、`children`、`onPopInvoked` 拷进新实例 ——
/// 但 `this` 是 `GetPage<X>`。调用方一旦显式指定另一个类型
/// （`Get.toNamed<String>(...)` 之后接 `Get.offAll<String>(...)`），
/// 就会把 `Completer<dynamic>` 塞进 `Completer<String?>` 的字段里，运行时 _TypeError。
///
/// 正确做法是 copyWith 不该改接收者的类型：去掉方法级 T 之后，
/// completer / children / onPopInvoked 都不可能被跨类型拷贝。
void main() {
  tearDown(Get.reset);

  group('GetPage.copyWith 类型安全', () {
    test('copyWith 不应丢掉 restorationId', () {
      final page = GetPage(
        name: '/a',
        page: () => const Text('a'),
        restorationId: 'keep-me',
      );

      final copied = page.copyWith(name: '/b');

      expect(
        copied.restorationId,
        'keep-me',
        reason: 'copyWith 必须继承原有的 restorationId',
      );
    });

    test('显式传入 restorationId 时应覆盖', () {
      final page = GetPage(
        name: '/a',
        page: () => const Text('a'),
        restorationId: 'old',
      );

      expect(page.copyWith(restorationId: 'new').restorationId, 'new');
    });

    test('copyWith 不传 completer 时应保留原有的', () {
      final page = GetPage(
        name: '/a',
        page: () => const Text('a'),
        completer: Completer<String?>(),
      );

      expect(page.copyWith(name: '/b').completer, same(page.completer));
    });

    test('copyWith 显式传 completer 时应覆盖', () {
      final page = GetPage(name: '/a', page: () => const Text('a'));
      final next = Completer<String?>();

      expect(page.copyWith(completer: next).completer, same(next));
    });

    test('copyWith 应保留 children', () {
      final child = GetPage(name: '/a/c', page: () => const Text('c'));
      final page = GetPage(
        name: '/a',
        page: () => const Text('a'),
        children: [child],
      );

      expect(page.copyWith(name: '/b').children, [child]);
    });
  });

  group('带泛型与不带泛型的跳转混用', () {
    Future<void> boot(WidgetTester tester) async {
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
    }

    testWidgets('Get.toNamed<String> 之后接 Get.offAll<String> 不应崩', (tester) async {
      await boot(tester);

      final pending = Get.toNamed<String>('/second');
      await tester.pumpAndSettle();
      expect(find.byType(Second), findsOneWidget);

      unawaited(Get.offAll<String>(() => const Third()));
      await tester.pumpAndSettle();

      expect(find.byType(Third), findsOneWidget);

      Get.back();
      await tester.pumpAndSettle();
      await pending;
    });

    testWidgets('Get.toNamed<String> 之后接不带泛型的 offAll 不应崩', (tester) async {
      await boot(tester);

      final pending = Get.toNamed<String>('/second');
      await tester.pumpAndSettle();
      expect(find.byType(Second), findsOneWidget);

      unawaited(Get.offAll(() => const Third()));
      await tester.pumpAndSettle();

      expect(find.byType(Third), findsOneWidget);

      Get.back();
      await tester.pumpAndSettle();
      await pending;
    });

    testWidgets('不带泛型的跳转之后接带泛型的 offAll 不应崩', (tester) async {
      await boot(tester);

      final pending = Get.toNamed('/second');
      await tester.pumpAndSettle();
      expect(find.byType(Second), findsOneWidget);

      unawaited(Get.offAll<String>(() => const Third()));
      await tester.pumpAndSettle();

      expect(find.byType(Third), findsOneWidget);

      Get.back();
      await tester.pumpAndSettle();
      await pending;
    });

    testWidgets('连续多次带泛型跳转不应崩', (tester) async {
      await boot(tester);

      final p1 = Get.toNamed<String>('/second');
      await tester.pumpAndSettle();

      final p2 = Get.toNamed<String>('/third');
      await tester.pumpAndSettle();
      expect(find.byType(Third), findsOneWidget);

      Get.back();
      await tester.pumpAndSettle();
      Get.back();
      await tester.pumpAndSettle();

      await p1;
      await p2;
    });
  });
}

class First extends StatelessWidget {
  const First({super.key});

  @override
  Widget build(BuildContext context) =>
      Scaffold(appBar: AppBar(title: const Text('first')), body: const Text('first'));
}

class Second extends StatelessWidget {
  const Second({super.key});

  @override
  Widget build(BuildContext context) =>
      Scaffold(appBar: AppBar(title: const Text('second')), body: const Text('second'));
}

class Third extends StatelessWidget {
  const Third({super.key});

  @override
  Widget build(BuildContext context) =>
      Scaffold(appBar: AppBar(title: const Text('third')), body: const Text('third'));
}
