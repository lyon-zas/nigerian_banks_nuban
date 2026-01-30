# Nigerian Banks NUBAN

A Flutter package that lists all Nigerian banks, their logos, and slugs, and provides functionality to detect probable banks from a NUBAN account number.

## Features

- **Get All Banks**: Retrieve a list of all commercial and microfinance banks in Nigeria.
- **Search by Slug/Code**: Find specific banks using their unique slug or CBN code.
- **NUBAN Lookup**: Detect probable banks for a given 10-digit account number using the NUBAN algorithm.
- **Fuzzy Matching**: Find banks by name with variations (e.g., "MONIE POINT" → "Moniepoint MFB").
- **Search**: Search banks by partial name, slug, or code.
- **BankLogo Widget**: Ready-to-use widget with fallback handling for missing logos.
- **Offline Assets**: All bank logos are bundled with the package.

## Installation

Add the dependency to your `pubspec.yaml`:

```yaml
dependencies:
  nigerian_banks_nuban: ^0.0.1
```

## Usage

### Import

```dart
import 'package:nigerian_banks_nuban/nigerian_banks_nuban.dart';
```

### Get All Banks

```dart
final nigerianBanks = NigerianBanks();
final banks = nigerianBanks.getBanks();

for (final bank in banks) {
  print('${bank.name} - ${bank.code}');
}
```

### Find Bank by Slug or Code

```dart
final bank = nigerianBanks.getBankBySlug('access-bank');
// or
final bank = nigerianBanks.getBankByCode('044');

if (bank != null) {
  print(bank.name);
  print(bank.logo); // Returns path to asset
}
```

### Detect Bank from Account Number (NUBAN)

Suggest probable banks for a user's account number.

```dart
final accountNum = '1234567890';
final probableBanks = nigerianBanks.getBanksByAccountNumber(accountNum);

if (probableBanks.isEmpty) {
  print('Invalid Account Number or No Matching Bank');
} else {
  for (final bank in probableBanks) {
    print('Detected: ${bank.name}');
  }
}
```

### Fuzzy Bank Matching

Find banks by name, handling variations like "MONIE POINT" vs "Moniepoint MFB":

```dart
final bank = nigerianBanks.findBankByName('MONIEPOINT');
// Returns Moniepoint MFB bank
```

### Search Banks

Search across names, slugs, and codes:

```dart
final results = nigerianBanks.searchBanks('access');
// Returns all banks containing "access"
```

### Normalized Name Comparison

Compare bank names from different sources:

```dart
final normalized = NigerianBanks.normalizeName('Access Bank PLC');
// Returns: "access"
```

### Display Bank Logo

Use the `BankLogo` widget with built-in error handling:

```dart
BankLogo(
  bank: bank,
  size: 48,
  borderRadius: 8,
  fallback: Icon(Icons.account_balance), // Optional custom fallback
)
```

## Note on OPay/PayCom

- **PayCom** (Code `100004`) and **OPay** (Code `999992`) both map to the slug `paycom`.
- **Lotus Bank**: Many OPay accounts are technically domiciled at Lotus Bank (Code `303`). If an "OPay" number is detected as Lotus Bank, this is correct behavior as per the NUBAN algorithm.

## Credits

Data and logos sourced from [ichtrojan/nigerian-banks](https://github.com/ichtrojan/nigerian-banks).
