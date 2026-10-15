import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:get/get.dart';

/// iOS 侧滑返回的触发区域。
///
/// 触发带 24pt，刻意比 Flutter 原生的 20 略宽一点，但不再往宽走 ——
/// 手势层是页面的前置兄弟节点，带内必然压过横向滚动组件（Flutter 原生同款结构、
/// 同样毛病），加宽会把横滑列表变成死区。灵敏度改从「松手提交」阈值上找。
///
/// `GetPageRouteTransitionMixin.buildPageTransitions` 的 `limitedSwipe` 默认 false，
/// 手势检测器就用 `Positioned.fill` 铺满整页 —— 页面上任何位置横向拖动都会触发
/// 返回，横滑 ListView / 轮播 / 滑块也会被抢走手势，比 iOS 原生灵敏得多。
///
/// 只在屏幕起始边缘的一条带内响应（默认 24pt，刘海屏按安全区加宽），
/// 宽度可通过 GetPage 的 `gestureWidth` 逐页调整。

class HomeBody extends StatelessWidget {
  const HomeBody({super.key});
  @override
  Widget build(BuildContext context) =>
      Scaffold(body: Center(child: Text('home-body')));
}

class SecondBody extends StatelessWidget {
  const SecondBody({super.key});
  @override
  Widget build(BuildContext context) =>
      Scaffold(body: Center(child: Text('second-body')));
}

/// GetBackGestureDetector 是泛型 widget，运行时类型取决于路由的 T
/// （GetPage 不带泛型时是 <dynamic>），find.byType 精确匹配会漏，
/// 所以按 is 谓词找。
final _detector = find.byWidgetPredicate((w) => w is GetBackGestureDetector);

Future<void> _settle(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 700));
  await tester.pump(const Duration(milliseconds: 1500));
}

