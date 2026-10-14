import 'package:get/get.dart';

import '../middleware/auth_middleware.dart';
import '../modules/bindings_demo/bindings/bindings_demo_binding.dart';
import '../modules/bindings_demo/views/bindings_demo_view.dart';
import '../modules/dashboard/bindings/dashboard_binding.dart';
import '../modules/dashboard/views/dashboard_view.dart';
import '../modules/data/bindings/country_details_binding.dart';
import '../modules/data/bindings/country_list_binding.dart';
import '../modules/data/presentation/views/country_details_view.dart';
import '../modules/data/presentation/views/country_list_view.dart';
import '../modules/home/bindings/home_binding.dart';
import '../modules/home/views/home_view.dart';
import '../modules/instance/bindings/instance_binding.dart';
import '../modules/instance/views/instance_view.dart';
import '../modules/lifecycle/bindings/lifecycle_binding.dart';
import '../modules/lifecycle/views/lifecycle_view.dart';
import '../modules/login/bindings/login_binding.dart';
import '../modules/login/views/login_view.dart';
import '../modules/menu/views/menu_view.dart';
import '../modules/navigation/views/navigation_target_view.dart';
import '../modules/navigation/views/navigation_view.dart';
import '../modules/overlays/views/overlays_view.dart';
import '../modules/pagination/bindings/pagination_binding.dart';
import '../modules/pagination/views/pagination_view.dart';
import '../modules/product_details/bindings/product_details_binding.dart';
import '../modules/product_details/views/product_details_view.dart';
import '../modules/products/bindings/products_binding.dart';
import '../modules/products/views/products_view.dart';
import '../modules/profile/bindings/profile_binding.dart';
import '../modules/profile/views/profile_view.dart';
import '../modules/root/bindings/root_binding.dart';
import '../modules/root/views/root_view.dart';
import '../modules/rx_types/bindings/rx_types_binding.dart';
import '../modules/rx_types/views/rx_types_view.dart';
import '../modules/settings/bindings/settings_binding.dart';
import '../modules/settings/views/settings_view.dart';
import '../modules/stateful/bindings/counter_binding.dart';
import '../modules/stateful/views/stateful_view.dart';
import '../modules/transitions/views/transitions_view.dart';
import '../modules/workers/bindings/worker_binding.dart';
import '../modules/workers/views/worker_view.dart';

part 'app_routes.dart';

// ignore: avoid_classes_with_only_static_members
class AppPages {
  AppPages._();

  static const INITIAL = Routes.root;

  static final routes = [
    // ---- 嵌套路由：根 + 两层子路由 ----
    // 根路由是整个示例的壳（只提供一个 GetRouterOutlet），下面所有页面
    // 都是它的子路由；default child 是示例目录。
    GetPage(
      name: Routes.root,
      page: () => const RootView(),
      binding: RootBinding(),
      participatesInRootNavigator: true,
      preventDuplicates: true,
      children: [
        GetPage(
          name: Routes.menu,
          page: () => const MenuView(),
        ),
        GetPage(
          name: Routes.login,
          page: () => const LoginView(),
          binding: LoginBinding(),
          // 已登录时不该再看到登录页
          middlewares: [EnsureNotAuthedMiddleware()],
        ),
        GetPage(
          name: Routes.home,
          page: () => const HomeView(),
          binding: HomeBinding(),
          children: [
            GetPage(
              name: Routes.dashboard,
              page: () => const DashboardView(),
              binding: DashboardBinding(),
            ),
            GetPage(
              name: Routes.profile,
              page: () => const ProfileView(),
              binding: ProfileBinding(),
              title: 'Profile',
              transition: Transition.size,
              // 未登录会被中间件弹回登录页
              middlewares: [EnsureAuthMiddleware()],
            ),
            GetPage(
              name: Routes.products,
              page: () => const ProductsView(),
              binding: ProductsBinding(),
              bindings: [ProductDetailsBinding()],
              title: 'Products',
              transition: Transition.cupertino,
              showCupertinoParallax: true,
              participatesInRootNavigator: false,
              children: [
                GetPage(
                  name: Routes.productDetails,
                  page: () => const ProductDetailsView(),
                  middlewares: [EnsureAuthMiddleware()],
                  transition: Transition.cupertino,
                  showCupertinoParallax: true,
                ),
              ],
            ),
          ],
        ),
        GetPage(
          name: Routes.settings,
          page: () => const SettingsView(),
          binding: SettingsBinding(),
        ),
      ],
    ),

    // ---- 扁平路由：各能力模块 ----
    GetPage(
      name: Routes.countries,
      page: () => const CountryListView(),
      binding: CountryListBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: Routes.countryDetails,
      page: () => const CountryDetailsView(),
      binding: CountryDetailsBinding(),
    ),
    GetPage(
      name: Routes.stateful,
      page: () => const StatefulView(),
      binding: CounterBinding(),
    ),
    GetPage(
      name: Routes.rxTypes,
      page: () => const RxTypesView(),
      binding: RxTypesBinding(),
    ),
    GetPage(
      name: Routes.workers,
      page: () => const WorkerView(),
      binding: WorkerBinding(),
    ),
    GetPage(
      name: Routes.pagination,
      page: () => const PaginationView(),
      binding: PaginationBinding(),
    ),
    GetPage(
      name: Routes.lifecycle,
      page: () => const LifecycleView(),
      binding: LifecycleBinding(),
    ),
    GetPage(
      name: Routes.instance,
      page: () => const InstanceView(),
      binding: InstanceBinding(),
    ),
    GetPage(
      name: Routes.bindings,
      page: () => const BindingsDemoView(),
      binding: BindingsDemoBinding(),
    ),
    GetPage(
      name: Routes.overlays,
      page: () => const OverlaysView(),
    ),
    GetPage(
      name: Routes.navigation,
      page: () => const NavigationView(),
    ),
    GetPage(
      name: Routes.transitions,
      page: () => const TransitionsView(),
    ),

    // 过渡与跳转示例共用的落点页
    GetPage(
      name: Routes.transitionTarget,
      page: () => const NavigationTargetView(),
      transition: Transition.downToUp,
    ),
  ];
}
