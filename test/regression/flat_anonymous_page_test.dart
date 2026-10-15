import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:get/get.dart';

/// 纯扁平路由（全程没有任何 participatesInRootNavigator 声明）下的匿名页回归。
///
/// `Get.to` / `Get.off` / `Get.offAll` 合成的匿名 GetPage 声明了
/// participatesInRootNavigator: true（为了让它在嵌套路由的 app 里留在根
/// navigator，而不是落进 outlet 被当前页盖住）。这会让 `getVisualPages`
/// 走进「历史里只收 pinRN==true 的页」的分支 —— 纯扁平 app 的历史页全是
/// null，全被过滤掉，前一页就被从根 navigator 挤出去销毁了（状态、
/// controller 全丢，back 回去是重建的新页面）。
///
/// 修复：历史扫描同时保留「branch 里没有任何 true 祖先的顶层 null 页」。
/// 嵌套叶子页（branch 里带 true 壳祖先）仍被剔除、由 outlet 渲染。
class FlatHomePage extends StatefulWidget {
  const FlatHomePage({super.key});
  @override
  State<FlatHomePage> createState() => _FlatHomePageState();
}

class _FlatHomePageState extends State<FlatHomePage> {
  int counter = 0;
  @override
  Widget build(BuildContext context) => Scaffold(
        body: Center(
          child: Column(
            children: [
              Text('home-counter-$counter'),
              ElevatedButton(
                onPressed: () => setState(() => counter++),
                child: const Text('inc'),
              ),
              ElevatedButton(
                onPressed: () => Get.to(() => const DetailsPage()),
                child: const Text('go details'),
              ),
              ElevatedButton(
                onPressed: () => Get.toNamed('/other'),
                child: const Text('go other'),
              ),
            ],
          ),
        ),
      );
}

class DetailsPage extends StatelessWidget {
  const DetailsPage({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('details')),
        body: Center(
          child: ElevatedButton(
            onPressed: Get.back,
            child: const Text('back'),
          ),
        ),
      );
}

class OtherPage extends StatelessWidget {
  const OtherPage({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('other')),
        body: Center(
          child: ElevatedButton(
            onPressed: () => Get.off(() => const DetailsPage()),
            child: const Text('off details'),
          ),
        ),
      );
}

List<GetPage> _flatRoutes() => [
      GetPage(name: '/home', page: () => const FlatHomePage()),
      GetPage(name: '/other', page: () => const OtherPage()),
    ];

Future<void> _settle(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 700));
  await tester.pump(const Duration(milliseconds: 1500));
}

void main() {
  setUp(() => Get.testMode = true);
  tearDown(Get.reset);

  group('纯扁平路由 + 匿名页', () {
    Future<void> boot(WidgetTester tester) async {
      await tester.pumpWidget(
        GetMaterialApp(initialRoute: '/home', getPages: _flatRoutes()),
      );
      await _settle(tester);
    }

    testWidgets('Get.to 后前一页必须留在 Navigator 栈里且状态保留', (tester) async {
      await boot(tester);

      await tester.tap(find.text('inc'));
      await tester.pump();
      expect(find.text('home-counter-1'), findsOneWidget);

      await tester.tap(find.text('go details'));
      await _settle(tester);

      expect(find.text('details'), findsOneWidget);
      // 关键断言：前一页必须还在栈里（转场后 offstage），不能被销毁。
      expect(
        find.byType(FlatHomePage, skipOffstage: false),
        findsOneWidget,
        reason: 'Get.to 压栈后前一页必须保留在 Navigator 栈中',
      );

      Get.back();
      await _settle(tester);

      expect(
        find.text('home-counter-1'),
        findsOneWidget,
        reason: 'back 回到前一页，页面状态（counter）必须保留',
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('Get.off 只替换栈顶，底下的页要保住', (tester) async {
      await boot(tester);

      await tester.tap(find.text('go other'));
      await _settle(tester);
      expect(find.text('other'), findsOneWidget);

      await tester.tap(find.text('off details'));
      await _settle(tester);

      expect(find.text('details'), findsOneWidget);
      expect(find.text('other'), findsNothing, reason: 'off 的语义就是替换栈顶');
      // home 是被压在底下的历史页，off 不该动它。
      expect(
        find.byType(FlatHomePage, skipOffstage: false),
        findsOneWidget,
        reason: 'Get.off 只替换栈顶，栈底历史页不能被销毁',
      );

      Get.back();
      await _settle(tester);
      expect(find.text('home-counter-0'), findsOneWidget,
          reason: 'off details 后 back 应回到 home');
      expect(tester.takeException(), isNull);
    });

    testWidgets('Get.offAll 清空历史，栈里只剩匿名页', (tester) async {
      await boot(tester);

      await tester.tap(find.text('go other'));
      await _settle(tester);

      Get.offAll(() => const DetailsPage());
      await _settle(tester);

      expect(find.text('details'), findsOneWidget);
      expect(find.byType(OtherPage, skipOffstage: false), findsNothing);
      expect(Get.rootController.rootDelegate.canBack, isFalse,
          reason: 'offAll 之后栈深为 1，Get.back 必须是空操作');

      Get.back();
      await _settle(tester);
      expect(find.text('details'), findsOneWidget,
          reason: '栈深为 1 时 back 是空操作，页面必须原样留在屏幕上');
      expect(tester.takeException(), isNull);
    });
  });

  group('嵌套路由 + 匿名页（锁死 375eda57 修复的行为）', () {
    testWidgets('从 outlet 页 Get.to，匿名页必须可见且不落进 outlet', (tester) async {
      const shellKey = Key('shell');
      await tester.pumpWidget(
        GetMaterialApp(
          initialRoute: '/',
          getPages: [
            GetPage(
              name: '/',
              page: () => Scaffold(
                key: shellKey,
                body: GetRouterOutlet(initialRoute: '/menu', anchorRoute: '/'),
              ),
              participatesInRootNavigator: true,
              children: [
                GetPage(
                  name: '/menu',
                  page: () => Scaffold(
                    body: Center(
                      child: ElevatedButton(
                        onPressed: () => Get.to(() => const DetailsPage()),
                        child: const Text('go details'),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
      await _settle(tester);
      expect(find.byKey(shellKey), findsOneWidget);

      await tester.tap(find.text('go details'));
      await _settle(tester);

      // 匿名页声明了 pinRN:true，必须留在根 navigator：
      // 可见、不在 outlet 里（祖先链上没有 GetRouterOutlet）。
      expect(find.text('details'), findsOneWidget);
      expect(tester.takeException(), isNull,
          reason: '匿名页进根 navigator 不能引发任何渲染异常');

      Get.back();
      await _settle(tester);
      expect(find.text('go details'), findsOneWidget,
          reason: 'back 后应回到 outlet 里的 menu 页');
      expect(tester.takeException(), isNull);
    });
  });
}
