import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:get/get.dart';

/// outlet 不得渲染声明了 participatesInRootNavigator: true 的页。
///
/// 这类页由根 navigator 渲染，但它们同样留在 currentTreeBranch 上，
/// outlet 的 pickAfterRoute 会把它们一起捞走，于是同一个 GetPage 被两个
/// Navigator 各建一份：两套 widget 实例、两套 controller，页面上看着「多了一层」。
///
/// 匿名页（Get.to/off/offAll 合成）都钉了 pinRN: true，所以从 outlet 页
/// Get.to 是最容易触到这条路径的入口。两种嵌套写法都要覆盖：
/// 壳声明 pinRN: true 的规范写法，以及全链都不声明的写法。

class OutletShell extends StatelessWidget {
  const OutletShell({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
        body: GetRouterOutlet(initialRoute: '/menu', anchorRoute: '/'),
      );
}

class OutletMenu extends StatelessWidget {
  const OutletMenu({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
        body: Center(
          child: ElevatedButton(
            onPressed: () => Get.to(() => const OutletDetails()),
            child: const Text('go details'),
          ),
        ),
      );
}

class OutletDetails extends StatelessWidget {
  const OutletDetails({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('details')),
        body: const Center(child: Text('details-body')),
      );
}

Future<void> _settle(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 700));
  await tester.pump(const Duration(milliseconds: 1500));
}

GetPage _shell({required bool declaredPinRN}) => GetPage(
      name: '/',
      page: () => const OutletShell(),
      participatesInRootNavigator: declaredPinRN ? true : null,
      children: [
        GetPage(name: '/menu', page: () => const OutletMenu()),
      ],
    );

void main() {
  setUp(() => Get.testMode = true);
  tearDown(Get.reset);

  group('outlet 不渲染 pinRN:true 的页', () {
    for (final declared in [true, false]) {
      final label = declared ? '壳声明 pinRN:true（规范写法）' : '全链都不声明 pinRN';

      testWidgets('$label：从 outlet 页 Get.to，详情页只该有一份', (tester) async {
        await tester.pumpWidget(GetMaterialApp(
          initialRoute: '/',
          getPages: [_shell(declaredPinRN: declared)],
        ));
        await _settle(tester);
        expect(find.byType(OutletShell), findsOneWidget);

        await tester.tap(find.text('go details'));
        await _settle(tester);

        expect(find.text('details'), findsOneWidget);
        expect(
          find.byType(OutletDetails, skipOffstage: false),
          findsOneWidget,
          reason: '同一个 GetPage 被根 navigator 与 outlet 各建了一份，'
              '会出现两套 widget 实例、两套 controller',
        );
        expect(tester.takeException(), isNull);
      });

      testWidgets('$label：Get.back 后 outlet 页完好', (tester) async {
        await tester.pumpWidget(GetMaterialApp(
          initialRoute: '/',
          getPages: [_shell(declaredPinRN: declared)],
        ));
        await _settle(tester);

        await tester.tap(find.text('go details'));
        await _settle(tester);

        Get.back();
        await _settle(tester);

        expect(find.text('go details'), findsOneWidget,
            reason: 'back 应回到 outlet 里的 menu 页');
        expect(find.byType(OutletDetails, skipOffstage: false), findsNothing);
        expect(tester.takeException(), isNull);
      });
    }
  });

  testWidgets('嵌套但没有匿名页时，outlet 仍只渲染一个 menu', (tester) async {
    await tester.pumpWidget(GetMaterialApp(
      initialRoute: '/menu',
      getPages: [_shell(declaredPinRN: true)],
    ));
    await _settle(tester);

    expect(find.byType(OutletMenu, skipOffstage: false), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
