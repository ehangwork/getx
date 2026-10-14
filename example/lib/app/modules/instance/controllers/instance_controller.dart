import 'package:get/get.dart';

/// 容器实例的查询与销毁。isRegistered / delete 在按需创建的服务里
/// 特别常用：先判断再取，或者取完立刻还回去。
class InstanceController extends GetxController {
  final report = <String>[].obs;

  DemoService? _held;

  void query() {
    _record('isRegistered<DemoService>() = ${Get.isRegistered<DemoService>()}');
    _record('isPrepared<DemoService>()  = ${Get.isPrepared<DemoService>()}');
  }

  void putEphemeral() {
    _held = DemoService('ephemeral');
    Get.put<DemoService>(_held!);
    _record('已注册 DemoService(ephemeral)');
  }

  void putPermanent() {
    Get.put<DemoService>(DemoService('permanent'), permanent: true);
    _record('已永久注册 DemoService(permanent)');
  }

  void putTagged() {
    Get.put<DemoService>(DemoService('tagged'), tag: 'a');
    Get.put<DemoService>(DemoService('tagged'), tag: 'b');
    _record('已注册两个 tag 的 DemoService');
  }

  void readTagged() {
    _record("find(tag: 'a') = ${Get.find<DemoService>(tag: 'a')}");
    _record("find(tag: 'b') = ${Get.find<DemoService>(tag: 'b')}");
  }

  Future<void> deleteOne() async {
    final ok = await Get.delete<DemoService>(force: true);
    _record('delete<DemoService>(force: true) = $ok');
  }

  void deleteAll() {
    Get.deleteAll(force: true);
    _record('deleteAll(force: true)');
  }

  void reset() {
    Get.reset();
    _record('Get.reset()');
  }

  void _record(String line) {
    report.insert(0, line);
    if (report.length > 30) report.removeLast();
  }
}

class DemoService {
  DemoService(this.name);

  final String name;

  @override
  String toString() => 'DemoService($name)';
}
