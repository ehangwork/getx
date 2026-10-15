import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:material_ui/material_ui.dart';

/// 上游 #3480-②：
/// `GetLifeCycleMixin.onInit()` 用 post-frame callback 排 `onReady()`，
/// 但回调里没有复查状态。同一帧内创建又被销毁的 controller（重定向、
/// offNamed 链、被替换的路由）会先 `onClose()` 再 `onReady()` ——
/// 本该只对可见页面做的请求照样发了出去。
///
/// 这些用例只需要一个能出帧的 widget 树，所以不套 GetMaterialApp：
/// 它会在 GetRootState.onInit 里留一个零时长 Future，测试收尾时会撞上
/// flutter_test 的 pending-timer 不变量。
void main() {
  setUp(() => Get.testMode = true);
  tearDown(Get.reset);

  Future<void> boot(WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: SizedBox.shrink()),
    );
    await tester.pump();
  }

  testWidgets('同一帧内创建并销毁的 controller 不应在 onClose 之后再触发 onReady',
      (tester) async {
    await boot(tester);

    final log = <String>[];
    Get.put(LifecycleProbe(log));
    Get.delete<LifecycleProbe>(force: true);

    expect(log, ['init', 'close']);

    await tester.pumpWidget(const MaterialApp(home: SizedBox.shrink()));
    await tester.pump();

    expect(
      log,
      ['init', 'close'],
      reason: 'controller 已经销毁，onReady 不该再跑',
    );
  });

  testWidgets('正常存活到下一帧的 controller 仍然会触发 onReady', (tester) async {
    await boot(tester);

    final log = <String>[];
    Get.put(LifecycleProbe(log));

    // 帧外注册的 post-frame callback 不会被下一次 pump 带出来
    // （那时并没有 scheduled frame），得重新出一帧。
    await tester.pumpWidget(const MaterialApp(home: SizedBox.shrink()));
    await tester.pump();

    expect(log, ['init', 'ready']);
  });

  testWidgets('isClosed 已置位时 onReady 被跳过', (tester) async {
    await boot(tester);

    final probe = LifecycleProbe(<String>[]);
    Get.put(probe);

    Get.delete<LifecycleProbe>(force: true);
    expect(probe.isClosed, isTrue);

    await tester.pumpWidget(const MaterialApp(home: SizedBox.shrink()));
    await tester.pump();
    expect(probe.log, ['init', 'close']);
  });
}

class LifecycleProbe extends GetxController {
  LifecycleProbe(this.log);

  final List<String> log;

  @override
  void onInit() {
    super.onInit();
    log.add('init');
  }

  @override
  void onReady() {
    log.add('ready');
  }

  @override
  void onClose() {
    log.add('close');
  }
}
