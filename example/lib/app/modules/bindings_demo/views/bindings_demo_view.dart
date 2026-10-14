import 'package:material_ui/material_ui.dart';
import 'package:get/get.dart';

import '../services/counter_service.dart';

class BindingsDemoView extends StatefulWidget {
  const BindingsDemoView({super.key});

  @override
  State<BindingsDemoView> createState() => _BindingsDemoViewState();
}

class _BindingsDemoViewState extends State<BindingsDemoView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('依赖绑定')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _card(
            'Bind.put / Bind.lazyPut / Bind.spawn',
            '由路由的 binding 注册，三者的差别在创建时机与生命周期。',
            Column(
              children: [
                _read(context, 'Bind.put', 'put'),
                _read(context, 'Bind.lazyPut', 'lazyPut'),
                _read(context, 'Bind.spawn', 'spawn'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _card(
            'Bind.create + Binds',
            '不进入容器，只在这棵子树里可用，随子树一起销毁。'
            '子树内用 context.get<T>() 取值。',
            Binds(
              binds: [
                Bind.create<CounterService>((_) => CounterService('create')),
              ],
              child: Builder(
                builder: (context) => _read(context, 'Bind.create', 'create'),
              ),
            ),
          ),
          const SizedBox(height: 16),
          _card(
            '带 tag 的同类型实例',
            '同一个类可以注册多份，用 tag 区分。',
            Column(
              children: [
                _read(context, 'left', 'left'),
                _read(context, 'right', 'right'),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          for (final tag in ['put', 'left', 'right']) {
            Get.find<CounterService>(tag: tag).increment();
          }
          setState(() {});
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _read(BuildContext context, String label, String tag) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(child: Text(label)),
          Text('${Get.find<CounterService>(tag: tag)}'),
        ],
      ),
    );
  }

  Widget _card(String title, String subtitle, Widget child) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(subtitle, style: const TextStyle(fontSize: 12)),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}
