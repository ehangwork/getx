import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:get/get.dart';

import 'package:get_demo/main.dart' as app;
import 'package:get_demo/app/routes/app_pages.dart';

/// 在模拟器 / 真机上把示例的每个模块都走一遍。
///
/// 按模块拆成独立用例：某个模块炸了就能一眼看出是哪一块，
/// 不用在一长串步骤里找失败点。
///
/// 每个用例都会：
/// 1. 检查这一步没有抛 Flutter 异常
/// 2. 断言真的渲染出了预期内容，而不是只做到「没崩」
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  /// dashboard 有 Timer.periodic 在刷时间，pumpAndSettle 会一直等下去，
  /// 所以用固定步长的 pump 代替。
  Future<void> settle(
    WidgetTester tester, {
    int frames = 5,
    Duration step = const Duration(milliseconds: 400),
  }) async {
    for (var i = 0; i < frames; i++) {
      await tester.pump(step);
    }
  }

  void noException(WidgetTester tester, String step) {
    var exception = tester.takeException();
    // 沙箱连不上 flagpedia / wikimedia，背景图解码失败跟 GetX 无关，滤掉
    while (exception is HandshakeException) {
      exception = tester.takeException();
    }
    expect(exception, isNull, reason: '「$step」这一步抛了异常：$exception');
  }

  /// 启动 app，停在示例目录页
  Future<void> boot(WidgetTester tester) async {
    app.main();
    await settle(tester, frames: 8);
    expect(find.text('GetX 示例'), findsOneWidget);
  }

  /// ListView 是懒构建的，屏幕外的条目根本没在树上，find 不到。
  /// 所以先回到顶部，再一段一段往下翻，每翻一下就找一次。
  Future<void> scrollTo(WidgetTester tester, Finder target) async {
    if (target.evaluate().isNotEmpty) return;
    final scrollable = find.byType(Scrollable);
    // 弹层之类的页面本来就没有可滚动容器，交给后面的 findsWidgets 去报错
    if (scrollable.evaluate().isEmpty) return;
    for (var i = 0; i < 8; i++) {
      try {
        await tester.drag(scrollable.first, const Offset(0, -240));
      } catch (_) {
        return; // 弹层盖住了底层列表，拖不动
      }
      await tester.pump(const Duration(milliseconds: 250));
      if (target.evaluate().isNotEmpty) return;
    }
  }

  Future<void> tapText(WidgetTester tester, String label) async {
    final finder = find.text(label);
    await scrollTo(tester, finder);
    expect(finder, findsWidgets, reason: '找不到「$label」');
    await tester.tap(finder.first);
    await settle(tester);
  }

  /// 弹层关掉后列表可能还停在原来的滚动位置，先回到顶部再找条目
  Future<void> scrollToTop(WidgetTester tester) async {
    final scrollable = find.byType(Scrollable);
    if (scrollable.evaluate().isEmpty) return;
    await tester.drag(scrollable.first, const Offset(0, 2000));
    await settle(tester, frames: 3);
  }

  Future<void> goBack(WidgetTester tester) async {
    final back = find.byType(BackButton);
    if (back.evaluate().isNotEmpty) {
      await tester.tap(back.first);
    } else {
      Get.back();
    }
    await settle(tester, frames: 5);
  }

  Future<void> goto(WidgetTester tester, String route, String label) async {
    Get.toNamed(route);
    await settle(tester, frames: 8);
    expect(find.text(label), findsWidgets, reason: '$route 没有渲染出「$label」');
    noException(tester, '跳转到 $route');
  }

  /// 嵌套路由这一段统一用「当前路由」当就位信号：
  /// 壳页的 AppBar 标题是 RouterListener 渲染的当前路由，不是固定的文字
  Future<void> enterHome(WidgetTester tester) async {
    Get.toNamed(Routes.home);
    await settle(tester, frames: 10);
    expect(find.text(Routes.home), findsWidgets,
        reason: '进入 $Routes.home 后没有拿到当前路由');
    noException(tester, '进入 /home');
  }

  tearDown(Get.reset);

  testWidgets('目录页', (tester) async {
    await boot(tester);
    for (final entry in const [
      'GetX / GetBuilder / Obx', 'Rx 类型', 'Worker', 'ScrollMixin 分页',
      '路由跳转', '路由过渡', '嵌套路由',
      '浮层', '依赖绑定', '实例管理', 'App 生命周期',
      'StateController + futurize',
    ]) {
      await scrollTo(tester, find.text(entry));
      expect(find.text(entry), findsWidgets, reason: '目录里少了「$entry」');
    }
    noException(tester, '目录页');
  });

  testWidgets('响应式：GetX / GetBuilder / Obx', (tester) async {
    await boot(tester);
    await tapText(tester, 'GetX / GetBuilder / Obx');

    expect(find.text('GetX<CounterController>'), findsOneWidget);
    expect(find.text('GetBuilder<CounterController>'), findsOneWidget);
    expect(find.text('Obx'), findsOneWidget);

    await tapText(tester, '+1');
    expect(find.textContaining('count: 1'), findsWidgets);

    // 按钮走的是 update(['even'], evenOnly.value.isEven)：
    // 0→1 是奇数，按设计就不刷新；再点一次到 2 才会重建
    await tapText(tester, '+1 (只刷新 even)');
    expect(find.textContaining('even: 0'), findsOneWidget);
    await tapText(tester, '+1 (只刷新 even)');
    expect(find.textContaining('even: 2'), findsOneWidget);
    noException(tester, 'GetX / GetBuilder / Obx');
  });

  testWidgets('响应式：Rx 类型', (tester) async {
    await boot(tester);
    await tapText(tester, 'Rx 类型');
    await tapText(tester, 'bump');
    await tapText(tester, 'mutate');
    noException(tester, 'Rx 类型');
  });

  testWidgets('响应式：Worker', (tester) async {
    await boot(tester);
    await tapText(tester, 'Worker');
    await tapText(tester, '+1');
    await settle(tester, frames: 10);
    noException(tester, 'Worker');
  });

  testWidgets('响应式：ScrollMixin 分页', (tester) async {
    await boot(tester);
    await tapText(tester, 'ScrollMixin 分页');
    final before = tester.widgetList(find.byType(ListTile)).length;
    for (var i = 0; i < 3; i++) {
      await tester.drag(find.byType(Scrollable).first, const Offset(0, -700));
      await settle(tester, frames: 8);
    }
    final after = tester.widgetList(find.byType(ListTile)).length;
    expect(after, greaterThan(before), reason: '滚到底没有加载出下一页');
    noException(tester, 'ScrollMixin 分页');
  });

  testWidgets('浮层：Snackbar / Dialog / BottomSheet', (tester) async {
    await boot(tester);
    await tapText(tester, '浮层');

    await tapText(tester, 'Get.snackbar');
    await tapText(tester, 'Get.rawSnackbar');
    await tapText(tester, 'Get.rawSnackbar + closeCurrentSnackbar');

    await tapText(tester, 'Get.dialog');
    expect(find.text('这是通过 Get.dialog 打开的自定义内容。'), findsOneWidget);
    await tapText(tester, '关闭');

    await tapText(tester, 'Get.defaultDialog');
    expect(find.text('defaultDialog'), findsOneWidget);
    expect(find.text('确认要继续吗？'), findsOneWidget);
    await tapText(tester, '确定');
    // 5.0-rc 的 defaultDialog 点确定 / 取消都不会自动关闭，只能点屏障
    expect(find.text('defaultDialog'), findsOneWidget);
    await tester.tapAt(const Offset(20, 20));
    await settle(tester);
    expect(find.text('defaultDialog'), findsNothing);

    await tapText(tester, 'Get.defaultDialog + content');
    expect(find.text('选项一'), findsOneWidget);
    await tapText(tester, '选项一');

    await tapText(tester, 'Get.bottomSheet');
    expect(find.text('选一个数字'), findsOneWidget);
    await tapText(tester, '1');
    await settle(tester, frames: 6);
    await scrollToTop(tester);

    await tapText(tester, 'Get.bottomSheet + 立即再弹一条');
    await settle(tester, frames: 3);
    expect(find.text('选一个数字'), findsOneWidget);
    await tapText(tester, '2');
    noException(tester, '浮层');
  });

  testWidgets('依赖绑定', (tester) async {
    await boot(tester);
    await tapText(tester, '依赖绑定');
    expect(find.text('Bind.put / Bind.lazyPut / Bind.spawn'), findsOneWidget);
    await tester.tap(find.byType(FloatingActionButton));
    await settle(tester);
    noException(tester, '依赖绑定');
  });

  testWidgets('实例管理', (tester) async {
    await boot(tester);
    await tapText(tester, '实例管理');
    for (final label in const [
      'isRegistered', 'put', 'put permanent',
      'put 带 tag', 'find 带 tag', 'delete', 'deleteAll',
    ]) {
      await tapText(tester, label);
    }
    expect(find.byType(ListTile), findsWidgets);

    expect(find.byType(ListTile), findsWidgets);

    // deleteAll / reset 会把本页 controller 一起清掉，页面应自动重新注册而不是崩
    await tapText(tester, 'reset');
    await settle(tester, frames: 8);
    expect(find.byType(ListTile), findsWidgets);
    noException(tester, '实例管理');
  });

  testWidgets('App 生命周期', (tester) async {
    await boot(tester);
    await tapText(tester, 'App 生命周期');
    expect(find.text('onResumed'), findsOneWidget);
    expect(find.text('onMemoryPressure'), findsOneWidget);
    noException(tester, 'App 生命周期');
  });

  testWidgets('数据层：StateController + futurize', (tester) async {
    await boot(tester);
    await tapText(tester, 'StateController + futurize');
    await settle(tester, frames: 20);
    // 数据来自公网 https://nobels.jonatasdev.workers.dev，
    // 走不通时应该落到 onError 分支，而不是卡在 loading 或者崩掉
    final list = find.byType(ListTile);
    final error = find.textContaining('Error:');
    expect(
      list.evaluate().isNotEmpty || error.evaluate().isNotEmpty,
      isTrue,
      reason: '列表既没出来也没进 onError，StateController 的三态有问题',
    );
    noException(tester, '国家列表');
  });

  testWidgets('路由跳转', (tester) async {
    await boot(tester);
    await tapText(tester, '路由跳转');

    await tapText(tester, 'Get.to');
    expect(find.text('返回并回传结果'), findsOneWidget);
    await goBack(tester);

    await tapText(tester, 'Get.toNamed');
    expect(find.text('返回并回传结果'), findsOneWidget);
    await goBack(tester);

    await tapText(tester, 'Get.toNamed + arguments');
    expect(find.textContaining('Get.arguments ='), findsOneWidget);
    expect(find.textContaining('toNamed'), findsWidgets);
    await goBack(tester);

    await tapText(tester, 'Get.toNamed + parameters');
    expect(find.text('返回并回传结果'), findsOneWidget);
    await goBack(tester);
    await scrollToTop(tester);

    await tapText(tester, 'Get.off');
    expect(find.text('inline target'), findsOneWidget);
    await goBack(tester);
    await scrollToTop(tester);

    await tapText(tester, 'Get.offNamed');
    expect(find.text('返回并回传结果'), findsOneWidget);
    await goBack(tester);

    await tapText(tester, 'Get.offAll');
    expect(find.text('inline target'), findsOneWidget);
    await goBack(tester);

    await tapText(tester, 'Get.offAllNamed');
    expect(find.text('GetX 示例'), findsOneWidget);
    noException(tester, '路由跳转');
  });

  testWidgets('路由过渡：16 种逐个点', (tester) async {
    await boot(tester);
    await tapText(tester, '路由过渡');
    for (final transition in const [
      'fade', 'fadeIn', 'rightToLeft', 'leftToRight',
      'upToDown', 'downToUp', 'rightToLeftWithFade', 'leftToRightWithFade',
      'zoom', 'topLevel', 'noTransition', 'cupertino',
      'cupertinoDialog', 'size', 'circularReveal', 'native',
    ]) {
      await tapText(tester, transition);
      expect(
        find.text('返回并回传结果'),
        findsOneWidget,
        reason: '过渡 $transition 没有把目标页推上来',
      );
      await goBack(tester);
      noException(tester, '过渡 $transition');
    }
  });

  testWidgets('嵌套路由：tab 切换与三级下钻', (tester) async {
    await boot(tester);
    await enterHome(tester);

    // /home/profile 有 EnsureAuthMiddleware，未登录会被弹到登录页，
    // 所以先登录，后面切 tab 才不会被弹走
    await tapText(tester, 'Profile');
    expect(find.text('Do LOGIN !!'), findsOneWidget);
    await tapText(tester, 'Do LOGIN !!');
    await settle(tester, frames: 10);
    await enterHome(tester);

    await tapText(tester, 'Profile');
    expect(find.text('Show a test dialog'), findsOneWidget);
    noException(tester, '切到 profile');

    await tapText(tester, 'Products');
    await settle(tester, frames: 6);
    final tiles = find.byType(ListTile);
    expect(tiles, findsWidgets, reason: 'products 列表没渲染出来');
    await tester.tap(tiles.first);
    await settle(tester, frames: 10);
    expect(
      find.textContaining('ProductId:'),
      findsOneWidget,
      reason: '三级下钻 /home/products/:id 没渲染出详情页',
    );
    noException(tester, '三级下钻到商品详情');
    await goBack(tester);

    await tapText(tester, 'Home');
    await settle(tester, frames: 6);
    noException(tester, '回到 dashboard');
  });

  testWidgets('嵌套路由：中间件拦截 + 登录回跳', (tester) async {
    await boot(tester);
    await enterHome(tester);

    await tapText(tester, 'Profile');
    await settle(tester, frames: 10);
    expect(
      find.text('Do LOGIN !!'),
      findsOneWidget,
      reason: '未登录访问 /home/profile 应当被 EnsureAuthMiddleware 弹到登录页',
    );
    noException(tester, '中间件拦截');

    await tapText(tester, 'Do LOGIN !!');
    await settle(tester, frames: 10);
    expect(find.text('Logged In'), findsWidgets);
    noException(tester, '登录后跳回 home');
  });

  testWidgets('嵌套路由：壳内切到别的子树', (tester) async {
    await boot(tester);
    await enterHome(tester);
    await tapText(tester, 'Products');
    await settle(tester, frames: 6);

    await goto(tester, Routes.settings, 'SettingsView is working');
    noException(tester, '嵌套壳切到 /settings');
  });
}
