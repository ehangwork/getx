import 'dart:async';

import 'package:get/get.dart';

class DashboardController extends GetxController {
  final now = DateTime.now().obs;

  Timer? _clock;

  @override
  void onReady() {
    super.onReady();
    _clock = Timer.periodic(
      const Duration(seconds: 1),
      (_) => now.value = DateTime.now(),
    );
  }

  @override
  void onClose() {
    _clock?.cancel();
    super.onClose();
  }
}
