import 'package:material_ui/material_ui.dart';
import 'package:get/get.dart';

import '../../../../shared/widgets/get_back_button.dart';
import '../../../routes/app_pages.dart';
import '../controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          color: Colors.yellow,
          width: double.infinity,
          height: 25,
        ),
        Expanded(
          child: GetRouterOutlet.builder(
            route: Routes.home,
            builder: (context) {
              return Scaffold(
                appBar: AppBar(
                  // RouterListener 的演示放在这儿：HomeView 在三个 tab
                  // 之间常驻，切 tab 时标题会跟着路由实时变。
                  // 目录页放不了——它一导航就被卸载，永远只显示初始路径。
                  title: RouterListener(
                    builder: (context) => Text('Home · ${context.location}'),
                  ),
                  leading: const GetBackButton(),
                ),
                body: GetRouterOutlet(
                  initialRoute: Routes.dashboard,
                  anchorRoute: Routes.home,
                ),
                bottomNavigationBar: IndexedRouteBuilder(
                    routes: const [
                      Routes.homeDashboard,
                      Routes.homeProfile,
                      Routes.homeProducts
                    ],
                    builder: (context, routes, index) {
                      final delegate = context.delegate;
                      return BottomNavigationBar(
                        currentIndex: index,
                        onTap: (value) => delegate.toNamed(routes[value]),
                        items: const [
                          // _Paths.HOME + [Empty]
                          BottomNavigationBarItem(
                            icon: Icon(Icons.home),
                            label: 'Home',
                          ),
                          // _Paths.HOME + Routes.PROFILE
                          BottomNavigationBarItem(
                            icon: Icon(Icons.account_box_rounded),
                            label: 'Profile',
                          ),
                          // _Paths.HOME + _Paths.PRODUCTS
                          BottomNavigationBarItem(
                            icon: Icon(Icons.account_box_rounded),
                            label: 'Products',
                          ),
                        ],
                      );
                    }),
              );
            },
          ),
        ),
      ],
    );
  }
}
