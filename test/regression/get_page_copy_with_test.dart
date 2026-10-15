import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:material_ui/material_ui.dart';

import '../navigation/utils/wrapper.dart';

/// `GetPage.copyWith` 的类型安全与字段继承。
///
/// 两个真实缺陷：
/// 1. copyWith 里 `return GetPage(...)` 没写显式类型实参，构造器的 T 会从实参反推
///    （传 `Completer<String?>` 就被推成 `GetPage<String>`），于是「返回类型与接收者一致」
///    只在编译期成立；
/// 2. `restorationId: restorationId ?? restorationId` 是自引用，copyWith 出来的页面
///    永远拿不到原来的 restorationId。
///
/// 另外还锁住 `children` 放宽成 `List<GetPage>?` 之后，completer / children 的继承语义没变。
///
/// 最后一组用的是带泛型的跳转混用（`Get.toNamed<String>` 之后接 `Get.offAll<String>`）——
/// 这是 delegate 里 `_replace` 漏传 `<T>` 时的崩溃路径。
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
