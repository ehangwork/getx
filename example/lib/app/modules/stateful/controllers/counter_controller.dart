import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

/// 一个 controller 同时供三种订阅方式使用，用来直观对比它们的差别。
class CounterController extends GetxController {
  /// GetBuilder 监听的是 controller 的 update()，字段本身可以不是 Rx
  int builderCount = 0;

  /// Obx 与 GetX 监听的是 Rx 变量本身，与 update() 无关
  final obxCount = 0.obs;
  final getxCount = 0.obs;

  /// 带 id 的更新可以只刷新订阅了同一个 id 的那些 GetBuilder
  final evenOnly = 0.obs;

  @override
  void onInit() {
    super.onInit();
    debugPrint('CounterController onInit');
  }

  @override
  void onClose() {
    debugPrint('CounterController onClose');
    super.onClose();
  }

  void incrementByBuilder() {
    builderCount++;
    update();
  }

  void incrementByObx() => obxCount.value++;

  void incrementByGetX() => getxCount.value++;

  void incrementEven() {
    evenOnly.value++;
    // 只把带 'even' 这个 id 的 GetBuilder 标记为需要重建
    update(['even'], evenOnly.value.isEven);
  }
}
