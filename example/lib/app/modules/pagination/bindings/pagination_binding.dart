import 'package:get/get.dart';

import '../controllers/pagination_controller.dart';

class PaginationBinding extends Binding {
  @override
  List<Bind> dependencies() => [Bind.lazyPut(() => PaginationController())];
}
