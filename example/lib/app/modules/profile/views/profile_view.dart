import 'package:material_ui/material_ui.dart';
import 'package:get/get.dart';

import '../controllers/profile_controller.dart';

class ProfileView extends GetView<ProfileController> {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.amber,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'ProfileView is working',
              style: TextStyle(fontSize: 20),
            ),
            const Hero(
              tag: 'heroLogo',
              child: FlutterLogo(),
            ),
            const SizedBox(height: 16),
            // 这个 tab 由 EnsureAuthMiddleware 守着，进得来说明登录态通了
            Text('ProfileController 已注册：${Get.isRegistered<ProfileController>()}'),
            Text('当前路由：${Get.currentRoute}'),
          ],
        ),
      ),
    );
  }
}
