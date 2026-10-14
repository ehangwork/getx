part of 'app_pages.dart';

// ignore_for_file: non_constant_identifier_names

abstract class Routes {
  Routes._();

  /// 示例总目录，所有能力演示的入口
  static const menu = '/menu';

  /// 嵌套路由的根：只提供一个 GetRouterOutlet，不画任何控件
  static const root = '/';

  // ---- 嵌套路由的子路径 ----
  static const login = '/login';
  static const home = '/home';
  static const dashboard = '/dashboard';
  static const profile = '/profile';
  static const products = '/products';
  static const settings = '/settings';

  // ---- 扁平路由：各能力模块 ----
  static const countries = '/countries';
  static const countryDetails = '/country-details';
  static const stateful = '/stateful';
  static const rxTypes = '/rx-types';
  static const workers = '/workers';
  static const bindings = '/bindings';
  static const overlays = '/overlays';
  static const navigation = '/navigation';
  static const transitions = '/transitions';
  static const transitionTarget = '/transition-target';
  static const lifecycle = '/lifecycle';
  static const pagination = '/pagination';
  static const instance = '/instance';

  /// 嵌套子路由的 name 只能是相对段，完整路径是父段直接拼接（`//home/products`）
  static const productDetails = '/:productId';

  /// 深层子路由在路由表里注册的是完整路径，
  /// outlet 的 initialRoute / IndexedRouteBuilder / Get.toNamed 都得用完整路径
  static const homeDashboard = '$home$dashboard';
  static const homeProfile = '$home$profile';
  static const homeProducts = '$home$products';

  static String LOGIN_THEN(String afterSuccessfulLogin) =>
      '$login?then=${Uri.encodeQueryComponent(afterSuccessfulLogin)}';

  static String PRODUCT_DETAILS(String productId) => '$homeProducts/$productId';
}
