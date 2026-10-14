import 'package:get/get.dart';

/// Worker 是一层防抖 / 节流 / 限次的订阅包装，
/// 与直接 listen 的区别是它会随 controller 一起被释放。
class WorkerController extends GetxController {
  final everSource = 0.obs;
  final onceSource = 0.obs;
  final intervalSource = 0.obs;
  final debounceSource = 0.obs;

  final log = <String>[].obs;

  final List<Worker> _workers = [];

  @override
  void onInit() {
    super.onInit();

    // 每次变化都回调
    _workers.add(ever<int>(everSource, (value) {
      _append('ever      <- $value');
    }));

    // 只在第一次变化时回调，之后自动失效
    _workers.add(once<int>(onceSource, (value) {
      _append('once      <- $value');
    }));

    // 每隔一段时间取一次当前值
    _workers.add(interval<int>(
      intervalSource,
      (value) => _append('interval  <- $value'),
      time: const Duration(seconds: 3),
    ));

    // 变化停下来一小会儿之后才回调
    _workers.add(debounce<int>(
      debounceSource,
      (value) => _append('debounce  <- $value'),
      time: const Duration(milliseconds: 600),
    ));
  }

  @override
  void onClose() {
    for (final worker in _workers) {
      worker.dispose();
    }
    _workers.clear();
    super.onClose();
  }

  void _append(String line) {
    final stamped = '${DateTime.now().toIso8601String().substring(11, 19)}  $line';
    log.insert(0, stamped);
    if (log.length > 30) log.removeLast();
  }

  void reset() => log.clear();
}
