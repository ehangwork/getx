import 'package:material_ui/material_ui.dart';
import 'package:get/get.dart';

import '../../../routes/app_pages.dart';
import 'navigation_target_view.dart';

/// 路由跳转方式的全集演示。每种方式的差别体现在「压栈还是替换」。
class NavigationView extends StatelessWidget {
  const NavigationView({super.key});

  @override
  Widget build(BuildContext context) {
    final inline = () => const NavigationTargetView(label: 'inline target');

    return Scaffold(
      appBar: AppBar(title: const Text('路由跳转')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _section('压栈', [
            _tile('Get.to', '推入一个 widget，返回值由 await 拿到', () async {
              final result = await Get.to<int>(() => const NavigationTargetView());
              Get.log('to result: $result');
            }),
            _tile('Get.toNamed', '按名字推入', () => Get.toNamed(Routes.transitionTarget)),
            _tile('Get.toNamed + arguments', '任意类型都能传', () => Get.toNamed(
                  Routes.transitionTarget,
                  arguments: {'from': 'toNamed', 'value': 42},
                )),
            _tile('Get.toNamed + parameters', '走 URL 的 query 部分',
                () => Get.toNamed('${Routes.transitionTarget}?id=7&name=ada')),
          ]),
          _section('替换当前页', [
            _tile('Get.off', '替换成另一个 widget', () => Get.off(inline)),
            _tile('Get.offNamed', '按名字替换', () => Get.offNamed(Routes.transitionTarget)),
            _tile('Get.offAndToNamed', '先弹掉当前页再压入新页',
                () => Get.offAndToNamed(Routes.transitionTarget)),
          ]),
          _section('清栈', [
            _tile('Get.offAll', '只留这一个页面', () => Get.offAll(inline)),
            _tile('Get.offAllNamed', '清栈后落到指定名字',
                () => Get.offAllNamed(Routes.menu)),
          ]),
          _section('条件式跳转', [
            _tile('Get.offNamedUntil', '弹出直到满足条件的页面',
                () => Get.offNamedUntil(Routes.transitionTarget,
                    (route) => route.name == Routes.menu)),
            _tile('Get.until', '只出栈不压入',
                () => Get.until((route) => route.name == Routes.menu)),
          ]),
          _section('其它', [
            _tile('Get.removeRoute', '按名字移除路由', () {
              Get.toNamed(Routes.transitionTarget);
              Future<void>.delayed(const Duration(milliseconds: 400), () {
                Get.removeRoute(Routes.transitionTarget);
              });
            }),
            _tile('回到示例目录', '用返回回到入口', () => Get.offAllNamed(Routes.menu)),
          ]),
        ],
      ),
    );
  }

  Widget _section(String title, List<Widget> children) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
            child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
          ...children,
        ],
      ),
    );
  }

  Widget _tile(String title, String subtitle, VoidCallback onTap) {
    return Card(
      child: ListTile(
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
