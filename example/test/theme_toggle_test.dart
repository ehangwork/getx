import 'package:flutter_test/flutter_test.dart';

import 'package:get_demo/app/modules/menu/views/menu_view.dart';
import 'package:get_demo/main.dart';
import 'package:material_ui/material_ui.dart';

/// 暗黑模式切换。
///
/// `Get.changeTheme` 只换调色板，不动 `themeMode`；
/// app 的 themeMode 默认是 system，设备在浅色模式下调用它看不到变化，
/// 所以手动切换必须走 `Get.changeThemeMode`。
void main() {
  Future<void> settle(WidgetTester tester, {int frames = 8}) async {
    for (var i = 0; i < frames; i++) {
      await tester.pump(const Duration(milliseconds: 120));
    }
  }

  testWidgets('点暗黑切换后主题真的变成 dark', (WidgetTester tester) async {
    await tester.pumpWidget(const GetDemoApp());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(
      Theme.of(tester.element(find.byType(MenuView))).brightness,
      Brightness.light,
    );

    await tester.tap(find.byIcon(Icons.dark_mode));
    await settle(tester);
    expect(
      Theme.of(tester.element(find.byType(MenuView))).brightness,
      Brightness.dark,
      reason: '点了切换但主题没变',
    );
    // 图标也要跟着换，不然用户不知道当前处于哪个模式
    expect(find.byIcon(Icons.light_mode), findsOneWidget);

    await tester.tap(find.byIcon(Icons.light_mode));
    await settle(tester);
    expect(
      Theme.of(tester.element(find.byType(MenuView))).brightness,
      Brightness.light,
      reason: '再点一次没切回浅色',
    );
  });
}
