/// Returns whether a dynamic value PROBABLY
/// has the isEmpty getter/method by checking
/// standard dart types that contains it.
///
/// This is here to for the 'DRY'
bool? _isEmpty(dynamic value) {
  if (value is String) {
    return value.toString().trim().isEmpty;
  }
  if (value is Iterable || value is Map) {
    return value.isEmpty as bool?;
  }
  return false;
}

class GetUtils {
  GetUtils._();

  /// Checks if data is null.
  static bool isNull(dynamic value) => value == null;

  /// Checks if data is null or blank (empty or only contains whitespace).
  static bool? isNullOrBlank(dynamic value) {
    if (isNull(value)) {
      return true;
    }

    // Pretty sure that isNullOrBlank should't be validating
    // iterables... but I'm going to keep this for compatibility.
    return _isEmpty(value);
  }

  /// Checks if data is null or blank (empty or only contains whitespace).
  static bool? isBlank(dynamic value) {
    return _isEmpty(value);
  }

  /// Checks if string is int or double.
  static bool isNum(String value) {
    if (isNull(value)) {
      return false;
    }

    return num.tryParse(value) is num;
  }

  /// Checks if string consist only numeric.
  /// Numeric only doesn't accepting "." which double data type have
  static bool isNumericOnly(String s) => hasMatch(s, r'^\d+$');

  /// Checks if string consist only Alphabet. (No Whitespace)
  static bool isAlphabetOnly(String s) => hasMatch(s, r'^[a-zA-Z]+$');

  /// Checks if string is boolean.
  static bool isBool(String value) {
    if (isNull(value)) {
      return false;
    }

    return (value == 'true' || value == 'false');
  }

  /// Checks if string is URL.
  static bool isURL(String s) => hasMatch(s,
      r"^((((H|h)(T|t)|(F|f))(T|t)(P|p)((S|s)?))\://)?(www.|[a-zA-Z0-9].)[a-zA-Z0-9\-\.]+\.[a-zA-Z]{2,7}(\:[0-9]{1,5})*(/($|[a-zA-Z0-9\.\,\;\?\'\\\+&amp;%\$#\=~_\-]+))*$");

  /// Checks if string is email.
  static bool isEmail(String s) => hasMatch(s,
      r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$');

  /// Checks if string is phone number.
  static bool isPhoneNumber(String s) {
    if (s.length > 16 || s.length < 9) return false;
    return hasMatch(s, r'^[+]*[(]{0,1}[0-9]{1,4}[)]{0,1}[-\s\./0-9]*$');
  }

  /// Checks if num a LOWER than num b.
  static bool isLowerThan(num a, num b) => a < b;

  /// Checks if num a GREATER than num b.
  static bool isGreaterThan(num a, num b) => a > b;

  /// Checks if num a EQUAL than num b.
  static bool isEqual(num a, num b) => a == b;

  /// Capitalize each word inside string
  /// Example: your name => Your Name, your name => Your name
  static String capitalize(String value) {
    if (isBlank(value)!) return value;
    return value.split(' ').map(capitalizeFirst).join(' ');
  }

  /// Uppercase first letter inside string and let the others lowercase
  /// Example: your name => Your name
  static String capitalizeFirst(String s) {
    if (isBlank(s)!) return s;
    return s[0].toUpperCase() + s.substring(1).toLowerCase();
  }

  /// Remove all whitespace inside string
  /// Example: your name => yourname
  static String removeAllWhitespace(String value) {
    return value.replaceAll(' ', '');
  }

  /// camelCase string
  /// Example: your name => yourName
  static String? camelCase(String value) {
    if (isNullOrBlank(value)!) {
      return null;
    }

    // 首尾或连续的分隔符不代表任何单词，剔除后再取首字符
    final separatedWords = value
        .split(RegExp(r'[!@#<>?":`~;[\]\\|=+)(*&^%-\s_]+'))
        .where((word) => word.isNotEmpty);
    var newString = '';

    for (final word in separatedWords) {
      newString += word[0].toUpperCase() + word.substring(1).toLowerCase();
    }

    if (newString.isEmpty) {
      return '';
    }

    return newString[0].toLowerCase() + newString.substring(1);
  }

  /// Extract numeric value of string
  /// Example: OTP 12312 27/04/2020 => 1231227042020ß
  /// If firstWordOnly is true, then the example return is "12312"
  /// (first found numeric word)
  static String numericOnly(String s, {bool firstWordOnly = false}) {
    var numericOnlyStr = '';

    for (var i = 0; i < s.length; i++) {
      if (isNumericOnly(s[i])) {
        numericOnlyStr += s[i];
      }
      if (firstWordOnly && numericOnlyStr.isNotEmpty && s[i] == " ") {
        break;
      }
    }

    return numericOnlyStr;
  }

  /// Capitalize only the first letter of each word in a string
  /// Example: getx will make it easy  => Getx Will Make It Easy
  /// Example 2 : this is an example text => This Is An Example Text
  static String capitalizeAllWordsFirstLetter(String s) {
    String lowerCasedString = s.toLowerCase();
    String stringWithoutExtraSpaces = lowerCasedString.trim();

    if (stringWithoutExtraSpaces.isEmpty) {
      return "";
    }
    if (stringWithoutExtraSpaces.length == 1) {
      return stringWithoutExtraSpaces.toUpperCase();
    }

    List<String> stringWordsList = stringWithoutExtraSpaces.split(" ");
    List<String> capitalizedWordsFirstLetter = stringWordsList
        .map(
          (word) {
            if (word.trim().isEmpty) return "";
            return word.trim();
          },
        )
        .where(
          (word) => word != "",
        )
        .map(
          (word) {
            if (word.startsWith(RegExp(r'[\n\t\r]'))) {
              return word;
            }
            return word[0].toUpperCase() + word.substring(1).toLowerCase();
          },
        )
        .toList();
    String finalResult = capitalizedWordsFirstLetter.join(" ");
    return finalResult;
  }

  static bool hasMatch(String? value, String pattern) {
    return (value == null) ? false : RegExp(pattern).hasMatch(value);
  }

  static String createPath(String path, [Iterable? segments]) {
    if (segments == null || segments.isEmpty) {
      return path;
    }
    final list = segments.map((e) => '/$e');
    return path + list.join();
  }
}
