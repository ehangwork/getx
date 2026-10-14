import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:get/get.dart';

import 'package:get_demo/main.dart' as app;
import 'package:get_demo/app/routes/app_pages.dart';

/// 嵌套路由的 outlet 页面必须显式给返回键：
/// outlet 的 Navigator 只持有当前分支切片，canPop 恒为 false，
/// AppBar 的自动返回键不会渲染。
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

  testWidgets('outlet 页面有返回键且能退回上一层', (tester) async {
    app.main();
    await settle(tester, frames: 8);
    expect(find.text('GetX 示例'), findsOneWidget);

    // 进二级页：从目录页的「嵌套路由」入口进 Home
    Get.toNamed(Routes.home);
    await settle(tester, frames: 8);
    expect(find.text('Home'), findsWidgets);
    expect(
      find.byType(BackButton),
      findsOneWidget,
      reason: '/home 是 outlet 页面，没有显式返回键',
    );

    // 点返回键应该退回目录
    await tester.tap(find.byType(BackButton));
    await settle(tester, frames: 8);
    expect(find.text('GetX 示例'), findsOneWidget,
        reason: '点返回键没有退回示例目录');
    expect(tester.takeException(), isNull);
  });
}
