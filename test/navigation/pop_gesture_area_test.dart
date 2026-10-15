import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:get/get.dart';

/// iOS 侧滑返回的触发区域。
///
/// 默认触发带 44pt（Apple HIG 最小可点击区域），不是 Flutter 原生的 20 ——
/// 20 忠实于原生但不够灵敏，落点差十几像素就静默失败。
///
/// `GetPageRouteTransitionMixin.buildPageTransitions` 的 `limitedSwipe` 默认 false，
/// 手势检测器就用 `Positioned.fill` 铺满整页 —— 页面上任何位置横向拖动都会触发
/// 返回，横滑 ListView / 轮播 / 滑块也会被抢走手势，比 iOS 原生灵敏得多。
///
/// 只在屏幕起始边缘的一条带内响应（默认 44pt，刘海屏按安全区加宽），
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
    expect(pos.width, 44,
        reason: '默认取 HIG 最小可点击区域 44pt；GetPage.gestureWidth 可逐页调');
  });

  testWidgets('触发带加宽到 44 后仍不能挡住 AppBar 返回键的点击', (tester) async {
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

    // 返回键中心大约落在 x=24，稳稳位于 44pt 触发带内
    await tester.tap(find.byIcon(Icons.arrow_back));
    await _settle(tester);

    expect(tapped, isTrue, reason: '触发带不该吞掉返回键的点击');
    expect(find.text('home-body'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('从页面中间起手横向拖动不应触发返回', (tester) async {
    await pushSecond(tester);
    expect(find.text('second-body'), findsOneWidget);

    // 测试视口 800x600：正中 400 起手，往右拖 600（0.75 屏宽，超过 0.5 的 pop 阈值）
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
    expect(pos.width, 44);
  });
}
