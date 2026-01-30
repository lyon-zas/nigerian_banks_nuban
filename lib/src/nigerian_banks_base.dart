import 'models/bank.dart';
import 'data/banks_data.dart';

class NigerianBanks {
  /// Returns a list of all banks.
  List<Bank> getBanks() {
    return banks;
  }

  /// Returns a bank by its slug.
  Bank? getBankBySlug(String slug) {
    try {
      return banks.firstWhere((bank) => bank.slug == slug);
    } catch (e) {
      return null;
    }
  }

  /// Returns a bank by its code.
  Bank? getBankByCode(String code) {
    try {
      return banks.firstWhere((bank) => bank.code == code);
    } catch (e) {
      return null;
    }
  }

  /// Returns a list of banks that match the account number's check digit.
  /// This relies on the NUBAN algorithm.
  /// It supports banks with numeric codes (padded to 6 digits).
  List<Bank> getBanksByAccountNumber(String accountNumber) {
    if (accountNumber.length != 10) {
      return [];
    }

    return banks.where((bank) {
      // Skip banks with non-numeric codes (e.g. 035A)
      final isNumeric = RegExp(r'^[0-9]+$').hasMatch(bank.code);
      if (!isNumeric) {
        return false;
      }

      return _isNubanValid(bank.code, accountNumber);
    }).toList();
  }

  /// Validates if an account number is valid for a given bank code using NUBAN algorithm.
  /// Uses the 15-digit algorithm (6-digit bank code + 9-digit serial).
  bool _isNubanValid(String bankCode, String accountNumber) {
    if (accountNumber.length != 10) {
      return false;
    }

    final String serialNumber = accountNumber.substring(0, 9);
    final int checkDigit = int.parse(accountNumber.substring(9));

    // Pad bank code to 6 digits
    final String paddedBankCode = bankCode.padLeft(6, '0');
    final String verificationString = paddedBankCode + serialNumber;

    // Weights for 15-digit string
    const List<int> weights = [3, 7, 3, 3, 7, 3, 3, 7, 3, 3, 7, 3, 3, 7, 3];
    int sum = 0;

    for (int i = 0; i < verificationString.length; i++) {
      final int digit = int.parse(verificationString[i]);
      sum += digit * weights[i];
    }

    int calculatedCheckDigit = 10 - (sum % 10);
    if (calculatedCheckDigit == 10) {
      calculatedCheckDigit = 0;
    }

    return calculatedCheckDigit == checkDigit;
  }
}
