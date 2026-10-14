import 'package:material_ui/material_ui.dart';
import 'package:get/get.dart';

class Wrapper extends StatelessWidget {
  final Widget? child;
  final List<GetPage>? namedRoutes;
  final String? initialRoute;
  final Transition? defaultTransition;

  const Wrapper({
    super.key,
    this.child,
    this.namedRoutes,
    this.initialRoute,
    this.defaultTransition,
  });

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      defaultTransition: defaultTransition,
      initialRoute: initialRoute,
      locale: const Locale('en', 'US'),
      getPages: namedRoutes,
      home: namedRoutes == null
          ? Scaffold(
              body: child,
            )
          : null,
    );
  }
}

class WrapperNamed extends StatelessWidget {
  final Widget? child;
  final List<GetPage>? namedRoutes;
  final String? initialRoute;
  final Transition? defaultTransition;

  const WrapperNamed({
    super.key,
    this.child,
    this.namedRoutes,
    this.initialRoute,
    this.defaultTransition,
  });

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      defaultTransition: defaultTransition,
      initialRoute: initialRoute,
      getPages: namedRoutes,
    );
  }
}
