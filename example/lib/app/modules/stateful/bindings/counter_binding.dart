import 'package:get/get.dart';

import '../controllers/counter_controller.dart';

class CounterBinding extends Binding {
  @override
  List<Bind> dependencies() => [Bind.lazyPut(() => CounterController())];
}
