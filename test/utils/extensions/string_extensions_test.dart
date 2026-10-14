import 'package:flutter_test/flutter_test.dart';
import 'package:get/utils.dart';

void main() {
  group('String extensions', () {
    const text = "oi";
    const digit = "5";
    const specialCaracters = "#\$!%@";
    const alphaNumeric = "123asd";
    const numbers = "123";
    const letters = "foo";

    test('var.isNum', () {
      expect(digit.isNum, true);
      expect(text.isNum, false);
    });

    test('var.capitalizeAllWordsFirstLetter()', () {
      final List<String> sentences = [
        "getx",
        "this is an example sentence",
        "this is an example sentence with a number 5",
        "this is an example sentence with a number 5 and a special character #",
        "this is an example sentence with a number 5 and a special character # and b letter C",
        "    emm, lemme        think !",
        "Bro, $letters is a good word",
        "THIS IS A SENTENCE WITH ALL CAPITAL LETTERS",
        ""
      ];
      expect(text.capitalizeAllWordsFirstLetter(), "Oi");
      expect(digit.capitalizeAllWordsFirstLetter(), "5");
      expect(specialCaracters.capitalizeAllWordsFirstLetter(), "#\$!%@");
      expect(alphaNumeric.capitalizeAllWordsFirstLetter(), "123asd");
      expect(numbers.capitalizeAllWordsFirstLetter(), "123");
      expect(letters.capitalizeAllWordsFirstLetter(), "Foo");
      expect(sentences[0].capitalizeAllWordsFirstLetter(), "Getx");
      expect(sentences[1].capitalizeAllWordsFirstLetter(),
          "This Is An Example Sentence");
      expect(sentences[2].capitalizeAllWordsFirstLetter(),
          "This Is An Example Sentence With A Number 5");
      expect(sentences[3].capitalizeAllWordsFirstLetter(),
          "This Is An Example Sentence With A Number 5 And A Special Character #");
      expect(sentences[4].capitalizeAllWordsFirstLetter(),
          "This Is An Example Sentence With A Number 5 And A Special Character # And B Letter C");
      expect(
          sentences[5].capitalizeAllWordsFirstLetter(), "Emm, Lemme Think !");
      expect(sentences[6].capitalizeAllWordsFirstLetter(),
          "Bro, Foo Is A Good Word");
      expect(sentences[7].capitalizeAllWordsFirstLetter(),
          "This Is A Sentence With All Capital Letters");
      expect(sentences[8].capitalizeAllWordsFirstLetter(), "");
    });

    test('var.isNumericOnly', () {
      expect(numbers.isNumericOnly, true);
      expect(letters.isNumericOnly, false);
      expect(specialCaracters.isNumericOnly, false);
      expect(alphaNumeric.isNumericOnly, false);
    });

    test('var.isAlphabetOnly', () {
      expect(alphaNumeric.isAlphabetOnly, false);
      expect(numbers.isAlphabetOnly, false);
      expect(letters.isAlphabetOnly, true);
    });

    test('var.isBool', () {
      const trueString = 'true';
      // expect(notInitializedVar.isBool, false);
      expect(letters.isBool, false);
      expect(trueString.isBool, true);
    });

    test('var.isURL', () {
      // Url's generated in https://www.randomlists.com/urls
      final urls = [
        'http://www.example.com/aunt/babies.aspx#act',
        'http://adjustment.example.com/bedroom/animal.htm',
        'http://blade.example.com/arch/basketball',
        'https://www.example.com/air/advice.php',
        'http://www.example.com/balance/arch.html?blow=aftermath&bait=bath',
        'http://authority.example.com/',
        'http://example.com/advice.html',
        'https://www.example.com/',
        'https://www.example.com/bee?act=art&bells=board',
        'http://example.org/',
        'https://www.example.com/',
        'https://example.com/bed',
        'https://www.example.edu/acoustics',
        'https://www.example.com/bells',
        'http://board.example.com/',
        'http://book.example.com/afterthought?advertisement=ball&birth=argument',
        'http://birds.example.org/ball.aspx?apparatus=border&brother=aftermath',
        'https://www.example.org/books/book?bedroom=birds',
        'http://advice.example.com/',
        'http://example.com/',
        'http://example.com/bedroom/alarm',
        'https://example.com/advice/approval',
        'http://anger.example.net/?breath=brother&air=bell#ball',
        'http://appliance.example.com/bee/badge',
        'http://www.example.org/berry.aspx',
        'http://example.org/',
        'http://birds.example/',
      ];

      for (final url in urls) {
        expect(url.isURL, true);
      }
      expect(alphaNumeric.isURL, false);
    });
    test('var.isEmail', () {
      final emails = [
        'hellfire@comcast.net',
        'hllam@icloud.com',
        'tskirvin@live.com',
        'choset@comcast.net',
        'parksh@live.com',
        'kassiesa@yahoo.com',
        'kramulous@comcast.net',
        'froodian@me.com',
        'shawnce@yahoo.ca',
        'cgreuter@gmail.com',
        'aprakash@verizon.net',
        'dhrakar@gmail.com',
        'wmszeliga@yahoo.ca',
        'bmorrow@icloud.com',
        'seurat@comcast.net',
        'dialworld@yahoo.ca',
        'johndo@yahoo.ca',
        'empathy@yahoo.com.pt',
        'openldap@verizon.net',
        'elflord@outlook.com',
        'kaiser@me.com',
        'carcus@att.net',
        'garland@hotmail.com',
        'clkao@yahoo.ca',
        'daveed@mac.com',
        'parasite@icloud.com',
        'drolsky@aol.com',
        'reziac@outlook.com',
        'storerm@yahoo.ca',
        'johnbob@hotmail.com.br',
      ];

      for (final email in emails) {
        expect(email.isEmail, true);
      }
      expect(alphaNumeric.isEmail, false);
    });
    test('var.isPhoneNumber', () {
      final phoneNumbers = [
        '+1202-555-0145',
        '+1202-555-0139',
        '+1202-555-0101',
        '+1202-555-0136',
        '+1202-555-0190',
        '+1202-555-0156',
        '(738) 952-5253',
        '(861) 965-1597',
        '(732) 372-9760',
        '(532) 766-4719',
        '(987) 472-7813',
        '(455) 443-8171',
        '(915) 685-8658',
        '(572) 207-1898',
        '(81) 6 2499-9538',
        '(31) 32304-4263',
        '(64) 25242-6375',
        '(41) 19308-7925',
        '(67) 61684-0395',
        '(60) 54706-3569',
        '(31) 33110055',
        '(11) 3344-5599',
        '(31) 977447788',
        '(31) 66557744',
        '(21) 946576541',
        '(11) 3432-3333',
        '02131973585858'
      ];

      for (final phone in phoneNumbers) {
        // print('testing $phone');
        expect(phone.isPhoneNumber, true);
      }

      const bigRandomNumber = '168468468465241327987624987327987';
      expect(bigRandomNumber.isPhoneNumber, false);

      expect(alphaNumeric.isPhoneNumber, false);
    });
    test('var.capitalize', () {
      expect('foo bar'.capitalize, 'Foo Bar');
      expect('FoO bAr'.capitalize, 'Foo Bar');
      expect('FOO BAR'.capitalize, 'Foo Bar');
      // expect(null.capitalize, null);
      expect(''.capitalize, '');
      expect('foo  bar '.capitalize, 'Foo  Bar ');
    });

    test('var.capitalizeFirst', () {
      expect('foo bar'.capitalizeFirst, 'Foo bar');
      expect('FoO bAr'.capitalizeFirst, 'Foo bar');
      expect('FOO BAR'.capitalizeFirst, 'Foo bar');
      expect(''.capitalizeFirst, '');
    });

    test('var.removeAllWhitespace', () {
      //late String nullString;
      expect('foo bar'.removeAllWhitespace, 'foobar');
      expect('foo'.removeAllWhitespace, 'foo');
      expect(''.removeAllWhitespace, '');
      // expect(nullString.removeAllWhitespace, null);
    });

    test('var.camelCase', () {
      expect('foo bar'.camelCase, 'fooBar');
      expect('the fox jumped in the water'.camelCase, 'theFoxJumpedInTheWater');
      expect('foo_bar'.camelCase, 'fooBar');
      expect(''.camelCase, null);
    });

    // 首尾或连续的分隔符不该让转换崩溃，也不该凭空多出一个单词
    test('var.camelCase tolerates leading, trailing and repeated separators',
        () {
      expect('-foo bar'.camelCase, 'fooBar');
      expect('foo bar-'.camelCase, 'fooBar');
      expect('foo---bar'.camelCase, 'fooBar');
      expect('_'.camelCase, '');
    });

    test('var.numericOnly()', () {
      expect('date: 2020/09/13, time: 00:00'.numericOnly(), '202009130000');
      expect(
        'and 1, and 2, and 1 2 3'.numericOnly(),
        '12123',
      );
      expect(''.numericOnly(), '');
    });
  });
}
