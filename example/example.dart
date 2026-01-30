// ignore_for_file: avoid_print

import 'package:nigerian_banks_nuban/nigerian_banks_nuban.dart';

void main() {
  // Initialize the NigerianBanks instance
  final nigerianBanks = NigerianBanks();

  // 1. Get all banks
  print('Total banks: ${nigerianBanks.banks.length}');

  // 2. Get bank by code
  final accessBank = nigerianBanks.getBankByCode('044');
  print('Bank with code 044: ${accessBank?.name}'); // Access Bank

  // 3. Get bank by slug
  final gtBank = nigerianBanks.getBankBySlug('guaranty-trust-bank');
  print('GTBank USSD: ${gtBank?.ussd}'); // *737#

  // 4. Find bank by name (fuzzy matching)
  final kuda = nigerianBanks.findBankByName('Kuda');
  print('Found bank: ${kuda?.name}'); // Kuda Bank

  // 5. Search banks
  final searchResults = nigerianBanks.searchBanks('first');
  print('Search results for "first": ${searchResults.length} banks');
  for (final bank in searchResults) {
    print('  - ${bank.name}');
  }

  // 6. Detect banks from NUBAN account number
  final accountNumber = '0123456789';
  final possibleBanks = nigerianBanks.getBanksByAccountNumber(accountNumber);
  print('\nPossible banks for account $accountNumber:');
  for (final bank in possibleBanks) {
    print('  - ${bank.name} (${bank.code})');
  }

  // 7. Normalize bank name for comparison
  final normalized = NigerianBanks.normalizeName('First Bank of Nigeria PLC');
  print('\nNormalized name: $normalized'); // firstnigeria
}
