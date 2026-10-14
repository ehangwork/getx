import 'package:get/get.dart';

class DemoUser {
  const DemoUser({required this.name, required this.age});

  final String name;
  final int age;

  @override
  String toString() => 'DemoUser($name, $age)';
}

/// GetX 给每个原生类型都准备了语义明确的 Rx 包装，
/// 这里把常用的一批集中放在一起，方便对照它们各自的能力。
class RxTypesController extends GetxController {
  // 非空包装：读写都直接给值
  final text = 'hello'.obs;
  final count = 0.obs;
  final ratio = 0.5.obs;
  final enabled = true.obs;

  // 可空包装 Rxnxxx：初值可空，读出来是 T?
  final optionalText = RxnString();
  final optionalCount = RxnInt(7);
  final optionalRatio = RxnDouble();
  final optionalEnabled = RxnBool();

  // 自定义对象：Rx<T> 要求 T 能被值比较，未提供时按引用比较
  final user = Rx<DemoUser>(const DemoUser(name: 'Ada', age: 36));
  final optionalUser = Rxn<DemoUser>();

  // 集合类型：增删改都会触发订阅
  final items = <String>[].obs;
  final scores = <String, int>{}.obs;
  final tags = <String>{}.obs;

  void bumpNullable() {
    optionalCount.value = (optionalCount.value ?? 0) + 1;
    optionalText.value = optionalText.value == null ? 'set' : null;
    optionalRatio.value = (optionalRatio.value ?? 0) + 0.25;
    optionalEnabled.value = !(optionalEnabled.value ?? false);
    optionalUser.value =
        optionalUser.value == null ? const DemoUser(name: 'Grace', age: 45) : null;
  }

  void mutateCollections() {
    items.add('item ${items.length + 1}');
    scores['count'] = (scores['count'] ?? 0) + 1;
    tags
      ..clear()
      ..addAll({'tag ${DateTime.now().millisecond % 100}'});
  }
}
