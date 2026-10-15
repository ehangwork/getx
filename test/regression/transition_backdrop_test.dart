import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:get/get.dart';

/// WithFade 系过渡的中间帧，两页会同时失去全屏覆盖：
/// 下方页被 secondaryAnimation 整页推走、新页只覆盖部分屏幕且半透明。
/// Router 底下必须垫一层主题背景色（scaffoldBackgroundColor），
/// 露出来的区域才是主题色，而不是未绘制表面（黑）。
///
/// 采样点选在下方页腾出的那一侧：rightToLeftWithFade push 时下方页
/// 向左离屏，左侧边缘最先露底。
class GreenPage extends StatelessWidget {
  const GreenPage({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: const Color(0xFF00CC00),
        body: Center(
          child: ElevatedButton(
            onPressed: () => Get.to(
              () => const MagentaPage(),
              transition: Transition.rightToLeftWithFade,
              duration: const Duration(milliseconds: 600),
            ),
            child: const Text('go'),
          ),
        ),
      );
}

class MagentaPage extends StatelessWidget {
  const MagentaPage({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: const Color(0xFFCC00CC),
        appBar: AppBar(title: const Text('B')),
      );
}

Color _pixel(ui.Image image, ByteData data, int x, int y) {
  final offset = (y * image.width + x) * 4;
  return Color.fromARGB(
    data.getUint8(offset + 3),
    data.getUint8(offset),
    data.getUint8(offset + 1),
    data.getUint8(offset + 2),
  );
}

/// 允许 ±2 的每通道误差，规避抗锯齿/合成舍入。
bool _near(Color a, Color b) {
  // 走 0..1 的浮点通道再折回 0..255：Color.red/green/blue 这三个 int
  // getter 在 Flutter 3.47 已废弃。
  int ch(double v) => (v * 255.0).round().clamp(0, 255);

  return (ch(a.r) - ch(b.r)).abs() <= 2 &&
      (ch(a.g) - ch(b.g)).abs() <= 2 &&
      (ch(a.b) - ch(b.b)).abs() <= 2;
}

void main() {
  setUp(() => Get.testMode = true);
  tearDown(Get.reset);

  /// 取样必须包在 runAsync 里：captureImage 走的是引擎光栅线程的真实异步
  /// future，留在 testWidgets 的 fake-async 区域内永不完成，整个套件会挂死。
  Future<Color> sampleLeftEdge(WidgetTester tester) async {
    late Color pixel;
    await tester.runAsync(() async {
      final image = await captureImage(
        find.byType(GetMaterialApp).evaluate().single,
      );
      final data = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
      // 800x600 测试视口，左侧边缘、垂直居中。
      pixel = _pixel(image, data!, 8, 300);
    });
    return pixel;
  }

  Future<void> pushMidFrame(
    WidgetTester tester, {
    ThemeData? theme,
    ThemeData? darkTheme,
    ThemeMode themeMode = ThemeMode.light,
  }) async {
    await tester.pumpWidget(GetMaterialApp(
      initialRoute: '/a',
      theme: theme,
      darkTheme: darkTheme,
      themeMode: themeMode,
      getPages: [
        GetPage(name: '/a', page: () => const GreenPage()),
        GetPage(name: '/b', page: () => const MagentaPage()),
      ],
    ));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 700));

    await tester.tap(find.text('go'));
    await tester.pump(); // t=0，转场启动
    await tester.pump(const Duration(milliseconds: 320)); // 600ms 的中段
  }

  testWidgets('WithFade 中间帧的露底区必须是主题背景色（默认浅色主题）',
      (tester) async {
    await pushMidFrame(tester);

    final pixel = await sampleLeftEdge(tester);
    final expected = ThemeData.fallback().scaffoldBackgroundColor;
    expect(
      _near(pixel, expected),
      isTrue,
      reason:
          '露底区像素应为主题 scaffoldBackgroundColor($expected)，实际为 $pixel',
    );
  });

  testWidgets('暗色主题下露底区也要跟随暗色背景', (tester) async {
    final darkTheme = ThemeData(brightness: Brightness.dark);
    await pushMidFrame(
      tester,
      theme: ThemeData(brightness: Brightness.light),
      darkTheme: darkTheme,
      themeMode: ThemeMode.dark,
    );

    final pixel = await sampleLeftEdge(tester);
    expect(
      _near(pixel, darkTheme.scaffoldBackgroundColor),
      isTrue,
      reason: '暗色模式下露底区应跟随暗色 scaffoldBackgroundColor，实际为 $pixel',
    );
  });
}
