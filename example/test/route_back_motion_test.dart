import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:get_demo/app/modules/menu/views/menu_view.dart';
import 'package:get_demo/app/modules/stateful/views/stateful_view.dart';
import 'package:get_demo/app/routes/app_pages.dart';
import 'package:get_demo/services/auth_service.dart';
import 'package:material_ui/material_ui.dart';

/// 返回的手势与动画方向。
///
/// 扁平模块页声明了 `participatesInRootNavigator: true`，
/// 和壳一起待在根 navigator 的真实栈里，所以：
///   - 目标页不再是 isFirst，iOS 侧滑返回才不会被 _isPopGestureEnabled 拦掉
///   - 返回是真正的 pop，页面往右滑，而不是被「推进」动画往左推
///
/// 注意：这些用例跑在 macOS 上，GetPlatform.isIOS 恒为 false，
/// 所以必须显式开 popGesture，否则测的不是真机行为。
void main() {
  Future<void> settle(WidgetTester t, {int frames = 8}) async {
    for (var i = 0; i < frames; i++) {
      await t.pump(const Duration(milliseconds: 120));
    }
  }

  Future<void> boot(WidgetTester tester) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    await tester.pumpWidget(GetMaterialApp(
      initialRoute: AppPages.INITIAL,
      getPages: AppPages.routes,
      binds: [Bind.put(AuthService())],
      popGesture: true,
    ));
    await settle(tester, frames: 8);
  }

  tearDown(() => debugDefaultTargetPlatformOverride = null);

  testWidgets('返回时页面往右滑，不是往左', (WidgetTester tester) async {
    await boot(tester);
    Get.toNamed(Routes.stateful);
    await settle(tester, frames: 14);

    final page = find.byType(StatefulView);
    // 目标页必须在根 navigator 的栈里，而不是 outlet 的唯一一页
    final route = ModalRoute.of(tester.element(page));
    expect(route!.isFirst, isFalse,
        reason: '目标页 isFirst 为 true 时侧滑返回会被 _isPopGestureEnabled 拦掉');

    Get.back();
    final offsets = <double>[];
    for (var i = 0; i < 4; i++) {
      await tester.pump(const Duration(milliseconds: 50));
      if (page.evaluate().isNotEmpty) {
        offsets.add(tester.getTopLeft(page).dx);
      }
    }

    expect(offsets, isNotEmpty, reason: '返回过程中页面已经被移除了');
    expect(offsets.first, closeTo(0, 1), reason: '退场起点应该在原位');
    expect(offsets.last, greaterThan(0),
        reason: '返回应该把页面推向右边，实测 $offsets');

    Get.reset();
    await settle(tester, frames: 2);
    // 必须在用例体内复位：flutter_test 的不变量校验跑在 tearDown 之前
    debugDefaultTargetPlatformOverride = null;
  });

  testWidgets('侧滑超过半屏可以返回', (WidgetTester tester) async {
    await boot(tester);
    Get.toNamed(Routes.stateful);
    await settle(tester, frames: 14);
    expect(find.byType(StatefulView), findsOneWidget);

    final gesture = await tester.startGesture(const Offset(3, 300), pointer: 7);
    for (var i = 0; i < 12; i++) {
      await gesture.moveBy(const Offset(650.0 / 12, 0));
      await tester.pump(const Duration(milliseconds: 16));
    }
    await gesture.up();
    await settle(tester, frames: 14);

    expect(find.byType(StatefulView), findsNothing, reason: '侧滑没有退回上一层');
    expect(find.byType(MenuView), findsOneWidget);

    Get.reset();
    await settle(tester, frames: 2);
    // 必须在用例体内复位：flutter_test 的不变量校验跑在 tearDown 之前
    debugDefaultTargetPlatformOverride = null;
  });

  testWidgets('侧滑不足半屏会弹回，不返回', (WidgetTester tester) async {
    await boot(tester);
    Get.toNamed(Routes.stateful);
    await settle(tester, frames: 14);

    final gesture = await tester.startGesture(const Offset(3, 300), pointer: 9);
    for (var i = 0; i < 6; i++) {
      await gesture.moveBy(const Offset(200.0 / 6, 0));
      await tester.pump(const Duration(milliseconds: 16));
    }
    await gesture.up();
    await settle(tester, frames: 14);

    expect(find.byType(StatefulView), findsOneWidget,
        reason: '没过半屏就松手应该弹回原页');

    Get.reset();
    await settle(tester, frames: 2);
    // 必须在用例体内复位：flutter_test 的不变量校验跑在 tearDown 之前
    debugDefaultTargetPlatformOverride = null;
  });
}