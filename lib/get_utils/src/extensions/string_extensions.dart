import '../get_utils/get_utils.dart';

extension GetStringUtils on String {
  /// Discover if the String is a valid number
  bool get isNum => GetUtils.isNum(this);

  /// Discover if the String is numeric only
  bool get isNumericOnly => GetUtils.isNumericOnly(this);

  String numericOnly({bool firstWordOnly = false}) =>
      GetUtils.numericOnly(this, firstWordOnly: firstWordOnly);

  /// Discover if the String is alphanumeric only
  bool get isAlphabetOnly => GetUtils.isAlphabetOnly(this);

  /// Discover if the String is a boolean
  bool get isBool => GetUtils.isBool(this);

  /// Discover if the String is a valid URL
  bool get isURL => GetUtils.isURL(this);

  /// Discover if the String is a Email
  bool get isEmail => GetUtils.isEmail(this);

  /// Discover if the String is a Phone Number
  bool get isPhoneNumber => GetUtils.isPhoneNumber(this);

  /// capitalize the String
  String get capitalize => GetUtils.capitalize(this);

  /// Capitalize the first letter of the String
  String get capitalizeFirst => GetUtils.capitalizeFirst(this);

  /// remove all whitespace from the String
  String get removeAllWhitespace => GetUtils.removeAllWhitespace(this);

  /// converter the String
  String? get camelCase => GetUtils.camelCase(this);

  /// add segments to the String
  String createPath([Iterable? segments]) {
    final path = startsWith('/') ? this : '/$this';
    return GetUtils.createPath(path, segments);
  }

  /// capitalize only first letter in String words to upper case
  String capitalizeAllWordsFirstLetter() =>
      GetUtils.capitalizeAllWordsFirstLetter(this);
}
