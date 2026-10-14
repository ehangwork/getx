import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/src/simple/list_notifier.dart';

void main() {
  tearDown(Get.reset);

  group('Notifier.append 全局状态复位', () {
    test('builder 抛异常后不再把 listener 挂到失效的 Obx 上', () {
      final rx = 0.obs;
      expect(rx.listenersLength, 0);

      expect(
        () => Notifier.instance.append(
          NotifyData(updater: () {}, disposers: <VoidCallback>[]),
          () => throw StateError('builder boom'),
        ),
        throwsStateError,
      );

      // 全局状态没复位的话，这里的 read 会把 listener 挂进 rx
      Notifier.instance.read(rx);
      expect(rx.listenersLength, 0);
    });

    test('builder 抛 ObxError 时同样复位', () {
      final rx = 0.obs;

      expect(
        () => Notifier.instance.append(
          NotifyData(updater: () {}, disposers: <VoidCallback>[]),
          () => const SizedBox.shrink(),
        ),
        throwsA(isA<ObxError>()),
      );

      Notifier.instance.read(rx);
      expect(rx.listenersLength, 0);
    });
  });

  group('刷新通知不应打到已失效的 element', () {
    testWidgets('Obx 卸载后原 Rx 再变更不产生任何异常', (tester) async {
      final rx = 0.obs;

      await tester.pumpWidget(MaterialApp(
        home: Obx(() => Text('${rx.value}')),
      ));
      expect(find.text('0'), findsOneWidget);
      expect(rx.listenersLength, greaterThan(0));

      await tester.pumpWidget(const MaterialApp(home: SizedBox.shrink()));
      // unmount 已解绑，监听数归零
      expect(rx.listenersLength, 0);

      rx.value = 99;
      await tester.pump();

      expect(tester.takeException(), isNull);
      expect(rx.listenersLength, 0);
    });

    testWidgets('GetBuilder 在 build 期间同步 update 不触发 markNeedsBuild 断言',
        (tester) async {
      final controller = Get.put(_Counter());

      await tester.pumpWidget(MaterialApp(
        home: GetBuilder<_Counter>(
          init: controller,
          builder: (c) {
            // 在 build 期间同步通知，刷新请求会立刻打回 GetBuilder 自己
            if (c.count.value == 0) {
              c.count.value = 1;
              c.update();
            }
            return Text('${c.count.value}');
          },
        ),
      ));
      await tester.pump();

      expect(tester.takeException(), isNull);
      expect(controller.count.value, 1);
    });

    testWidgets('GetBuilder 的刷新仍然生效', (tester) async {
      final controller = Get.put(_Counter());

      await tester.pumpWidget(MaterialApp(
        home: GetBuilder<_Counter>(
          init: controller,
          builder: (c) => Text('${c.count.value}'),
        ),
      ));
      expect(find.text('0'), findsOneWidget);

      controller.count.value = 7;
      controller.update();
      await tester.pump();

      expect(find.text('7'), findsOneWidget);
    });
  });
}

class _Counter extends GetxController {
  final count = 0.obs;
}
