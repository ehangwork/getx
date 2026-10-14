import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

class TestClass {
  final name = "John";
}

class EmptyClass {}

void main() {
  dynamic newId(dynamic e) => e;

  test('null isNullOrBlank should be true for null', () {
    expect(GetUtils.isNullOrBlank(null), true);
  });

  test('isNullOrBlank should be false for unsupported types', () {
    expect(GetUtils.isNullOrBlank(5), false);
    expect(GetUtils.isNullOrBlank(0), false);

    expect(GetUtils.isNullOrBlank(5.0), equals(false));
    expect(GetUtils.isNullOrBlank(0.0), equals(false));

    TestClass? testClass;
    expect(GetUtils.isNullOrBlank(testClass), equals(true));
    expect(GetUtils.isNullOrBlank(TestClass()), equals(false));
    expect(GetUtils.isNullOrBlank(EmptyClass()), equals(false));
  });

  test('isNullOrBlank should validate strings', () {
    expect(GetUtils.isNullOrBlank(""), true);
    expect(GetUtils.isNullOrBlank("  "), true);

    expect(GetUtils.isNullOrBlank("foo"), false);
    expect(GetUtils.isNullOrBlank(" foo "), false);

    expect(GetUtils.isNullOrBlank("null"), false);
  });

  test('isNullOrBlank should validate iterables', () {
    expect(GetUtils.isNullOrBlank([].map(newId)), true);
    expect(GetUtils.isNullOrBlank([1].map(newId)), false);
  });

  test('isNullOrBlank should validate lists', () {
    expect(GetUtils.isNullOrBlank(const []), true);
    expect(GetUtils.isNullOrBlank(['oi', 'foo']), false);
    expect(GetUtils.isNullOrBlank([{}, {}]), false);
    expect(GetUtils.isNullOrBlank(['foo'][0]), false);
  });

  test('isNullOrBlank should validate sets', () {
    expect(GetUtils.isNullOrBlank(<dynamic>{}), true);
    expect(GetUtils.isNullOrBlank({1}), false);
    expect(GetUtils.isNullOrBlank({'fluorine', 'chlorine', 'bromine'}), false);
  });

  test('isNullOrBlank should validate maps', () {
    expect(GetUtils.isNullOrBlank({}), true);
    expect(GetUtils.isNullOrBlank({1: 1}), false);
    expect(GetUtils.isNullOrBlank({"other": "thing"}), false);

    final map = {"foo": 'bar', "one": "um"};
    expect(GetUtils.isNullOrBlank(map["foo"]), false);
    expect(GetUtils.isNullOrBlank(map["other"]), true);
  });

  // 分隔符出现在首尾或连续出现时不该让转换崩溃
  group('GetUtils.camelCase', () {
    test('converts separators between words into camelCase', () {
      expect(GetUtils.camelCase('foo bar'), 'fooBar');
      expect(GetUtils.camelCase('foo_bar'), 'fooBar');
    });

    test('returns null for blank input', () {
      expect(GetUtils.camelCase(''), isNull);
      expect(GetUtils.camelCase('   '), isNull);
    });

    test('tolerates leading, trailing and repeated separators', () {
      expect(GetUtils.camelCase('-foo bar'), 'fooBar');
      expect(GetUtils.camelCase('foo bar-'), 'fooBar');
      expect(GetUtils.camelCase('foo---bar'), 'fooBar');
      expect(GetUtils.camelCase('_'), '');
    });
  });
}
