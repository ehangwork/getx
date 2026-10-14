import 'package:material_ui/material_ui.dart';
import 'package:get/get.dart';
import '../../../../shared/widgets/get_back_button.dart';

/// 被路由跳转反复推入的目标页，用来观察 arguments / parameters /
/// currentRoute 在不同跳转方式下的差别。
class NavigationTargetView extends StatelessWidget {
  const NavigationTargetView({super.key, this.label});

  final String? label;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(label ?? '目标页'),
        leading: const GetBackButton(),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _info('Get.currentRoute', Get.currentRoute),
          _info('Get.arguments', '${Get.arguments}'),
          _info('context.arguments', '${context.arguments}'),
          _info('Get.parameters', '${Get.parameters}'),
          _info('context.params', '${context.params}'),
          _info('Get.previousRoute', Get.previousRoute),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: () {
              final result = DateTime.now().millisecondsSinceEpoch;
              Get.back(result: result);
              Get.log('back with result: $result');
            },
            child: const Text('返回并回传结果'),
          ),
          const SizedBox(height: 8),
          OutlinedButton(
            onPressed: () => Get.log('Get.key: ${Get.key.currentContext != null}'),
            child: const Text('检查 Get.key 是否有 context'),
          ),
          const SizedBox(height: 8),
          OutlinedButton(
            onPressed: () => Get.log('Get.context: ${Get.context != null}'),
            child: const Text('检查 Get.context'),
          ),
        ],
      ),
    );
  }

  Widget _info(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Text('$label = $value'),
    );
  }
}
