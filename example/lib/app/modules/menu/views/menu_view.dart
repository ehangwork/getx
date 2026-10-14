import 'package:material_ui/material_ui.dart';
import 'package:get/get.dart';

import '../../../routes/app_pages.dart';

/// 示例总目录。左侧的图标按能力分类，方便一眼看出这个 fork 覆盖了什么。
class MenuView extends StatelessWidget {
  const MenuView({super.key});

  static const _groups = <_MenuGroup>[
    _MenuGroup('响应式', [
      _MenuItem('GetX / GetBuilder / Obx', '三种订阅方式并排对照',
          Icons.widgets_outlined, Routes.stateful),
      _MenuItem('Rx 类型', 'RxString / Rxn / RxList / RxMap / RxSet',
          Icons.data_object, Routes.rxTypes),
      _MenuItem('Worker', 'ever / once / interval / debounce',
          Icons.timelapse, Routes.workers),
      _MenuItem('ScrollMixin 分页', '滚到顶或底自动加载',
          Icons.unfold_more, Routes.pagination),
    ]),
    _MenuGroup('路由', [
      _MenuItem('路由跳转', 'to / off / offAll / until 等全套',
          Icons.alt_route, Routes.navigation),
      _MenuItem('路由过渡', '16 种 Transition 逐个预览',
          Icons.animation, Routes.transitions),
      _MenuItem('嵌套路由', 'GetRouterOutlet + 中间件 + GetWidget',
          Icons.account_tree_outlined, Routes.root),
    ]),
    _MenuGroup('浮层与依赖', [
      _MenuItem('浮层', 'Snackbar / Dialog / BottomSheet',
          Icons.layers_outlined, Routes.overlays),
      _MenuItem('依赖绑定', 'put / lazyPut / spawn / create / tag',
          Icons.link, Routes.bindings),
      _MenuItem('实例管理', 'isRegistered / delete / reset',
          Icons.inventory_2_outlined, Routes.instance),
      _MenuItem('App 生命周期', 'FullLifeCycle 的全部回调',
          Icons.phonelink_lock, Routes.lifecycle),
    ]),
    _MenuGroup('数据层', [
      _MenuItem('StateController + futurize', '加载中 / 成功 / 失败三态',
          Icons.cloud_download_outlined, Routes.countries),
    ]),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('GetX 示例'),
        actions: [
          IconButton(
            tooltip: '切换主题',
            onPressed: () => Get.changeTheme(
              Get.isDarkMode ? ThemeData.light() : ThemeData.dark(),
            ),
            icon: Icon(Get.isDarkMode ? Icons.light_mode : Icons.dark_mode),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          for (final group in _groups) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
              child: Text(
                group.title,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            for (final item in group.items)
              ListTile(
                leading: Icon(item.icon),
                title: Text(item.title),
                subtitle: Text(item.subtitle),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Get.toNamed(item.route),
              ),
          ],
        ],
      ),
    );
  }
}

class _MenuGroup {
  const _MenuGroup(this.title, this.items);

  final String title;
  final List<_MenuItem> items;
}

class _MenuItem {
  const _MenuItem(this.title, this.subtitle, this.icon, this.route);

  final String title;
  final String subtitle;
  final IconData icon;
  final String route;
}
