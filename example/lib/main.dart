import 'package:material_ui/material_ui.dart';
import 'package:get/get.dart';

import 'app/routes/app_pages.dart';
import 'services/auth_service.dart';
import 'shared/logger/logger_utils.dart';

void main() {
  runApp(const GetDemoApp());
}

class GetDemoApp extends StatelessWidget {
  const GetDemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'GetX Demo',
      debugShowCheckedModeBanner: false,
      enableLog: true,
      logWriterCallback: Logger.write,
      theme: ThemeData(
        colorSchemeSeed: Colors.indigo,
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorSchemeSeed: Colors.indigo,
        brightness: Brightness.dark,
        useMaterial3: true,
      ),
      initialRoute: AppPages.INITIAL,
      getPages: AppPages.routes,
      // 全局依赖随 App 注册一次，与具体路由无关
      binds: [Bind.put(AuthService())],
      // Get.tr 体系在这个 fork 里已经删掉，语言直接交给 MaterialApp
      locale: const Locale('en', 'US'),
      fallbackLocale: const Locale('en', 'US'),
    );
  }
}
