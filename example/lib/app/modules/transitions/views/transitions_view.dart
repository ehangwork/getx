import 'package:material_ui/material_ui.dart';
import 'package:get/get.dart';

import '../../navigation/views/navigation_target_view.dart';

/// Transition 枚举的每一项都对应 routes/default_transitions.dart 里的一个
/// 过渡类，这里逐个点一遍，方便肉眼比较差异。
class TransitionsView extends StatelessWidget {
  const TransitionsView({super.key});

  static const _all = <Transition>[
    Transition.fade,
    Transition.fadeIn,
    Transition.rightToLeft,
    Transition.leftToRight,
    Transition.upToDown,
    Transition.downToUp,
    Transition.rightToLeftWithFade,
    Transition.leftToRightWithFade,
    Transition.zoom,
    Transition.topLevel,
    Transition.noTransition,
    Transition.cupertino,
    Transition.cupertinoDialog,
    Transition.size,
    Transition.circularReveal,
    Transition.native,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('路由过渡')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            '同名枚举项背后是一个独立的过渡类；customTransition 则接一个'
            '自写的 CustomTransition 实现。',
            style: TextStyle(fontSize: 12),
          ),
          const SizedBox(height: 16),
          for (final transition in _all)
            Card(
              child: ListTile(
                title: Text(transition.name),
                trailing: const Icon(Icons.play_arrow),
                onTap: () => Get.to(
                  () => const NavigationTargetView(),
                  transition: transition,
                  duration: const Duration(milliseconds: 600),
                  arguments: transition.name,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
