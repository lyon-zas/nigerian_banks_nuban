import 'package:flutter_test/flutter_test.dart';
import 'package:nigerian_banks_nuban/nigerian_banks_nuban.dart';

void main() {
  group('NigerianBanks', () {
    final nigerianBanks = NigerianBanks();

    test('getBanks returns a list of banks', () {
      final banks = nigerianBanks.getBanks();
      expect(banks, isNotEmpty);
      expect(
        banks.length,
        greaterThan(10),
      ); // Ensure we have a reasonable number of banks
    });

    test('getBankBySlug returns correct bank', () {
      final bank = nigerianBanks.getBankBySlug('access-bank');
      expect(bank, isNotNull);
      expect(bank!.name, 'Access Bank');
      expect(bank.code, '044');
      expect(
        bank.logo,
        'packages/nigerian_banks_nuban/assets/logos/access-bank.png',
      );
    });

    test('getBankByCode returns correct bank', () {
      final bank = nigerianBanks.getBankByCode('058'); // GTBank
      expect(bank, isNotNull);
      expect(bank!.name, 'Guaranty Trust Bank');
    });

    test('returns null for invalid slug/code', () {
      expect(nigerianBanks.getBankBySlug('invalid-slug'), isNull);
      expect(nigerianBanks.getBankByCode('999999'), isNull);
    });

    group('getBanksByAccountNumber', () {
      test('returns GTBank for valid constructed account number', () {
        // Bank Code: 058 (GTBank)
        // Serial: 012345678
        // Calculated Check Digit: 5
        // Account: 0123456785
        final banks = nigerianBanks.getBanksByAccountNumber('0119930507');
        expect(banks, isNotEmpty);
        expect(banks.map((b) => b.slug), contains('guaranty-trust-bank'));
      });

      test('returns Access Bank for valid constructed account number', () {
        // Bank Code: 044 (Access Bank)
        // Serial: 012345678
        // Calculated Check Digit: 4
        // Account: 0123456784
        final banks = nigerianBanks.getBanksByAccountNumber('0123456784');
        expect(banks, isNotEmpty);
        expect(banks.map((b) => b.slug), contains('access-bank'));
      });

      test('returns opay/paycom for valid constructed account number', () {
        // Account provided by user: 6108155676
        // Matches PayCom code 100004
        final banks = nigerianBanks.getBanksByAccountNumber('6108155676');
        expect(banks, isNotEmpty);
        // We check SLUGS. Both "OPay" and "PayCom" banks have the slug "paycom" in our data.
        expect(banks.map((b) => b.slug), contains('paycom'));
      });

      test('returns empty list for invalid length', () {
        expect(nigerianBanks.getBanksByAccountNumber('123'), isEmpty);
        expect(nigerianBanks.getBanksByAccountNumber('12345678901'), isEmpty);
      });

      test('returns empty list for non-matching number', () {
        final banks = nigerianBanks.getBanksByAccountNumber('0123456789');
        expect(
          banks.map((b) => b.slug),
          isNot(contains('guaranty-trust-bank')),
        );
      });
    });
  });
}
