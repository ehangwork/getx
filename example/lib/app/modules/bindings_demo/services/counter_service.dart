/// 一个普通的服务类，用来观察它被什么时候创建、由谁持有。
class CounterService {
  CounterService(this.name);

  final String name;

  int value = 0;

  void increment() => value++;

  @override
  String toString() => '$name($value)';
}
