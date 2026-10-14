import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:get_demo/app/routes/app_pages.dart';
import 'package:get_demo/main.dart';
import 'package:get_demo/services/auth_service.dart';
import 'package:material_ui/material_ui.dart';

/// bottomSheet 必须出现在当前页之上。
///
/// 当前页有两种位置：
///   - 声明了 participatesInRootNavigator 的扁平页，在根 navigator 的真实栈里
///   - 其余页面在壳的 outlet 里
///
/// 之前只认「最后构建的 outlet」，而壳的 outlet 被根层盖住时仍然在构建，
/// 于是在扁平页上弹层被推进了底下那层，用户完全看不到。
void main() {
  Future<void> settle(WidgetTester tester, {int frames = 8}) async {
    for (var i = 0; i < frames; i++) {
      await tester.pump(const Duration(milliseconds: 120));
    }
  }

  Future<void> boot(WidgetTester tester) async {
    await tester.pumpWidget(const GetDemoApp());
    await tester.pump();
    await settle(tester);
  }

  tearDown(Get.reset);

  testWidgets('扁平页上弹 bottomSheet 要盖在当前页之上', (WidgetTester tester) async {
    await boot(tester);

    Get.toNamed(Routes.overlays);
    await settle(tester, frames: 12);
    expect(find.text('浮层'), findsWidgets);

    Get.bottomSheet(const _Sheet());
    await settle(tester, frames: 4);

    expect(find.text('SHEET_MARK'), findsOneWidget, reason: 'bottomSheet 没展示出来');
    expect(
      find.text('SHEET_MARK').hitTestable(),
      findsOneWidget,
      reason: 'bottomSheet 推出了当前页所在的 navigator，被页面挡住了',
    );

    Get.back();
    await settle(tester, frames: 4);
  });

  testWidgets('outlet 页上弹 bottomSheet 仍推进 outlet', (WidgetTester tester) async {
    await boot(tester);
    AuthService.to.login();

    Get.toNamed(Routes.home);
    await settle(tester, frames: 12);
    Get.toNamed(Routes.homeDashboard);
    await settle(tester, frames: 12);
    expect(find.text('DashboardView is working'), findsOneWidget);

    Get.bottomSheet(const _Sheet());
    await settle(tester, frames: 4);

    expect(find.text('SHEET_MARK'), findsOneWidget);
    expect(find.text('SHEET_MARK').hitTestable(), findsOneWidget,
        reason: 'outlet 页的弹层没盖在当前页上');

    Get.back();
    await settle(tester, frames: 4);
  });
}

class _Sheet extends StatelessWidget {
  const _Sheet();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('SHEET_MARK')),
    );
  }
}