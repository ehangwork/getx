import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:get/get.dart';

/// 路由白屏回归测试。
///
/// `getVisualPages` 在「用户声明过 participatesInRootNavigator」的分支里，
/// 只从 `_activePages` 每一项取**末页**再按 pinRN==true 过滤。
/// 但分支内部那些 pinRN==true 的**祖先**（这里就是嵌套壳 `/`）不在历史项的末页里，
/// 一旦历史被压成一条（例如 `Get.offAllNamed` 到嵌套叶子页），过滤结果为空列表
/// → `build` 返回 ColoredBox → 白屏。
///
/// 路由表与 nested_outlet_regression_test.dart 保持一致，便于对照。
class ShellPage extends StatelessWidget {
  const ShellPage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('shell')),
        body: GetRouterOutlet(initialRoute: '/menu', anchorRoute: '/'),
      );
}

class MenuPage extends StatelessWidget {
  const MenuPage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Center(
          child: ElevatedButton(
            onPressed: () => Get.toNamed('/home'),
            child: const Text('go home'),
          ),
        ),
      );
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) => GetRouterOutlet.builder(
        route: '/home',
        builder: (context) => Scaffold(
          body: GetRouterOutlet(initialRoute: '/dashboard', anchorRoute: '/home'),
          bottomNavigationBar: IndexedRouteBuilder(
            routes: const ['/home/dashboard', '/home/profile'],
            builder: (context, routes, index) => BottomNavigationBar(
              currentIndex: index,
              onTap: (i) => context.delegate.toNamed(routes[i]),
              items: const [
                BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
                BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Me'),
              ],
            ),
          ),
        ),
      );
}

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: Text('dashboard')));
}

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: Text('profile')));
}

class TopPage extends StatelessWidget {
  const TopPage({super.key});

  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: Text('top')));
}

List<GetPage> _routes() => [
      GetPage(
        name: '/',
        page: () => const ShellPage(),
        participatesInRootNavigator: true,
        children: [
          GetPage(name: '/menu', page: () => const MenuPage()),
          GetPage(
            name: '/home',
            page: () => const HomePage(),
            children: [
              GetPage(name: '/dashboard', page: () => const DashboardPage()),
              GetPage(name: '/profile', page: () => const ProfilePage()),
            ],
          ),
        ],
      ),
      GetPage(name: '/top', page: () => const TopPage()),
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

  Future<void> enterHome(WidgetTester tester) async {
    await boot(tester);
    await tester.tap(find.text('go home'));
    await _settle(tester);
  }

  testWidgets('嵌套壳能正常进入（守基准）', (tester) async {
    await enterHome(tester);
    expect(find.text('dashboard'), findsOneWidget);
  });

  testWidgets('offAllNamed 到嵌套叶子页不能白屏', (tester) async {
    await enterHome(tester);
    expect(find.text('dashboard'), findsOneWidget);

    Get.offAllNamed('/home/dashboard');
    await _settle(tester);

    expect(
      find.text('dashboard'),
      findsOneWidget,
      reason: '嵌套路由下 offAllNamed 后必须还能看到页面，不能只剩 ColoredBox',
    );
  });

  testWidgets('offAllNamed 到嵌套叶子页后还能再跳到顶层扁平页', (tester) async {
    await enterHome(tester);
    expect(find.text('dashboard'), findsOneWidget);

    Get.offAllNamed('/home/dashboard');
    await _settle(tester);
    expect(find.text('dashboard'), findsOneWidget);

    Get.offAllNamed('/top');
    await _settle(tester);
    expect(find.text('top'), findsOneWidget);
  });

  testWidgets('offAllNamed 到嵌套叶子页后 back 不应退回上一页，也不该白屏',
      (tester) async {
    await enterHome(tester);
    expect(find.text('dashboard'), findsOneWidget);

    Get.offAllNamed('/home/dashboard');
    await _settle(tester);
    expect(find.text('dashboard'), findsOneWidget);

    // offAllNamed 的语义就是「清掉全部历史」，所以 back 没有可退的目标，
    // 但也不能因此退化成白屏。
    Get.back();
    await _settle(tester);

    expect(
      find.text('go home'),
      findsNothing,
      reason: 'offAllNamed 之后不应还能退回之前的页面',
    );
    expect(
      find.text('dashboard'),
      findsOneWidget,
      reason: 'back 之后仍要有内容，不能白屏',
    );
  });
}
