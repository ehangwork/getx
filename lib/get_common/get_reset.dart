import '../get_core/src/get_interface.dart';
import '../get_core/src/get_main.dart';
import '../get_instance/src/extension_instance.dart';

extension GetResetExt on GetInterface {
  void reset({bool clearRouteBindings = true}) {
    Get.resetInstance(clearRouteBindings: clearRouteBindings);
  }
}