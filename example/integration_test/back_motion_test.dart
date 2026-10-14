import 'package:flutter/gestures.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:get_demo/app/modules/menu/views/menu_view.dart';
import 'package:get_demo/app/modules/stateful/views/stateful_view.dart';
import 'package:get_demo/app/routes/app_pages.dart';
import 'package:integration_test/integration_test.dart';
import 'package:material_ui/material_ui.dart';

import 'package:get_demo/main.dart' as app;

/// 真机上验证返回动画方向与 iOS 侧滑。
///
/// 跑在 macOS 的 widget 测试里 GetPlatform.isIOS 恒为 false，
/// 侧滑门禁那条路径在那边测不到，必须上真机。
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  Future<void> settle(WidgetTester tester, {int frames = 12}) async {
    for (var i = 0; i < frames; i++) {
      await tester.pump(const Duration(milliseconds: 120));
    }
  }

  tearDown(Get.reset);

  testWidgets('返回动画往右 + 侧滑能返回', (tester) async {
    app.main();
    await settle(tester, frames: 12);

    // 从目录页点进去：和用户实际操作一致
    await tester.tap(find.text('GetX / GetBuilder / Obx'));
    await settle(tester);
    expect(find.byType(StatefulView), findsOneWidget);

    // 返回：页面应该往右移
    final page = find.byType(StatefulView);
    final route = ModalRoute.of(tester.element(page));
    expect(route!.isFirst, isFalse, reason: '目标页必须在根 navigator 的栈里');

    Get.back();
    final offsets = <double>[];
    for (var i = 0; i < 4; i++) {
      await tester.pump(const Duration(milliseconds: 50));
      if (page.evaluate().isNotEmpty) {
        offsets.add(tester.getTopLeft(page).dx);
      }
    }
    expect(offsets, isNotEmpty);
    expect(offsets.last, greaterThan(0), reason: '返回应把页面推向右边，实测 $offsets');

    await settle(tester);
    expect(tester.takeException(), isNull);

    // 侧滑：再进去一次，从左边缘拖过半屏
    await tester.tap(find.text('GetX / GetBuilder / Obx'));
    await settle(tester);
    expect(find.byType(StatefulView), findsOneWidget);

    final gesture = await tester.startGesture(const Offset(3, 400), pointer: 11);
    for (var i = 0; i < 14; i++) {
      await gesture.moveBy(Offset(700.0 / 14, 0));
      await tester.pump(const Duration(milliseconds: 16));
    }
    await gesture.up();
    await settle(tester, frames: 16);

    expect(find.byType(StatefulView), findsNothing, reason: '侧滑没有退回上一层');
    expect(find.byType(MenuView), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('暗黑切换在真机上生效', (tester) async {
    app.main();
    await settle(tester, frames: 12);

    expect(
      Theme.of(tester.element(find.byType(MenuView))).brightness,
      Brightness.light,
    );

    await tester.tap(find.byIcon(Icons.dark_mode));
    await settle(tester);
    expect(
      Theme.of(tester.element(find.byType(MenuView))).brightness,
      Brightness.dark,
    );

    await tester.tap(find.byIcon(Icons.light_mode));
    await settle(tester);
    expect(
      Theme.of(tester.element(find.byType(MenuView))).brightness,
      Brightness.light,
    );
    expect(tester.takeException(), isNull);
  });
}