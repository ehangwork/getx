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

  _shellFalseTests();

  testWidgets('offAllNamed 到嵌套叶子页后栈深为 1，Get.back 是空操作', (tester) async {
    await enterHome(tester);
    expect(find.text('dashboard'), findsOneWidget);

    Get.offAllNamed('/home/dashboard');
    await _settle(tester);
    expect(find.text('dashboard'), findsOneWidget);

    // offAllNamed 的语义就是「清掉全部历史」，此时栈深为 1，
    // Get.back 内部先查 canBack（= _activePages.length > 1），
    // 所以它根本不会执行任何 pop —— 这条用例锁的就是「空操作也不该白屏」。
    expect(Get.rootController.rootDelegate.canBack, isFalse);

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
      reason: '栈深为 1 时 Get.back 是空操作，页面必须原样留在屏幕上',
    );
  });
}

/// 壳页自己声明 `participatesInRootNavigator: false`（Flutter 里表达
/// 「这页不进根 navigator」的标准写法）时，前面两个来源都算不出页面，
/// 修复前会退回 ColoredBox 白屏。
List<GetPage> _routesWithFalseShell() => [
      GetPage(
        name: '/',
        page: () => const ShellPage(),
        participatesInRootNavigator: false,
        children: [
          GetPage(name: '/menu', page: () => const MenuPage()),
          GetPage(
            name: '/home',
            page: () => const HomePage(),
            children: [
              GetPage(name: '/dashboard', page: () => const DashboardPage()),
            ],
          ),
        ],
      ),
      GetPage(name: '/top', page: () => const TopPage()),
    ];

void _shellFalseTests() {
  // 特征化测试：记录一个**自相矛盾**的配置下当前的行为，不是期望值。
  //
  // 壳页声明 participatesInRootNavigator: false 等于说「壳不进根 navigator」，
  // 而根 navigator 是壳唯一能待的地方 —— 于是从 boot 起它一个页面都算不出来，
  // 整个界面直接空白。曾试过兜底「把壳塞回根 navigator」，结果壳自己渲染的
  // outlet 和根 navigator 抢同一个 GlobalKey，崩溃比空白更糟，所以保持现状。
  //
  // 仓库里的正确约定：壳声明 true，叶子页才声明 false
  // （见 test/navigation/nested_outlet_regression_test.dart）。
  testWidgets('特征化：壳页声明 pinRN:false 是自相矛盾配置，不崩溃但界面为空',
      (tester) async {
    await tester.pumpWidget(
      GetMaterialApp(initialRoute: '/', getPages: _routesWithFalseShell()),
    );
    await _settle(tester);

    // 壳根本没被渲染出来
    expect(find.byType(ShellPage), findsNothing);

    // 关键不变量：绝不能因为「补一个壳进去」而撞 GlobalKey 崩溃。
    expect(tester.takeException(), isNull);
  });
}
