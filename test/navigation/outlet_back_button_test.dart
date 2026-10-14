import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:get/get.dart';

/// 验证：在 outlet 页面里放 AppBar，Navigator 自动生成的返回键
/// 到底能不能正确同步 GetX 的历史栈。
class ShellPage extends StatelessWidget {
  const ShellPage({super.key});
  @override
  Widget build(BuildContext context) =>
      Scaffold(body: GetRouterOutlet(initialRoute: '/a', anchorRoute: '/'));
}

class APage extends StatelessWidget {
  const APage({super.key});
  @override
  Widget build(BuildContext context) =>
      Scaffold(body: Center(child: Text('A_MARK')));
}

/// 带 AppBar 的 outlet 页面，用来拿到 Navigator 的自动返回键
class BPage extends StatelessWidget {
  const BPage({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
        // 自动返回键在 outlet 里不会出现（canPop 恒为 false），必须显式给
        appBar: AppBar(
          title: const Text('B_TITLE'),
          leading: BackButton(onPressed: Get.back),
        ),
        body: const Center(child: Text('B_MARK')),
      );
}

void main() {
  tearDown(Get.reset);

  testWidgets('outlet 页面的 AppBar 返回键是否同步 GetX 历史', (tester) async {
    Get.testMode = true;
    await tester.pumpWidget(GetMaterialApp(
      initialRoute: '/',
      getPages: [
        GetPage(
          name: '/',
          page: () => const ShellPage(),
          participatesInRootNavigator: true,
          children: [
            GetPage(name: '/a', page: () => const APage()),
            GetPage(name: '/b', page: () => const BPage()),
          ],
        ),
      ],
    ));
    await tester.pumpAndSettle();

    Get.toNamed('/b');
    await tester.pumpAndSettle();
    expect(find.text('B_MARK'), findsOneWidget);

    final beforeBranch = Get.rootController.rootDelegate.currentConfiguration!
        .currentTreeBranch.map((e) => e.name).toList();
    // ignore: avoid_print
    print('BACKBTN before=$beforeBranch backBtn=${find.byType(BackButton).evaluate().length}');

    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();

    final afterBranch = Get.rootController.rootDelegate.currentConfiguration!
        .currentTreeBranch.map((e) => e.name).toList();
    // ignore: avoid_print
    print('BACKBTN after=$afterBranch '
        'a=${find.text('A_MARK').evaluate().length} '
        'b=${find.text('B_MARK').evaluate().length} '
        'exc=${tester.takeException()}');

    // /a 是 outlet 的 emptyPage 兜底，从 /b 返回后历史里剩的就是壳页本身
    expect(afterBranch, ['/'], reason: '显式返回键没有同步 GetX 历史');
    expect(find.text('A_MARK'), findsOneWidget);
    expect(find.text('B_MARK'), findsNothing);
  });
}
