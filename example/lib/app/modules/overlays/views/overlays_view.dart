import 'package:get/get.dart';
import 'package:material_ui/material_ui.dart';

/// Snackbar / Dialog / BottomSheet 三类浮层的入口。
/// 全部走 Get 的全局方法，不需要从当前页面的 context 里拿 Navigator。
class OverlaysView extends StatelessWidget {
  const OverlaysView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('浮层')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _tile(
            'Get.snackbar',
            '带主按钮与状态回调的 Snackbar',
            () => Get.snackbar(
              'title',
              'message',
              mainButton: TextButton(
                onPressed: () => Get.log('snackbar main button'),
                child: const Text('button'),
              ),
              snackPosition: SnackPosition.bottom,
              duration: const Duration(seconds: 3),
              snackStyle: SnackStyle.floating,
              borderRadius: 12,
            ),
          ),
          _tile(
            'Get.rawSnackbar',
            '自己拼内容的 Snackbar，返回的控制器可以关掉或结束当前这条',
            () {
              final controller = Get.rawSnackbar(
                titleText: const Text('raw'),
                messageText: const Text('rawSnackbar 会立刻展示'),
                duration: const Duration(seconds: 5),
                snackPosition: SnackPosition.top,
                snackStyle: SnackStyle.floating,
                borderRadius: 12,
              );
              // 静态入口：直接关掉当前正在显示的那条
              Get.log(
                  'isSnackbarBeingShown = ${SnackbarController.isSnackbarBeingShown}');
              Get.log('controller = $controller');
            },
          ),
          _tile(
            'Get.rawSnackbar + closeCurrentSnackbar',
            '不用等它自己消失，提前关掉当前这条',
            () {
              Get.rawSnackbar(
                titleText: const Text('raw'),
                messageText: const Text('1 秒后被提前关掉'),
                duration: const Duration(seconds: 5),
              );
              Future<void>.delayed(const Duration(seconds: 1), () {
                SnackbarController.closeCurrentSnackbar();
              });
            },
          ),
          _tile(
            'Get.dialog',
            '自定义内容的 Dialog',
            () => Get.dialog(
              const _DemoDialog(),
              barrierDismissible: true,
              transitionDuration: const Duration(milliseconds: 300),
            ),
          ),
          _tile(
            'Get.defaultDialog',
            'GetX 内置样式的 Dialog，回调走 onConfirm / onCancel',
            () => Get.defaultDialog(
              title: 'defaultDialog',
              middleText: '确认要继续吗？',
              textCancel: '取消',
              textConfirm: '确定',
              onConfirm: () => Get.log('confirmed'),
              onCancel: () => Get.log('cancelled'),
            ),
          ),
          _tile(
            'Get.defaultDialog + content',
            'content 参数可以塞任意 widget',
            () => Get.defaultDialog(
              title: 'MenuView',
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (final label in ['选项一', '选项二', '选项三'])
                    ListTile(
                      title: Text(label),
                      onTap: () {
                        Navigator.of(Get.context!).pop();
                        Get.log(label);
                      },
                    ),
                ],
              ),
            ),
          ),
          _tile(
            'Get.bottomSheet',
            '底部弹层，返回值由 await 拿到',
            () async {
              final picked = await Get.bottomSheet<int>(
                const _DemoBottomSheet(),
                isScrollControlled: true,
                backgroundColor: Colors.white,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
              );
              Get.log('bottomSheet result: $picked');
            },
          ),
          _tile(
            'Get.bottomSheet + 立即再弹一条',
            '两个浮层可以叠加，互不影响',
            () {
              Get.bottomSheet(const _DemoBottomSheet());
              Get.snackbar('提示', 'bottomSheet 已经打开了');
            },
          ),
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

class _DemoDialog extends StatelessWidget {
  const _DemoDialog();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Get.dialog'),
      content: const Text('这是通过 Get.dialog 打开的自定义内容。'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(Get.context!).pop(),
          child: const Text('关闭'),
        ),
      ],
    );
  }
}

class _DemoBottomSheet extends StatelessWidget {
  const _DemoBottomSheet();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('选一个数字'),
            const SizedBox(height: 16),
            for (final n in [1, 2, 3])
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: FilledButton(
                  onPressed: () => Get.back(result: n),
                  child: Text('$n'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
