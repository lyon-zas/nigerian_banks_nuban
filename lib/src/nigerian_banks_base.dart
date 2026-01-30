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

  /// Normalizes a bank name by removing common suffixes, extra spaces, and converting to lowercase.
  /// Useful for comparing bank names from different sources.
  static String normalizeName(String name) {
    return name
        .toLowerCase()
        .replaceAll(RegExp(r'\s+'), ' ')
        .replaceAll(
          RegExp(r'\b(bank|mfb|microfinance|plc|limited|ltd|nigeria|ng)\b'),
          '',
        )
        .replaceAll(RegExp(r'[^a-z0-9]'), '')
        .trim();
  }

  /// Finds a bank by name using fuzzy matching.
  /// Handles variations like "MONIE POINT" vs "Moniepoint MFB".
  /// Returns the best match or null if no reasonable match is found.
  Bank? findBankByName(String name) {
    final normalizedInput = normalizeName(name);
    if (normalizedInput.isEmpty) return null;

    Bank? bestMatch;
    int bestScore = 0;

    for (final bank in banks) {
      final normalizedBankName = normalizeName(bank.name);

      // Exact match after normalization
      if (normalizedBankName == normalizedInput) {
        return bank;
      }

      // Check if one contains the other
      final score = _calculateMatchScore(normalizedInput, normalizedBankName);
      if (score > bestScore) {
        bestScore = score;
        bestMatch = bank;
      }
    }

    // Only return if we have a reasonable match (at least 50% similarity)
    return bestScore >= 50 ? bestMatch : null;
  }

  /// Calculates a match score between two normalized strings.
  int _calculateMatchScore(String input, String target) {
    if (input == target) return 100;
    if (target.contains(input) || input.contains(target)) {
      final shorter = input.length < target.length ? input : target;
      final longer = input.length >= target.length ? input : target;
      return (shorter.length / longer.length * 100).round();
    }

    // Simple character overlap scoring
    int matches = 0;
    for (int i = 0; i < input.length && i < target.length; i++) {
      if (input[i] == target[i]) matches++;
    }
    return (matches /
            (input.length > target.length ? input.length : target.length) *
            100)
        .round();
  }

  /// Searches banks by name, slug, or code.
  /// Returns a list of banks matching the query (case-insensitive).
  List<Bank> searchBanks(String query) {
    if (query.isEmpty) return [];

    final normalizedQuery = query.toLowerCase().trim();

    return banks.where((bank) {
      return bank.name.toLowerCase().contains(normalizedQuery) ||
          bank.slug.toLowerCase().contains(normalizedQuery) ||
          bank.code.toLowerCase().contains(normalizedQuery) ||
          normalizeName(bank.name).contains(normalizeName(query));
    }).toList();
  }
}
