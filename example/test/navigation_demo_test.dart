import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:get_demo/app/modules/home/views/home_view.dart';
import 'package:get_demo/app/modules/menu/views/menu_view.dart';
import 'package:get_demo/app/modules/rx_types/views/rx_types_view.dart';
import 'package:get_demo/app/modules/stateful/controllers/counter_controller.dart';
import 'package:get_demo/app/modules/stateful/views/stateful_view.dart';
import 'package:get_demo/app/modules/navigation/views/navigation_target_view.dart';
import 'package:get_demo/app/modules/transitions/views/transitions_view.dart';
import 'package:get_demo/app/routes/app_pages.dart';
import 'package:get_demo/main.dart';
import 'package:material_ui/material_ui.dart';

/// 目录页里的两个入口，以及跳转演示页的实际行为。
void main() {
  Future<void> settle(WidgetTester tester, {int frames = 10}) async {
    for (var i = 0; i < frames; i++) {
      await tester.pump(const Duration(milliseconds: 120));
    }
  }

  tearDown(Get.reset);

  testWidgets('「嵌套路由」入口要真的跳进去', (WidgetTester tester) async {
    await tester.pumpWidget(const GetDemoApp());
    await tester.pump();
    await settle(tester);

    await tester.scrollUntilVisible(find.text('嵌套路由'), 200);
    await tester.pumpAndSettle();
    await tester.tap(find.text('嵌套路由'));
    await settle(tester, frames: 12);

    expect(find.byType(HomeView), findsOneWidget,
        reason: '入口指到 Routes.root 的话是空操作（/ 已经是当前路由且 '
            'preventDuplicates 为 true），点进去什么都没发生');

    // 返回键要能退回目录
    await tester.tap(find.byType(BackButton).first);
    await settle(tester, frames: 12);
    expect(find.byType(MenuView), findsOneWidget);
  });

  testWidgets('Get.to 推的匿名页要盖在当前页之上', (WidgetTester tester) async {
    await tester.pumpWidget(const GetDemoApp());
    await tester.pump();
    await settle(tester);

    Get.toNamed(Routes.transitions);
    await settle(tester);
    expect(find.byType(TransitionsView), findsOneWidget);

    Get.to(() => const NavigationTargetView(label: 'inline'));
    await settle(tester, frames: 12);

    expect(find.text('inline'), findsOneWidget);
    expect(
      find.text('inline').hitTestable(),
      findsOneWidget,
      reason: '匿名页落进了 outlet，藏在当前页底下，用户看不到',
    );

    Get.back();
    await settle(tester, frames: 6);
  });

  testWidgets('从 outlet 页 Get.to 也要盖在当前页之上', (WidgetTester tester) async {
    await tester.pumpWidget(const GetDemoApp());
    await tester.pump();
    await settle(tester);

    Get.toNamed(Routes.home);
    await settle(tester, frames: 12);
    Get.toNamed(Routes.homeDashboard);
    await settle(tester, frames: 12);
    expect(find.text('DashboardView is working'), findsOneWidget);

    Get.to(() => const NavigationTargetView(label: 'sheet-ish'));
    await settle(tester, frames: 12);
    expect(find.text('sheet-ish').hitTestable(), findsOneWidget,
        reason: 'outlet 页上推的匿名页没盖住当前页');

    Get.back();
    await settle(tester, frames: 6);
  });

  testWidgets('导航演示的每个入口都要有反应', (WidgetTester tester) async {
    await tester.pumpWidget(const GetDemoApp());
    await tester.pump();
    await settle(tester);

    // Get.toNamed('.../transition-target') 是命名顶层页
    Get.toNamed(Routes.transitions);
    await settle(tester);
    Get.toNamed(Routes.navigation);
    await settle(tester, frames: 12);

    await tester.tap(find.text('Get.to'));
    await settle(tester, frames: 12);
    expect(find.text('目标页'), findsOneWidget,
        reason: 'Get.to 没跳过去');
    Get.back();
    await settle(tester, frames: 6);

    await tester.tap(find.text('Get.toNamed'));
    await settle(tester, frames: 12);
    expect(find.text('目标页'), findsOneWidget,
        reason: 'Get.toNamed 没跳过去');
  });

  testWidgets('连压两层不能把第一层挤掉', (WidgetTester tester) async {
    await tester.pumpWidget(const GetDemoApp());
    await tester.pump();
    await settle(tester);

    Get.toNamed(Routes.stateful);
    await settle(tester);
    expect(find.byType(StatefulView), findsOneWidget);

    Get.toNamed(Routes.rxTypes);
    await settle(tester, frames: 12);
    expect(find.byType(RxTypesView), findsOneWidget);

    // 第一层被上层不透明路由盖住时会 offstage，
    // 所以断言它的 controller 还在，而不是断言 widget 还在树上
    expect(Get.isRegistered<CounterController>(), isTrue,
        reason: '压第二层时第一层被销毁了，返回过去会是重新创建');

    Get.back();
    await settle(tester, frames: 12);
    expect(find.byType(StatefulView), findsOneWidget,
        reason: '返回没有回到第一层');
  });
}
