import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:get/get.dart';

import 'app/routes/app_pages.dart';
import 'app/modules/menu/views/menu_view.dart';

/// GetCupertinoApp 的独立入口。GetMaterialApp 与 GetCupertinoApp 不能同时
/// 挂在同一棵树上，所以单独放一个 target：
///
/// ```
/// flutter run -t lib/main_cupertino.dart
/// ```
///
/// 两者共用同一份路由表，只有默认外观与默认过渡不同。
void main() {
  runApp(const GetCupertinoDemoApp());
}

class GetCupertinoDemoApp extends StatelessWidget {
  const GetCupertinoDemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetCupertinoApp(
      title: 'GetX Demo (Cupertino)',
      debugShowCheckedModeBanner: false,
      enableLog: true,
      defaultTransition: Transition.cupertino,
      initialRoute: AppPages.INITIAL,
      getPages: AppPages.routes,
      locale: const Locale('en', 'US'),
      fallbackLocale: const Locale('en', 'US'),
      home: const MenuView(),
    );
  }
}
