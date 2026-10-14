import 'package:material_ui/material_ui.dart';
import 'package:get/get.dart';

import '../../../../shared/widgets/get_back_button.dart';
import '../controllers/pagination_controller.dart';

/// 上下滚到底都会触发分页加载：列表用 controller 提供的 controller.scroll。
class PaginationView extends GetView<PaginationController> {
  const PaginationView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ScrollMixin 分页'),
        leading: const GetBackButton(),
      ),
      body: Obx(
        () => Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8),
              child: Text(
                '共 ${controller.items.length} 条'
                '${controller.isLoading.value ? ' · 加载中…' : ''}',
              ),
            ),
            Expanded(
              child: ListView.builder(
                controller: controller.scroll,
                itemCount: controller.items.length,
                itemBuilder: (context, index) => ListTile(
                  leading: CircleAvatar(child: Text('${index + 1}')),
                  title: Text(controller.items[index]),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
