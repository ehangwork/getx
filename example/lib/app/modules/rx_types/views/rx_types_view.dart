import 'package:material_ui/material_ui.dart';
import 'package:get/get.dart';

import '../../../../shared/widgets/get_back_button.dart';
import '../controllers/rx_types_controller.dart';

class RxTypesView extends GetView<RxTypesController> {
  const RxTypesView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rx 类型'),
        leading: const GetBackButton(),
      ),
      body: Obx(
        () => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _section('RxString / RxInt / RxDouble / RxBool', [
              _line('text', controller.text.value),
              _line('count', '${controller.count.value}'),
              _line('ratio', controller.ratio.value.toString()),
              _line('enabled', '${controller.enabled.value}'),
            ]),
            _section('RxnString / RxnInt / RxnDouble / RxnBool', [
              _line('optionalText', '${controller.optionalText.value}'),
              _line('optionalCount', '${controller.optionalCount.value}'),
              _line('optionalRatio', '${controller.optionalRatio.value}'),
              _line('optionalEnabled', '${controller.optionalEnabled.value}'),
            ], action: FilledButton(
              onPressed: controller.bumpNullable,
              child: const Text('bump'),
            )),
            _section('Rx<T> / Rxn<T>', [
              _line('user', '${controller.user.value}'),
              _line('optionalUser', '${controller.optionalUser.value}'),
            ]),
            _section('RxList / RxMap / RxSet', [
              _line('items', '${controller.items.value}'),
              _line('scores', '${controller.scores.value}'),
              _line('tags', '${controller.tags.value}'),
            ], action: FilledButton(
              onPressed: controller.mutateCollections,
              child: const Text('mutate'),
            )),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => controller.count.value++,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _section(String title, List<Widget> lines, {Widget? action}) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                ),
                if (action != null) action,
              ],
            ),
            const SizedBox(height: 8),
            ...lines,
          ],
        ),
      ),
    );
  }

  Widget _line(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Text('$label = $value'),
    );
  }
}
