import 'package:get/get.dart';
import 'package:material_ui/material_ui.dart';

/// 目录页控制器，目前只管暗黑模式切换。
///
/// 注意 `Get.changeTheme` 只换调色板，不动 `themeMode`；
/// app 的 themeMode 默认是 system，设备在浅色模式下调用它看不到任何变化。
/// 手动切换必须走 `Get.changeThemeMode`。
class CatalogController extends GetxController {
  final themeMode = ThemeMode.light.obs;

  bool get isDark => themeMode.value == ThemeMode.dark;

  void toggleTheme() {
    final next = isDark ? ThemeMode.light : ThemeMode.dark;
    themeMode.value = next;
    Get.changeThemeMode(next);
  }
}
