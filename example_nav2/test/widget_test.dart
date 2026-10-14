import 'package:example_nav2/app/routes/app_pages.dart';
import 'package:example_nav2/services/auth_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

void main() {
  testWidgets('nav2 app mounts and reaches the root route hosting the nested tree',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      GetMaterialApp(
        binds: [Bind.put(AuthService())],
        getPages: AppPages.routes,
        initialRoute: AppPages.initial,
      ),
    );
    await tester.pump();
    // 抽屉与路由过渡会留下未触发的定时器，把时间轴推到底再收尾
    await tester.pump(const Duration(seconds: 2));

    expect(find.byType(GetMaterialApp), findsOneWidget);
    expect(Get.currentRoute, '/');
  });

  test('nested route table exposes every documented path', () {
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
      '/',
      '//login',
      '//home',
      '//settings',
      '//home/dashboard',
      '//home/profile',
      '//home/products',
      '//home/products/:productId',
    ]));
  });
}
