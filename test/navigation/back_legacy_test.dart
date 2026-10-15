import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:material_ui/material_ui.dart';

import '../navigation/utils/wrapper.dart';

/// `Get.backLegacy` 的行为锁定。
///
/// 它是**保留**的公开 API，但移除浮层时签名被改过（去掉了 `closeOverlays` 形参），
/// 而改动前仅有的两处调用都在浮层测试里，随浮层一起被删掉了 ——
/// 结果这个方法的 times / canPop 分支一度零覆盖。
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

  testWidgets('times = 1 且 canPop 时退一层', (tester) async {
    await boot(tester);

    Get.toNamed('/second');
    await tester.pumpAndSettle();
    Get.toNamed('/third');
    await tester.pumpAndSettle();
    expect(find.byType(Third), findsOneWidget);

    Get.backLegacy();
    await tester.pumpAndSettle();

    expect(find.byType(Second), findsOneWidget);
  });

  testWidgets('times > 1 连退多层', (tester) async {
    await boot(tester);

    Get.toNamed('/second');
    await tester.pumpAndSettle();
    Get.toNamed('/third');
    await tester.pumpAndSettle();
    Get.toNamed('/fourth');
    await tester.pumpAndSettle();
    expect(find.byType(Fourth), findsOneWidget);

    Get.backLegacy(times: 2);
    await tester.pumpAndSettle();

    expect(find.byType(Second), findsOneWidget);
  });

  testWidgets('times < 1 被归一成 1', (tester) async {
    await boot(tester);

    Get.toNamed('/second');
    await tester.pumpAndSettle();

    Get.backLegacy(times: 0);
    await tester.pumpAndSettle();

    // 只退一层，不会一路退到 first
    expect(find.byType(First), findsOneWidget);
  });

  testWidgets('栈底调用不抛异常、也不越界', (tester) async {
    await boot(tester);
    expect(find.byType(First), findsOneWidget);

    Get.backLegacy();
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.byType(First), findsOneWidget);
  });

  testWidgets('canPop: false 时强制 pop', (tester) async {
    await boot(tester);

    Get.toNamed('/second');
    await tester.pumpAndSettle();

    Get.backLegacy(canPop: false);
    await tester.pumpAndSettle();

    expect(find.byType(First), findsOneWidget);
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
