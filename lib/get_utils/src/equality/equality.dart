library;

import 'package:collection/collection.dart';

/// 值对象的相等性基类：子类只需提供 [props]，由这里统一实现 `==` / `hashCode`。
///
/// 深比较委托给 `package:collection`，该库不再随本包对外导出，
/// 避免与业务代码同时 import `package:collection` 时产生同名符号歧义。
mixin Equality {
  List get props;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        runtimeType == other.runtimeType &&
            other is Equality &&
            const DeepCollectionEquality().equals(props, other.props);
  }

  @override
  int get hashCode {
    return runtimeType.hashCode ^ const DeepCollectionEquality().hash(props);
  }
}