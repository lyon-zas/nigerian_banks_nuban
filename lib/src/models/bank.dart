class Bank {
  final String name;
  final String slug;
  final String code;
  final String ussd;

  const Bank({
    required this.name,
    required this.slug,
    required this.code,
    required this.ussd,
  });

  /// Returns the path to the bank's logo asset.
  String get logo {
    return 'packages/nigerian_banks_nuban/assets/logos/$slug.png';
  }

  @override
  String toString() {
    return 'Bank(name: $name, slug: $slug, code: $code, ussd: $ussd)';
  }
}
