import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:get/get.dart';

import 'package:get_demo/main.dart' as app;

/// 复现并锁定 bottomSheet 的层级语义（嵌套路由）。
///
/// 修复前：bottomSheet 固定压在根 navigator 上，而嵌套路由下跳转后的页面
/// 渲染在壳的 outlet 里、位置在壳之下，于是弹层盖住新页面。
/// 修复后：bottomSheet 推到当前 outlet 的 navigator 上，新页面盖住弹层。
///
/// 注意：「返回后弹层还在」做不到 —— outlet 的声明式 pages 被整体替换时，
/// Flutter 会把夹在中间、不属于 pages 的命令式路由一起丢弃。
/// 这是 Navigator 声明式/命令式混用的硬约束，不是 GetX 能绕过的。
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  Future<void> settle(
    WidgetTester tester, {
    int frames = 6,
    Duration step = const Duration(milliseconds: 400),
  }) async {
    for (var i = 0; i < frames; i++) {
      await tester.pump(step);
    }
  }

  tearDown(Get.reset);

  testWidgets('bottomSheet 不该盖住跳转后的页面', (tester) async {
    app.main();
    await settle(tester, frames: 8);
    expect(find.text('GetX 示例'), findsOneWidget);

    Get.bottomSheet(const _NavSheet());
    await settle(tester, frames: 4);
    expect(find.text('SHEET_MARK'), findsOneWidget,
        reason: 'bottomSheet 没有展示出来');
    expect(find.text('GetX 示例'), findsOneWidget,
        reason: 'bottomSheet 应该盖在跳转前的页面上');

    // 从弹层里跳到另一个页面
    await tester.tap(find.text('GO_NEXT'));
    await settle(tester, frames: 8);

    expect(find.text('SHEET_MARK'), findsNothing,
        reason: '跳转之后 bottomSheet 仍然盖在最上面');
    expect(find.text('路由过渡'), findsOneWidget,
        reason: '跳转之后的页面没有展示出来');
    expect(tester.takeException(), isNull);
  });
}

class _NavSheet extends StatelessWidget {
  const _NavSheet();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('SHEET_MARK'),
            FilledButton(
              onPressed: () => Get.toNamed('/transitions'),
              child: const Text('GO_NEXT'),
            ),
          ],
        ),
      ),
    );
  }
}
