// 默认分支：编译目标既非 web 也非 io 时占位（正常发布目标不会走到）。
// ignore: avoid_classes_with_only_static_members
class GeneralPlatform {
  static bool get isWeb => throw UnimplementedError();

  static bool get isMacOS => throw UnimplementedError();

  static bool get isWindows => throw UnimplementedError();

  static bool get isLinux => throw UnimplementedError();

  static bool get isAndroid => throw UnimplementedError();

  static bool get isIOS => throw UnimplementedError();

  static bool get isFuchsia => throw UnimplementedError();

  static bool get isDesktop => throw UnimplementedError();
}
