import 'package:flutter/foundation.dart' show TargetPlatform, defaultTargetPlatform;

// 浏览器上 dart:io 不可用，平台判定走 foundation 的 defaultTargetPlatform：
// Flutter web 会按浏览器 UA 报告宿主系统（android/iOS/macOS/windows/linux），
// 不需要为此引入 package:web。
// ignore: avoid_classes_with_only_static_members
class GeneralPlatform {
  static bool get isWeb => true;

  static bool get isMacOS => defaultTargetPlatform == TargetPlatform.macOS;

  static bool get isWindows => defaultTargetPlatform == TargetPlatform.windows;

  static bool get isLinux => defaultTargetPlatform == TargetPlatform.linux;

  static bool get isAndroid => defaultTargetPlatform == TargetPlatform.android;

  static bool get isIOS => defaultTargetPlatform == TargetPlatform.iOS;

  static bool get isFuchsia => defaultTargetPlatform == TargetPlatform.fuchsia;

  static bool get isDesktop =>
      GeneralPlatform.isMacOS ||
      GeneralPlatform.isWindows ||
      GeneralPlatform.isLinux;
}
