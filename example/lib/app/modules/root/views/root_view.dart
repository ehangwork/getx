import 'package:material_ui/material_ui.dart';
import 'package:get/get.dart';

import '../../../routes/app_pages.dart';
import '../controllers/root_controller.dart';

/// 嵌套路由的壳。
///
/// 壳本身不画任何界面控件，标题栏交给每个页面自己的 AppBar——
/// 壳再画一层的话，所有页面都会变成双 AppBar，
/// 而且壳这层只能显示原始路径，对使用者没有意义。
class RootView extends GetView<RootController> {
  const RootView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetRouterOutlet(
      initialRoute: Routes.menu,
      anchorRoute: Routes.root,
    );
  }
}
