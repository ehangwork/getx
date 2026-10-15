import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:get/get.dart';

/// #3139(a)：PageRedirect 的重定向循环必须能终止。
///
/// `getPageToRoute` 里原本是 `while (needRecheck(context)) {}` —— 没有迭代上限，
/// 也没有「这一轮没有进展」的判断。两种情况会同步死循环、整个界面冻住：
/// 1. middleware 的 redirect 每次都返回同一个目标（永远收敛不了）；
/// 2. 像 #3139 那样，redirect 新增的路径参数读不回来，中间件认为参数还是缺，
///    又生成一个新值再 redirect（每轮都"有进展"，但参数永远补不齐）。
///
/// 注意这条链路的真实语义：GetX 5 的导航由 delegate 的 `redirectDelegate` 驱动，
/// `redirect(String?)` 只被 legacy 的 `PageRedirect` 消费 —— 它决定「用哪个 GetPage
/// 构造路由」，不影响最终停在哪一页。所以用例断言的是**调用次数与是否终止**，
/// 而不是页面最终显示哪个。
///
/// 用例里的中间件会在被调用 guard 次之后抛错，这样修复前是**快速失败**而不是挂死。
class EndlessRedirector extends GetMiddleware {
  EndlessRedirector(this.guard);

  final int guard;
  int calls = 0;

  @override
  RouteSettings? redirect(String? route) {
    calls++;
    if (calls > guard) {
      throw StateError('redirect 无限循环：已经被调用 $calls 次仍未收敛');
    }
    return const RouteSettings(name: '/target');
  }
}

/// 固定在两个目标之间来回跳：每轮拿到的名字都在变，
/// 「无进展」判定永远不触发，只能靠 maxRedirectRounds 兜底。
/// 这是唯一能真正测到硬上限的形态。
class Flipper extends GetMiddleware {
  Flipper(this.to);

  final String to;
  int calls = 0;

  @override
  RouteSettings? redirect(String? route) {
    calls++;
    return RouteSettings(name: to);
  }
}

/// 每一步都换一个新目标、真正在推进的合法链路。
class ChainedRedirector extends GetMiddleware {
  int calls = 0;

  @override
  RouteSettings? redirect(String? route) {
    calls++;
    if (route == '/a') return const RouteSettings(name: '/target');
    if (route == '/target') return const RouteSettings(name: '/b');
    return null;
  }
}

List<GetPage> _routes(
  List<GetMiddleware> forA, {
  List<GetMiddleware>? forTarget,
  List<GetMiddleware>? forHop,
}) =>
    [
      GetPage(
        name: '/',
        page: () => const Scaffold(body: Text('home')),
      ),
      GetPage(
        name: '/a',
        page: () => const Scaffold(body: Text('a')),
        middlewares: forA,
      ),
      GetPage(
        name: '/target',
        page: () => const Scaffold(body: Text('target')),
        // #3139 的写法：重定向的落点页也挂了同一个中间件，于是每轮都会再 redirect。
        middlewares: forTarget ?? const [],
      ),
      GetPage(
        name: '/b',
        page: () => const Scaffold(body: Text('b')),
        middlewares: forHop ?? const [],
      ),
    ];

void main() {
  setUp(() => Get.testMode = true);
  tearDown(Get.reset);

  Future<void> settle(WidgetTester tester) async {
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 700));
    await tester.pump(const Duration(milliseconds: 1500));
  }

  testWidgets('收敛不了的 redirect 必须在有限轮内停下来', (tester) async {
    final mw = EndlessRedirector(20);

    await tester.pumpWidget(
      GetMaterialApp(
        initialRoute: '/',
        getPages: _routes([mw], forTarget: [mw]),
      ),
    );
    await settle(tester);
    expect(find.text('home'), findsOneWidget);

    Get.toNamed('/a');
    await settle(tester);

    expect(
      mw.calls,
      lessThanOrEqualTo(5),
      reason: '反复 redirect 到同一个目标时，应判定为「无进展」并立刻停止',
    );
  });

  testWidgets('迭代上限：目标每轮都在变时，靠 maxRedirectRounds 兜底', (tester) async {
    // /a → /b → /a → /b …… 每轮名字都不同，「无进展」判定不触发。
    final toB = Flipper('/b');
    final toA = Flipper('/a');

    await tester.pumpWidget(
      GetMaterialApp(
        initialRoute: '/',
        getPages: _routes([toB], forHop: [toA]),
      ),
    );
    await settle(tester);

    Get.toNamed('/a');
    await settle(tester);

    expect(
      toA.calls + toB.calls,
      PageRedirect.maxRedirectRounds,
      reason: '名字一直变时必须由硬上限终止，不能无限跑',
    );
    expect(
      toB.calls,
      PageRedirect.maxRedirectRounds ~/ 2,
      reason: '两侧交替被调用，各自约占一半',
    );
  });

  testWidgets('真正在推进的链式 redirect 仍要正常走完', (tester) async {
    final mw = ChainedRedirector();

    await tester.pumpWidget(
      GetMaterialApp(
        initialRoute: '/',
        getPages: _routes([mw], forTarget: [mw]),
      ),
    );
    await settle(tester);

    Get.toNamed('/a');
    await settle(tester);

    expect(
      mw.calls,
      2,
      reason: '/a → /target → /b 两跳都要跑完，不能被上限误伤截断',
    );
    expect(find.text('a'), findsOneWidget);
  });

  testWidgets('没有 middleware 时不受影响', (tester) async {
    await tester.pumpWidget(
      GetMaterialApp(initialRoute: '/', getPages: _routes([])),
    );
    await settle(tester);

    Get.toNamed('/a');
    await settle(tester);

    expect(find.text('a'), findsOneWidget);
  });
}
