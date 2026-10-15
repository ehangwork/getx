@TestOn('vm')
library;

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

void main() {
  test('Platform test', () {
    expect(GetPlatform.isAndroid, Platform.isAndroid);
    expect(GetPlatform.isIOS, Platform.isIOS);
    expect(GetPlatform.isFuchsia, Platform.isFuchsia);
    expect(GetPlatform.isLinux, Platform.isLinux);
    expect(GetPlatform.isMacOS, Platform.isMacOS);
    expect(GetPlatform.isWindows, Platform.isWindows);
  });

  test('io 实现下 isWeb 恒为 false，且 isMobile/isDesktop 是各平台判定的派生',
      () {
    // GetPlatform 走条件导入：web 编译时才命中 platform_web.dart（isWeb 为
    // true），native 编译走 platform_io.dart。这里跑在 VM 上，只锁住 native 侧。
    expect(GetPlatform.isWeb, isFalse);
    expect(
      GetPlatform.isMobile,
      Platform.isIOS || Platform.isAndroid,
    );
    expect(
      GetPlatform.isDesktop,
      Platform.isMacOS || Platform.isWindows || Platform.isLinux,
    );
    expect(
      [GetPlatform.isMobile, GetPlatform.isDesktop].any((e) => e),
      isTrue,
      reason: '测试跑在真实宿主上，移动端或桌面端至少应命中一个',
    );
  });
}
