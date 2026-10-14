import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:get_demo/main.dart';

void main() {
  testWidgets('lands on /first and renders its screen',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pump();
    Get.toNamed('/first');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(Get.currentRoute, '/first');
    expect(find.text('page one'), findsOneWidget);
  });

  testWidgets('/second receives query arguments', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pump();
    Get.toNamed('/second?id=123');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(Get.currentRoute, '/second');
    expect(Get.parameters['id'], '123');
  });
}
