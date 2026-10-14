import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:get_demo/app/routes/app_pages.dart';
import 'package:get_demo/main.dart';

void main() {
  testWidgets('App 启动后落在示例目录', (WidgetTester tester) async {
    await tester.pumpWidget(const GetDemoApp());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.byType(GetMaterialApp), findsOneWidget);
    expect(find.text('GetX / GetBuilder / Obx'), findsOneWidget);
  });

  testWidgets('目录页列出了全部示例入口', (WidgetTester tester) async {
    await tester.pumpWidget(const GetDemoApp());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    // 首屏能看到的
    expect(find.text('响应式'), findsOneWidget);
    expect(find.text('GetX / GetBuilder / Obx'), findsOneWidget);
    expect(find.text('Rx 类型'), findsOneWidget);
    expect(find.text('ScrollMixin 分页'), findsOneWidget);

    // 往下滚到底，浮层与依赖那一组也要在
    await tester.scrollUntilVisible(find.text('StateController + futurize'), 200);
    await tester.pumpAndSettle();

    expect(find.text('嵌套路由'), findsOneWidget);
    expect(find.text('浮层'), findsOneWidget);
    expect(find.text('StateController + futurize'), findsOneWidget);
  });

  test('路由表把每个常量路径都注册了', () {
    final paths = <String>{};

    void collect(List<GetPage> pages, String prefix) {
      for (final page in pages) {
        final full = '$prefix${page.name}';
        paths.add(full);
        if (page.children.isNotEmpty) {
          collect(page.children, full);
        }
      }
    }

    collect(AppPages.routes, '');

    // 嵌套路由的完整路径是父路径与子路径直接拼接，根路由自身贡献一个 '/'
    expect(paths, containsAll(<String>[
      Routes.root,
      '//menu',
      '//login',
      '//home',
      '//settings',
      '//home/dashboard',
      '//home/profile',
      '//home/products',
      '//home/products/:productId',
      Routes.countries,
      Routes.countryDetails,
      Routes.stateful,
      Routes.rxTypes,
      Routes.workers,
      Routes.bindings,
      Routes.overlays,
      Routes.navigation,
      Routes.transitions,
      Routes.transitionTarget,
      Routes.lifecycle,
      Routes.pagination,
      Routes.instance,
    ]));
  });
}
