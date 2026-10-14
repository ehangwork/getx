import 'package:material_ui/material_ui.dart';
import 'package:get/get.dart';

import '../../../../shared/widgets/get_back_button.dart';
import '../controllers/lifecycle_controller.dart';

/// 生命周期回调由系统触发，页面上再补几个按钮把行为手动触发一遍，
/// 这样不切前后台也能看到效果。
class LifecycleView extends GetView<LifecycleController> {
  const LifecycleView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('App 生命周期'),
        leading: const GetBackButton(),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilledButton(
                  onPressed: controller.onResumed,
                  child: const Text('onResumed'),
                ),
                FilledButton(
                  onPressed: controller.onInactive,
                  child: const Text('onInactive'),
                ),
                FilledButton(
                  onPressed: controller.onPaused,
                  child: const Text('onPaused'),
                ),
                FilledButton(
                  onPressed: controller.onHidden,
                  child: const Text('onHidden'),
                ),
                FilledButton(
                  onPressed: controller.onDetached,
                  child: const Text('onDetached'),
                ),
                OutlinedButton(
                  onPressed: controller.onMemoryPressure,
                  child: const Text('onMemoryPressure'),
                ),
                OutlinedButton(
                  onPressed: controller.onAccessibilityChanged,
                  child: const Text('onAccessibilityChanged'),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: Obx(
              () => ListView.builder(
                itemCount: controller.events.length,
                itemBuilder: (context, index) => ListTile(
                  dense: true,
                  leading: const Icon(Icons.chevron_right),
                  title: Text(controller.events[index]),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
