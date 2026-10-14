import 'package:get/get.dart';

/// FullLifeCycle 让 controller 能感知 App 的前后台切换、锁屏、内存告警
/// 与无障碍开关变化，这些回调在普通 GetxController 里是拿不到的。
class LifecycleController extends FullLifeCycleController with FullLifeCycleMixin {
  final events = <String>[].obs;

  @override
  void onInit() {
    super.onInit();
    _record('onInit');
  }

  @override
  void onClose() {
    _record('onClose');
    super.onClose();
  }

  @override
  void onResumed() => _record('onResumed —— 回到前台');

  @override
  void onInactive() => _record('onInactive —— 失去交互');

  @override
  void onPaused() => _record('onPaused —— 进入后台');

  @override
  void onDetached() => _record('onDetached —— 即将销毁');

  @override
  void onHidden() => _record('onHidden —— 被隐藏');

  @override
  void onMemoryPressure() => _record('onMemoryPressure —— 内存告警');

  @override
  void onAccessibilityChanged() => _record('onAccessibilityChanged —— 无障碍变化');

  void _record(String event) {
    events.insert(0, event);
    if (events.length > 20) events.removeLast();
  }
}
