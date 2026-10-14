import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:get/get.dart';

class CounterController extends GetxController {
  /// Rx 字段：给 Obx / GetX 读
  final rxCount = 0.obs;

  /// 普通字段：只有 controller.update() 才能刷新
  int plain = 0;

  void bumpRx() => rxCount.value++;
  void bumpPlain() {
    plain++;
    update();
  }
}

void main() {
  tearDown(Get.reset);

  testWidgets('GetX<T> 的 builder 只读普通字段时不应报 ObxError', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: GetX<CounterController>(
          init: CounterController(),
          builder: (controller) => Text('plain: ${controller.plain}'),
        ),
      ),
    ));
    await tester.pump();

    expect(tester.takeException(), isNull);
    expect(find.text('plain: 0'), findsOneWidget);

    // 没有 Rx 读，GetX 靠 controller.update() 刷新
    Get.find<CounterController>().bumpPlain();
    await tester.pumpAndSettle();

    expect(find.text('plain: 1'), findsOneWidget);
  });

  testWidgets('GetX<T> 的 builder 读 Rx 时仍然自动重建', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: GetX<CounterController>(
          init: CounterController(),
          builder: (controller) => Text('rx: ${controller.rxCount.value}'),
        ),
      ),
    ));
    await tester.pump();
    expect(find.text('rx: 0'), findsOneWidget);

    Get.find<CounterController>().bumpRx();
    await tester.pumpAndSettle();

    expect(find.text('rx: 1'), findsOneWidget);
  });

  testWidgets('Obx 里没读到 Rx 时仍然要报 ObxError', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: Obx(() => const Text('没有任何 Rx 读取')),
      ),
    ));
    await tester.pump();

    // ObxError 不是公开类型，按错误文案断言这条约定仍然生效
    final exception = tester.takeException();
    expect(exception, isNotNull);
    expect('$exception', contains('improper use of a GetX'));
  });
}
