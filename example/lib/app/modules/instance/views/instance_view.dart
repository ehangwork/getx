import 'package:material_ui/material_ui.dart';
import 'package:get/get.dart';

import '../controllers/instance_controller.dart';

class InstanceView extends GetView<InstanceController> {
  const InstanceView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('实例管理')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                OutlinedButton(
                  onPressed: controller.query,
                  child: const Text('isRegistered'),
                ),
                OutlinedButton(
                  onPressed: controller.putEphemeral,
                  child: const Text('put'),
                ),
                OutlinedButton(
                  onPressed: controller.putPermanent,
                  child: const Text('put permanent'),
                ),
                OutlinedButton(
                  onPressed: controller.putTagged,
                  child: const Text('put 带 tag'),
                ),
                OutlinedButton(
                  onPressed: controller.readTagged,
                  child: const Text('find 带 tag'),
                ),
                FilledButton(
                  onPressed: controller.deleteOne,
                  child: const Text('delete'),
                ),
                FilledButton(
                  onPressed: controller.deleteAll,
                  child: const Text('deleteAll'),
                ),
                FilledButton(
                  onPressed: controller.reset,
                  child: const Text('reset'),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: Obx(
              () => ListView.builder(
                itemCount: controller.report.length,
                itemBuilder: (context, index) => ListTile(
                  dense: true,
                  leading: const Icon(Icons.chevron_right),
                  title: Text(controller.report[index]),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
