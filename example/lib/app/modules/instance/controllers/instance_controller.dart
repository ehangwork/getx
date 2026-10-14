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
    _nukeContainer('deleteAll(force: true)');
  }

  void reset() {
    _nukeContainer('Get.reset()');
  }

  /// deleteAll / Get.reset 都是「把容器清空」的语义，会连本页的 controller
  /// 一起带走。重新注册一个并把记录搬过去，页面才能继续演示，
  /// 否则上面的 Obx 会因为找不到 InstanceController 直接抛错。
  void _nukeContainer(String label) {
    final log = List<String>.from(report);
    Get.deleteAll(force: true);
    Get.put(InstanceController());
    final fresh = Get.find<InstanceController>();
    fresh.report.addAll(log);
    fresh._record('$label —— 连本页的 controller 一起清掉了，已重新注册');
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
