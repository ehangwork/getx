import 'package:get/get.dart';

import '../controllers/rx_types_controller.dart';

class RxTypesBinding extends Binding {
  @override
  List<Bind> dependencies() => [Bind.lazyPut(() => RxTypesController())];
}
