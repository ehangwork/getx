import 'package:material_ui/material_ui.dart';
import 'package:get/get.dart';

import '../../../../shared/widgets/get_back_button.dart';
import '../controllers/counter_controller.dart';

/// 三种订阅方式并排对照：
///
/// - GetX<T>   直接把 controller 交给 widget，读 Rx 字段即自动重建
/// - GetBuilder 监听 controller 的 update()，字段不必是 Rx
/// - Obx       订阅一棵 Rx 树，没有类型安全的 controller 引用
class StatefulView extends StatelessWidget {
  const StatefulView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('GetX / GetBuilder / Obx'),
        leading: const GetBackButton(),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          _GetXSection(),
          SizedBox(height: 16),
          _GetBuilderSection(),
          SizedBox(height: 16),
          _ObxSection(),
          SizedBox(height: 16),
          _ScopedUpdateSection(),
          SizedBox(height: 16),
          _ContextAccessSection(),
        ],
      ),
    );
  }
}

class _GetXSection extends StatelessWidget {
  const _GetXSection();

  @override
  Widget build(BuildContext context) {
    return GetX<CounterController>(
      builder: (controller) => Card(
        child: ListTile(
          title: const Text('GetX<CounterController>'),
          subtitle: Text('count: ${controller.getxCount.value}'),
          trailing: FilledButton(
            onPressed: controller.incrementByGetX,
            child: const Text('+1'),
          ),
        ),
      ),
    );
  }
}

class _GetBuilderSection extends StatelessWidget {
  const _GetBuilderSection();

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CounterController>(
      builder: (controller) => Card(
        child: ListTile(
          title: const Text('GetBuilder<CounterController>'),
          subtitle: Text('count: ${controller.builderCount}'),
          trailing: FilledButton(
            onPressed: controller.incrementByBuilder,
            child: const Text('+1'),
          ),
        ),
      ),
    );
  }
}

class _ObxSection extends StatelessWidget {
  const _ObxSection();

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Card(
        child: ListTile(
          title: const Text('Obx'),
          subtitle: Text('count: ${Get.find<CounterController>().obxCount.value}'),
          trailing: FilledButton(
            onPressed: Get.find<CounterController>().incrementByObx,
            child: const Text('+1'),
          ),
        ),
      ),
    );
  }
}

/// update 带上 id 与 condition 后，可以只标记指定的 GetBuilder 重建。
/// 下面两个 GetBuilder 共用同一个 controller，只有 even 那个会被刷新。
class _ScopedUpdateSection extends StatelessWidget {
  const _ScopedUpdateSection();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('update(ids, condition)'),
            const SizedBox(height: 12),
            GetBuilder<CounterController>(
              id: 'even',
              builder: (controller) => Text('even: ${controller.evenOnly.value}'),
            ),
            GetBuilder<CounterController>(
              builder: (controller) =>
                  Text('plain builderCount: ${controller.builderCount}'),
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: Get.find<CounterController>().incrementEven,
              child: const Text('+1 (只刷新 even)'),
            ),
          ],
        ),
      ),
    );
  }
}

/// context.listen<T>() 不需要包一层 builder，直接在 build 里拿到 controller；
/// context.get<T>() 是不订阅的读取，两者都是 Bind.of 的薄封装。
class _ContextAccessSection extends StatelessWidget {
  const _ContextAccessSection();

  @override
  Widget build(BuildContext context) {
    // listen 会把当前 widget 登记为依赖，controller update 时重建
    final controller = context.listen<CounterController>();

    return GetX<CounterController>(
      init: Get.find<CounterController>(),
      builder: (host) => Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('context.listen<T>() / context.get<T>()'),
              const SizedBox(height: 12),
              Text('builderCount: ${controller.builderCount}'),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: controller.incrementByBuilder,
                child: const Text('+1'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
