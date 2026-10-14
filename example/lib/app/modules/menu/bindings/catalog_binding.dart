import 'package:get/get.dart';

import '../controllers/catalog_controller.dart';

class CatalogBinding extends Binding {
  @override
  List<Bind> dependencies() {
    return [
      Bind.lazyPut<CatalogController>(
        () => CatalogController(),
      ),
    ];
  }
}
