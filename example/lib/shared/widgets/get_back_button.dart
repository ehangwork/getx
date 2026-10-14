import 'package:material_ui/material_ui.dart';
import 'package:get/get.dart';

/// 嵌套路由里 outlet 页面的返回键。
///
/// AppBar 默认那个返回键是靠 `Navigator.canPop` 决定要不要显示的，
/// 而 outlet 的 Navigator 只持有当前分支切片的那一个栈顶页
/// （真正的历史栈在 GetDelegate._activePages 里），canPop 恒为 false，
/// 自动返回键永远不出现。所以这里必须显式给，并且走 Get.back()。
class GetBackButton extends StatelessWidget {
  const GetBackButton({super.key});

  @override
  Widget build(BuildContext context) {
    // 真正的历史栈在 delegate 上，不在 outlet 的 Navigator 上。
    // 栈里只剩一页时按返回没有意义，直接不显示
    if (!Get.rootController.rootDelegate.canBack) {
      return const SizedBox.shrink();
    }
    return BackButton(onPressed: Get.back);
  }
}
