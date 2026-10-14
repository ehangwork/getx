import 'package:get/get.dart';

import '../controllers/instance_controller.dart';

class InstanceBinding extends Binding {
  @override
  List<Bind> dependencies() => [Bind.lazyPut(() => InstanceController())];
}
