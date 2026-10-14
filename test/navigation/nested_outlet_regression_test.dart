import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:get/get.dart';

/// 嵌套路由回归测试。
///
/// 路由表与 example 一致：`/` 是壳（participatesInRootNavigator: true），
/// 壳里嵌一层 `/home`，`/home` 里再嵌 `/products` → `/products/:productId`。
class NavTestController extends GetxController {
  final taps = 0.obs;
  void tap() => taps.value++;
}

class ShellPage extends StatelessWidget {
  const ShellPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: RouterListener(builder: (c) => Text(c.location))),
      body: GetRouterOutlet(initialRoute: '/menu', anchorRoute: '/'),
    );
  }
}

class MenuPage extends StatelessWidget {
  const MenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () => Get.toNamed('/home'),
          child: const Text('go home'),
        ),
      ),
    );
  }
}

class HomePage extends GetView<NavTestController> {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return GetRouterOutlet.builder(
      route: '/home',
      builder: (context) => Scaffold(
        body: GetRouterOutlet(initialRoute: '/dashboard', anchorRoute: '/home'),
        bottomNavigationBar: IndexedRouteBuilder(
          routes: const ['/home/dashboard', '/home/profile', '/home/products'],
          builder: (context, routes, index) => BottomNavigationBar(
            currentIndex: index,
            onTap: (i) => context.delegate.toNamed(routes[i]),
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
              BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Me'),
              BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Items'),
            ],
          ),
        ),
      ),
    );
  }
}

class DashboardPage extends GetView<NavTestController> {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('dashboard'),
            Obx(() => Text('taps: ${controller.taps.value}')),
            ElevatedButton(onPressed: controller.tap, child: const Text('tap')),
          ],
        ),
      ),
    );
  }
}

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: Text('profile')));
  }
}

class ProductsPage extends StatelessWidget {
  const ProductsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () => Get.toNamed('/home/products/p1'),
          child: const Text('open product'),
        ),
      ),
    );
  }
}

class ProductDetailsPage extends StatelessWidget {
  const ProductDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('product ${Get.parameters['productId'] ?? ''}'),
            ElevatedButton(onPressed: Get.back, child: const Text('back')),
          ],
        ),
      ),
    );
  }
}

class CountriesPage extends StatelessWidget {
  const CountriesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () => Get.toNamed('/menu'),
          child: const Text('back to menu'),
        ),
      ),
    );
  }
}

List<GetPage> _routes() => [
      GetPage(
        name: '/',
        page: () => const ShellPage(),
        participatesInRootNavigator: true,
        binds: [Bind.create<NavTestController>((_) => NavTestController())],
        children: [
          GetPage(name: '/menu', page: () => const MenuPage()),
          GetPage(
            name: '/home',
            page: () => const HomePage(),
            children: [
              GetPage(name: '/dashboard', page: () => const DashboardPage()),
              GetPage(name: '/profile', page: () => const ProfilePage()),
              GetPage(
                name: '/products',
                page: () => const ProductsPage(),
                participatesInRootNavigator: false,
                children: [
                  GetPage(
                    name: '/:productId',
                    page: () => const ProductDetailsPage(),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
      GetPage(name: '/countries', page: () => const CountriesPage()),
    ];

Future<void> _settle(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 700));
  await tester.pump(const Duration(milliseconds: 1500));
}

void main() {
  setUp(() => Get.testMode = true);
  tearDown(Get.reset);

  Future<void> boot(WidgetTester tester) async {
    await tester.pumpWidget(
      GetMaterialApp(initialRoute: '/', getPages: _routes()),
    );
    await _settle(tester);
  }

  testWidgets('嵌套壳：进入 /home 并切 tab', (tester) async {
    await boot(tester);
    expect(find.text('go home'), findsOneWidget);

    await tester.tap(find.text('go home'));
    await _settle(tester);
    expect(find.text('dashboard'), findsOneWidget);

    await tester.tap(find.text('Me'));
    await _settle(tester);
    expect(find.text('profile'), findsOneWidget);

    await tester.tap(find.text('Home'));
    await _settle(tester);
    expect(find.text('dashboard'), findsOneWidget);
  });

  testWidgets('嵌套壳：三级下钻 /home/products/p1 后返回', (tester) async {
    await boot(tester);
    await tester.tap(find.text('go home'));
    await _settle(tester);

    await tester.tap(find.text('Items'));
    await _settle(tester);
    expect(find.text('open product'), findsOneWidget);

    await tester.tap(find.text('open product'));
    await _settle(tester);
    expect(find.text('product p1'), findsOneWidget);

    await tester.tap(find.text('back'));
    await _settle(tester);
    expect(find.text('open product'), findsOneWidget);
  });

  testWidgets('从嵌套壳跳到扁平路由再跳回', (tester) async {
    await boot(tester);
    await tester.tap(find.text('go home'));
    await _settle(tester);
    expect(find.text('dashboard'), findsOneWidget);

    // 不 await：toNamed 的 future 要等页面被 pop 才完成
    Get.toNamed('/countries');
    await _settle(tester);
    expect(find.text('back to menu'), findsOneWidget);

    await tester.tap(find.text('back to menu'));
    await _settle(tester);
    expect(find.text('go home'), findsOneWidget);
  });
}
