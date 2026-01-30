import 'dart:convert';
import 'dart:io';

// Source: https://nigerianbanks.xyz
const String logoBaseUrl = 'https://nigerianbanks.xyz/logo/';

// Banks from user's API
const String apiData = '''
{"status":true,"data":[
{"name":"Access Bank","slug":"access_bank","code":"044","country":"NG"},
{"name":"ACCESS BANK PLC (DIAMOND)","slug":"access_bank_plc_(diamond)","code":"063","country":"NG"},
{"name":"Alpha Morgan Bank","slug":"alpha_morgan_bank","code":"000041","country":"NG"},
{"name":"ALTERNATIVE BANK","slug":"alternative_bank","code":"000037","country":"NG"},
{"name":"Citi Bank","slug":"citi_bank","code":"023","country":"NG"},
{"name":"Coronation Merchant Bank","slug":"coronation_merchant_bank","code":"559","country":"NG"},
{"name":"EcoBank","slug":"ecobank","code":"050","country":"NG"},
{"name":"Enterprise Bank","slug":"enterprise_bank","code":"084","country":"NG"},
{"name":"Fidelity Bank","slug":"fidelity_bank","code":"070","country":"NG"},
{"name":"First Bank of Nigeria","slug":"first_bank_of_nigeria","code":"011","country":"NG"},
{"name":"First City Monument Bank","slug":"first_city_monument_bank","code":"214","country":"NG"},
{"name":"FSDH Merchant Bank","slug":"fsdh_merchant_bank","code":"601","country":"NG"},
{"name":"GLOBUS Bank","slug":"globus_bank","code":"000027","country":"NG"},
{"name":"GTBank Plc","slug":"gtbank_plc","code":"058","country":"NG"},
{"name":"Heritage","slug":"heritage","code":"030","country":"NG"},
{"name":"JAIZ Bank","slug":"jaiz_bank","code":"301","country":"NG"},
{"name":"Keystone Bank","slug":"keystone_bank","code":"082","country":"NG"},
{"name":"Kuda Microfinance bank","slug":"kuda_microfinance_bank","code":"090267","country":"NG"},
{"name":"LOTUS BANK","slug":"lotus_bank","code":"000029","country":"NG"},
{"name":"Moniepoint Microfinance Bank","slug":"moniepoint_microfinance_bank","code":"090405","country":"NG"},
{"name":"Nova Merchant Bank","slug":"nova_merchant_bank","code":"637","country":"NG"},
{"name":"Opay Digital Services","slug":"opay_digital_services","code":"100004","country":"NG"},
{"name":"Optimus Bank","slug":"optimus_bank","code":"000036","country":"NG"},
{"name":"Paga","slug":"paga","code":"100002","country":"NG"},
{"name":"Palmpay","slug":"palmpay","code":"100033","country":"NG"},
{"name":"PARALLEX BANK","slug":"parallex_bank","code":"000030","country":"NG"},
{"name":"Polaris Bank","slug":"polaris_bank","code":"076","country":"NG"},
{"name":"Premium Trust Bank","slug":"premium_trust_bank","code":"000031","country":"NG"},
{"name":"Providus Bank","slug":"providus_bank","code":"101","country":"NG"},
{"name":"Signature Bank","slug":"signature_bank","code":"000034","country":"NG"},
{"name":"StanbicIBTC Bank","slug":"stanbicibtc_bank","code":"221","country":"NG"},
{"name":"StandardChartered","slug":"standardchartered","code":"000021","country":"NG"},
{"name":"Sterling Bank","slug":"sterling_bank","code":"232","country":"NG"},
{"name":"Suntrust Bank","slug":"suntrust_bank","code":"000022","country":"NG"},
{"name":"Taj Bank","slug":"taj_bank","code":"000026","country":"NG"},
{"name":"Titan Trust Bank","slug":"titan_trust_bank","code":"000025","country":"NG"},
{"name":"Union Bank","slug":"union_bank","code":"032","country":"NG"},
{"name":"United Bank for Africa","slug":"united_bank_for_africa","code":"033","country":"NG"},
{"name":"Unity Bank","slug":"unity_bank","code":"215","country":"NG"},
{"name":"VFD Microfinance Bank","slug":"vfd_microfinance_bank","code":"566","country":"NG"},
{"name":"Wema/ALAT","slug":"wema/alat","code":"035","country":"NG"},
{"name":"Zenith Bank","slug":"zenith_bank","code":"057","country":"NG"}
]}
''';

// Existing slugs in the package
const existingSlugs = {
  '9psb',
  'access-bank',
  'access-bank-diamond',
  'alat-by-wema',
  'asosavings',
  'cemcs-microfinance-bank',
  'citibank-nigeria',
  'ecobank-nigeria',
  'ekondo-microfinance-bank',
  'fidelity-bank',
  'first-bank-of-nigeria',
  'first-city-monument-bank',
  'globus-bank',
  'guaranty-trust-bank',
  'heritage-bank',
  'keystone-bank',
  'kuda-bank',
  'lotus-bank',
  'moniepoint-mfb-ng',
  'paga',
  'palmpay',
  'paycom',
  'polaris-bank',
  'sparkle-microfinance-bank',
  'stanbic-ibtc-bank',
  'standard-chartered-bank',
  'sterling-bank',
  'taj-bank',
  'union-bank-of-nigeria',
  'united-bank-for-africa',
  'wema-bank',
  'zenith-bank',
};

void main() async {
  final data = jsonDecode(apiData);
  final banks = data['data'] as List;

  print('=== Commercial Banks Analysis ===\n');
  print('Checking for missing banks with available logos...\n');

  final client = HttpClient();
  final missingWithLogos = <Map<String, dynamic>>[];

  for (final bank in banks) {
    final name = bank['name'] as String;
    final apiSlug = bank['slug'] as String;
    final code = bank['code'] as String;

    // Convert to package slug format (underscores to hyphens, lowercase)
    final packageSlug = apiSlug
        .replaceAll('_', '-')
        .replaceAll('/', '-')
        .toLowerCase();

    // Check if already exists
    if (existingSlugs.contains(packageSlug)) {
      continue;
    }

    // Check if logo exists
    final logoUrl = '$logoBaseUrl$packageSlug.png';
    try {
      final request = await client.headUrl(Uri.parse(logoUrl));
      final response = await request.close();

      if (response.statusCode == 200) {
        print('✅ FOUND: $name ($code) -> $packageSlug');
        missingWithLogos.add({
          'name': name,
          'slug': packageSlug,
          'code': code,
          'logoUrl': logoUrl,
        });
      } else {
        print('❌ NO LOGO: $name ($code)');
      }
    } catch (e) {
      print('❌ ERROR: $name - $e');
    }
  }

  client.close();

  print('\n=== Summary ===');
  print('Banks with logos that can be added: ${missingWithLogos.length}');

  if (missingWithLogos.isNotEmpty) {
    print('\n=== Banks to Add ===');
    for (final bank in missingWithLogos) {
      print(
        "Bank(name: '${bank['name']}', slug: '${bank['slug']}', code: '${bank['code']}', ussd: ''),",
      );
    }
  }
}