void main() {
  setUp(() => Get.testMode = true);
  tearDown(Get.reset);

  // popGesture: true 是必须的：canSwipe 读的是
  // route.popGesture ?? Get.defaultPopGesture ?? GetPlatform.isIOS，
  // 而 GetPlatform.isIOS 在 macOS 上恒为 false。
  Future<void> pushSecond(WidgetTester tester) async {
    await tester.pumpWidget(GetMaterialApp(
      popGesture: true,
      initialRoute: '/home',
      getPages: [
        GetPage(name: '/home', page: () => const HomeBody()),
        GetPage(name: '/second', page: () => const SecondBody()),
      ],
    ));
    await _settle(tester);
    Get.toNamed('/second');
    await _settle(tester);
  }

  testWidgets('手势检测器只覆盖起始边缘一条，不是整页', (tester) async {
    await pushSecond(tester);

    final detector = tester
        .widget<GetBackGestureDetector<Object?>>(
          _detector.last,
        );
    expect(
      detector.limitedSwipe,
      isTrue,
      reason: 'limitedSwipe 为 false 时手势区是 Positioned.fill，整页都能触发返回',
    );

    final strip = find.descendant(
      of: _detector.last,
      matching: find.byType(PositionedDirectional),
    );
    expect(strip, findsOneWidget,
        reason: '边缘受限时应渲染一块贴在起始边的 PositionedDirectional');

    final pos = tester.widget<PositionedDirectional>(strip);
    expect(pos.start, 0, reason: '应贴在起始边');
    expect(pos.width, 24,
        reason: '刻意保持窄：手势层是页面前置兄弟节点，带内必然压过横向组件，'
            '加宽会把横滑列表变成死区');
  });

  testWidgets('触发带不能挡住 AppBar 返回键的点击', (tester) async {
    // 触发带与返回键在屏幕上重叠（返回键大致横跨 x=8~56），靠的是
    // HitTestBehavior.translucent —— 底层 widget 照样能收到点击。
    var tapped = false;
    await tester.pumpWidget(GetMaterialApp(
      popGesture: true,
      initialRoute: '/home',
      getPages: [
        GetPage(name: '/home', page: () => const HomeBody()),
        GetPage(
          name: '/second',
          page: () => Scaffold(
            appBar: AppBar(
              leading: Builder(
                builder: (context) => IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () {
                    tapped = true;
                    Get.back();
                  },
                ),
              ),
            ),
            body: const Center(child: Text('second-body')),
          ),
        ),
      ],
    ));
    await _settle(tester);
    Get.toNamed('/second');
    await _settle(tester);

    // 返回键中心大约落在 x=24，正好压在 24pt 触发带上
    await tester.tap(find.byIcon(Icons.arrow_back));
    await _settle(tester);

    expect(tapped, isTrue, reason: '触发带不该吞掉返回键的点击');
    expect(find.text('home-body'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('从页面中间起手横向拖动不应触发返回', (tester) async {
    await pushSecond(tester);
    expect(find.text('second-body'), findsOneWidget);

    // 测试视口 800x600：正中 400 起手往右拖，落点离边缘远到不该进手势带
    await tester.dragFrom(const Offset(400, 300), const Offset(600, 0));
    await _settle(tester);

    expect(find.text('second-body'), findsOneWidget,
        reason: '整页任意位置都能起手侧滑，就是「太灵敏」的根因');
  });

  testWidgets('从左边缘起手仍应能侧滑返回（不能把原生行为一起砍掉）', (tester) async {
    await pushSecond(tester);

    await tester.dragFrom(const Offset(5, 300), const Offset(700, 0));
    await _settle(tester);

    expect(find.text('home-body'), findsOneWidget);
    expect(find.text('second-body'), findsNothing);
  });

  testWidgets('RTL 下手势区应贴在右边缘', (tester) async {
    await tester.pumpWidget(GetMaterialApp(
      popGesture: true,
      initialRoute: '/home',
      locale: const Locale('ar', 'DZ'),
      getPages: [
        GetPage(name: '/home', page: () => const HomeBody()),
        GetPage(name: '/second', page: () => const SecondBody()),
      ],
    ));
    await _settle(tester);
    Get.toNamed('/second');
    await _settle(tester);

    final pos = tester.widget<PositionedDirectional>(
      find.descendant(
        of: _detector.last,
        matching: find.byType(PositionedDirectional),
      ),
    );
    // PositionedDirectional 的 start=0 在 RTL 下就是从右往左量的 0，即右边缘。
    expect(pos.start, 0);
    expect(pos.width, 24);
  });

  // 「不灵敏」拆成两半：起手难（受触发带宽度限制，会和横滑组件抢手势，只能收窄）
  // 与提交难（拖了快一半松手却弹回去）。后半截与横滑组件零冲突，是灵敏度真正的来源。
  //
  // 不通过合成手势测：testWidgets 的 fake-async 下，timedDragFrom 的拖动在竞技场里
  // 要拖到指针抬起才被默认裁决接收，期间 controller.value 一直是 1.0，位移判定根本
  // 走不到（实测 8 组参数无一命中）。改为直接驱动 GetBackGestureController.dragEnd
  // —— 它就是判定的全部逻辑，要么 Get.back()，要么 animateTo(1.0) 弹回。
  group('松手提交的灵敏度', () {
    // dragUpdate 的入参是「拖过的屏幕比例」，value 从 1.0 递减；
    // dragEnd 的入参是「屏宽/秒」。
    Future<GetBackGestureController<dynamic>> arm(WidgetTester tester) async {
      await pushSecond(tester);
      // find.byType(Navigator) 比的是 runtimeType 全等，而 Navigator 的类型参数
      // 取决于路由，这里直接拿 delegate 上的 key。
      final nav = Get.rootController.rootDelegate.navigatorKey.currentState!;
      final ctl = AnimationController(vsync: const TestVSync(), value: 1.0);
      addTearDown(ctl.dispose);
      return GetBackGestureController<dynamic>(navigator: nav, controller: ctl);
    }

    testWidgets('慢拖到 45% 松手应确认返回（Flutter 原生要求 50%）', (tester) async {
      final back = await arm(tester);

      back.dragUpdate(0.45); // value: 1.0 -> 0.55
      back.dragEnd(0.375); // 低于甩动阈值，按位移判定

      await _settle(tester);
      expect(find.text('home-body'), findsOneWidget,
          reason: '拖到 45% 松手就该返回，弹回去正是「滑不动」体感的主因');
    });

    testWidgets('慢拖到 30% 仍应弹回 —— 不能一路放宽成乱返回', (tester) async {
      final back = await arm(tester);

      back.dragUpdate(0.30); // value: 1.0 -> 0.70
      back.dragEnd(0.375);

      await _settle(tester);
      expect(find.text('second-body'), findsOneWidget, reason: '提交阈值是 0.4');
      expect(find.text('home-body'), findsNothing);
    });

    testWidgets('速度介于原生阈值 1.0 与新阈值 0.5 之间时应确认返回', (tester) async {
      final back = await arm(tester);

      back.dragUpdate(0.35); // value: 0.65，位置不够（原生要求拖过半屏）
      back.dragEnd(0.7); // 0.7 屏/秒：原生阈值 1.0 够不到，会退回位移判定判为取消

      await _settle(tester);
      expect(find.text('home-body'), findsOneWidget,
          reason: '一次有意识的甩动不该因为速度差一点就被忽略');
    });

    testWidgets('速度够但方向是「回推页面」时应弹回', (tester) async {
      final back = await arm(tester);

      back.dragUpdate(0.35);
      back.dragEnd(-0.7); // 负速度 = 把页面往回推

      await _settle(tester);
      expect(find.text('second-body'), findsOneWidget);
    });
  });
}
