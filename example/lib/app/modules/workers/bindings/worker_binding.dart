import 'package:get/get.dart';

import '../controllers/worker_controller.dart';

class WorkerBinding extends Binding {
  @override
  List<Bind> dependencies() => [Bind.lazyPut(() => WorkerController())];
}
