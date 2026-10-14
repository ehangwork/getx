import 'package:get/get.dart';

import '../controllers/lifecycle_controller.dart';

class LifecycleBinding extends Binding {
  @override
  List<Bind> dependencies() => [Bind.lazyPut(() => LifecycleController())];
}
