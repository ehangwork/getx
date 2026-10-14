import 'package:get/get.dart';

import '../services/counter_service.dart';

/// Binding.dependencies() 返回的是 List<Bind>，每个 Bind 工厂在调用时
/// 就已经完成了注册，返回的只是占位对象。
///
/// - Bind.put     注册时就创建
/// - Bind.lazyPut 第一次被 find 时才创建，之后复用同一个
/// - Bind.spawn   注册时就创建，但生命周期跟随当前页面
class BindingsDemoBinding extends Binding {
  @override
  List<Bind> dependencies() => [
        Bind.put(CounterService('put'), tag: 'put'),
        Bind.lazyPut(() => CounterService('lazyPut'), tag: 'lazyPut'),
        Bind.spawn(() => CounterService('spawn'), tag: 'spawn'),
        Bind.put(CounterService('left'), tag: 'left'),
        Bind.put(CounterService('right'), tag: 'right'),
      ];
}
