import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import '../../../get_core/get_core.dart';
import '../../../get_instance/src/extension_instance.dart';
import '../../../get_instance/src/lifecycle.dart';
import '../simple/get_controllers.dart';
import '../simple/list_notifier.dart';

typedef GetXControllerBuilder<T extends GetLifeCycleMixin> = Widget Function(
    T controller);

class GetX<T extends GetLifeCycleMixin> extends StatefulWidget {
  final GetXControllerBuilder<T> builder;
  final bool global;
  final bool autoRemove;
  final bool assignId;
  final void Function(GetXState<T> state)? initState,
      dispose,
      didChangeDependencies;
  final void Function(GetX oldWidget, GetXState<T> state)? didUpdateWidget;
  final T? init;
  final String? tag;

  const GetX({
    super.key,
    this.tag,
    required this.builder,
    this.global = true,
    this.autoRemove = true,
    this.initState,
    this.assignId = false,
    //  this.stream,
    this.dispose,
    this.didChangeDependencies,
    this.didUpdateWidget,
    this.init,
    // this.streamController
  });

  @override
  StatefulElement createElement() => StatefulElement(this);

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(
        DiagnosticsProperty<T>('controller', init),
      )
      ..add(DiagnosticsProperty<String>('tag', tag))
      ..add(
          ObjectFlagProperty<GetXControllerBuilder<T>>.has('builder', builder));
  }

  @override
  GetXState<T> createState() => GetXState<T>();
}

class GetXState<T extends GetLifeCycleMixin> extends State<GetX<T>> {
  T? controller;
  bool? _isCreator = false;

  @override
  void initState() {
    // var isPrepared = Get.isPrepared<T>(tag: widget.tag);
    final isRegistered = Get.isRegistered<T>(tag: widget.tag);

    if (widget.global) {
      if (isRegistered) {
        _isCreator = Get.isPrepared<T>(tag: widget.tag);
        controller = Get.find<T>(tag: widget.tag);
      } else {
        controller = widget.init;
        _isCreator = true;
        Get.put<T>(controller!, tag: widget.tag);
      }
    } else {
      controller = widget.init;
      _isCreator = true;
      controller?.onStart();
    }
    widget.initState?.call(this);
    if (widget.global && Get.smartManagement == SmartManagement.onlyBuilder) {
      controller?.onStart();
    }

    _subscribeToController();

    super.initState();
  }

  Disposer? _removeListener;

  /// GetX 的刷新来源有两个：builder 里读到的 Rx，以及 controller.update()。
  /// 少了这一条，只读普通字段的 GetX<T> 就永远不会重建。
  void _subscribeToController() {
    final localController = controller;
    if (localController is GetxController) {
      _removeListener?.call();
      _removeListener = localController.addListener(_update);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (widget.didChangeDependencies != null) {
      widget.didChangeDependencies!(this);
    }
  }

  @override
  void didUpdateWidget(GetX oldWidget) {
    super.didUpdateWidget(oldWidget as GetX<T>);
    widget.didUpdateWidget?.call(oldWidget, this);
  }

  @override
  void dispose() {
    if (widget.dispose != null) widget.dispose!(this);
    _removeListener?.call();
    _removeListener = null;
    if (_isCreator! || widget.assignId) {
      if (widget.autoRemove && Get.isRegistered<T>(tag: widget.tag)) {
        Get.delete<T>(tag: widget.tag);
      }
    }

    for (final disposer in disposers) {
      disposer();
    }

    disposers.clear();

    controller = null;
    _isCreator = null;
    super.dispose();
  }

  void _update() {
    if (!mounted) return;
    // 与 StatelessBuilder / Obx 保持同一条刷新路径：延到微任务，既避开
    // build 期间的 setState，也让卸载后到达的通知不会打到 defunct element 上
    scheduleMicrotask(() {
      if (mounted) setState(() {});
    });
  }

  final disposers = <Disposer>[];

  @override
  Widget build(BuildContext context) => Notifier.instance.append(
      NotifyData(
        disposers: disposers,
        updater: _update,
        // GetX 的刷新本来就可以来自 controller.update()，不强制要求 builder 里
        // 读到 Rx。「必须读到 Rx，否则抛 ObxError」是 Obx 的约定，
        // 套到 GetX 上会让只读普通字段的 GetX<T> 直接报错。
        throwException: false,
      ),
      () => widget.builder(controller!));

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<T>('controller', controller));
  }
}
