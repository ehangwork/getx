import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:get_demo/main.dart' as app;
import 'package:get_demo/app/modules/menu/views/menu_view.dart';
import 'package:get_demo/app/modules/stateful/views/stateful_view.dart';
import 'package:get_demo/app/routes/app_pages.dart';
import 'package:get_demo/services/auth_service.dart';
import 'package:material_ui/material_ui.dart';

/// 所有二级页面都必须有返回键。
///
/// 这里的 AppBar 自动返回键是靠 `Navigator.canPop` 决定显不显示的，
/// 而 outlet 的 Navigator 只持有当前分支切片，canPop 恒为 false，
/// 所以每个页面都得显式挂 `GetBackButton`。
void main() {
  Future<void> settle(
    WidgetTester tester, {
    int frames = 8,
    Duration step = const Duration(milliseconds: 120),
  }) async {
    for (var i = 0; i < frames; i++) {
      await tester.pump(step);
    }
  }

  tearDown(Get.reset);

  testWidgets('每个二级页面都有返回键', (tester) async {
    app.main();
    await settle(tester);
    // /profile 有 EnsureAuthMiddleware
    AuthService.to.login();
    await settle(tester, frames: 2);

    // 从示例目录点进去的扁平页面
    const flatRoutes = <String>[
      Routes.stateful,
      Routes.rxTypes,
      Routes.workers,
      Routes.pagination,
      Routes.navigation,
      Routes.transitions,
      Routes.bindings,
      Routes.overlays,
      Routes.instance,
      Routes.lifecycle,
      Routes.home,
      Routes.settings,
      Routes.homeProducts,
    ];

    for (final route in flatRoutes) {
      Get.toNamed(route);
      await settle(tester);
      expect(find.byType(BackButton), findsWidgets,
          reason: '$route 没有返回键');
      Get.back();
      await settle(tester);
    }

    // 最深层的商品详情
    Get.toNamed(Routes.PRODUCT_DETAILS('1'));
    await settle(tester);
    expect(find.byType(BackButton), findsWidgets,
        reason: '/home/products/:id 没有返回键');
    Get.back();
    await settle(tester);

    // 首页三个 tab 都停在 HomeView 的返回键上
    for (final route in [
      Routes.homeDashboard,
      Routes.homeProfile,
      Routes.homeProducts,
    ]) {
      Get.toNamed(route);
      await settle(tester);
      expect(find.byType(BackButton), findsWidgets,
          reason: '$route 没有返回键');
      Get.back();
      await settle(tester);
    }

    // 全部退干净，让 controller 的 Timer 随 onClose 取消
    Get.reset();
    await settle(tester, frames: 2);
  });

  testWidgets('返回键真的能退回上一层', (tester) async {
    app.main();
    await settle(tester);

    Get.toNamed(Routes.stateful);
    await settle(tester);
    expect(find.byType(StatefulView), findsOneWidget);

    await tester.tap(find.byType(BackButton).first);
    await settle(tester, frames: 15);
    expect(find.byType(MenuView), findsOneWidget);
    // 用类型判断页面是否真的卸载了：
    // find.text 会命中移除动画里还没销毁的 Text 节点，不能作为依据
    expect(find.byType(StatefulView), findsNothing);

    Get.reset();
    await settle(tester, frames: 2);
  });
}