import 'package:material_ui/material_ui.dart';
import 'package:get/get.dart';

import '../../../../shared/widgets/get_back_button.dart';
import '../controllers/worker_controller.dart';

class WorkerView extends GetView<WorkerController> {
  const WorkerView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const GetBackButton(),
        title: const Text('Worker'),
        actions: [
          IconButton(
            onPressed: controller.reset,
            icon: const Icon(Icons.clear_all),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(child: Text('ever 源：${controller.everSource.value}')),
                    FilledButton(
                      onPressed: () => controller.everSource.value++,
                      child: const Text('+1'),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(child: Text('once 源：${controller.onceSource.value}')),
                    FilledButton(
                      onPressed: () => controller.onceSource.value++,
                      child: const Text('+1'),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(child: Text('interval 源：${controller.intervalSource.value}')),
                    FilledButton(
                      onPressed: () => controller.intervalSource.value++,
                      child: const Text('+1'),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(child: Text('debounce 源：${controller.debounceSource.value}')),
                    FilledButton(
                      onPressed: () => controller.debounceSource.value++,
                      child: const Text('+1'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'debounce 连续点几次只会留下最后一次，interval 不受点击影响。',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: Obx(
              () => ListView.builder(
                itemCount: controller.log.length,
                itemBuilder: (context, index) => ListTile(
                  dense: true,
                  leading: const Icon(Icons.chevron_right),
                  title: Text(controller.log[index]),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
