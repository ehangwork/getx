import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

void main() {
  tearDown(Get.reset);

  group('Get.reset 生命周期收尾', () {
    test('会触发 GetxController.onClose', () {
      var closeCount = 0;

      Get.put(_Controller(onCloseCallback: () => closeCount++));
      expect(closeCount, 0);

      Get.reset();

      expect(closeCount, 1);
      expect(Get.isRegistered<_Controller>(), isFalse);
    });

    test('会关闭标记为 permanent 的实例', () {
      var closeCount = 0;

      Get.put(_Controller(onCloseCallback: () => closeCount++),
          permanent: true);

      Get.reset();

      expect(closeCount, 1);
    });

    test('会关闭 GetxService', () {
      var closeCount = 0;

      Get.put(_Service(onCloseCallback: () => closeCount++));

      Get.reset();

      expect(closeCount, 1);
    });

    test('同一实例注册多个 tag 时 onClose 只触发一次', () {
      var closeCount = 0;
      final controller = _Controller(onCloseCallback: () => closeCount++);

      Get.put(controller);
      Get.put(controller, tag: 'second');

      Get.reset();

      expect(closeCount, 1);
    });

    test('reset 后 controller 标记为已关闭', () {
      final controller = Get.put(_Controller());

      Get.reset();

      expect(controller.isClosed, isTrue);
    });
  });
}

class _Controller extends GetxController {
  _Controller({this.onCloseCallback});

  final void Function()? onCloseCallback;



  @override
  void onClose() {
    onCloseCallback?.call();
    super.onClose();
  }
}

class _Service extends GetxService {
  _Service({this.onCloseCallback});

  final void Function()? onCloseCallback;

  @override
  void onClose() {
    onCloseCallback?.call();
    super.onClose();
  }
}
