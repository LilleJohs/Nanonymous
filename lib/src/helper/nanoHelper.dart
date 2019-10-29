import 'package:decimal/decimal.dart';

import 'package:nanodart/nanodart.dart';

import './storage.dart';

class NanoHelper {
  static String rawToNano(BigInt raw) {
    // Only for printing on screen
    // Only show less than you actually have by finding floor to nearest 0.000001
    final double nano = (raw / BigInt.from(1e24)).floor() / 1e6;
    if (nano == 0) {
      return '0';
    }
    return nano.toString();
  }

  static BigInt nanoToRaw(String nano) {
    final Decimal decimalNano = Decimal.parse(nano) * Decimal.parse('1e30');
    return BigInt.parse(decimalNano.toString());
  }

  static Future<Map<String, String>> getHashAndSignature(
      {int index,
      String account,
      String previous,
      String representative,
      BigInt newBalance,
      String link}) async {
    final tick = DateTime.now().millisecondsSinceEpoch;
    final String hash = NanoBlocks.computeStateHash(
      NanoAccountType.NANO,
      account,
      previous,
      representative,
      newBalance,
      link,
    );
    final tock = DateTime.now().millisecondsSinceEpoch;
    print('Time to get hash for one block: ${(tock - tick) / 1000} second');
    final String seed = await getSeed();

    final tick0 = DateTime.now().millisecondsSinceEpoch;
    final String privateKey = NanoKeys.seedToPrivate(seed, index);
    final tock0 = DateTime.now().millisecondsSinceEpoch;
    print('Time to get privatekey: ${(tock0 - tick0) / 1000} second');

    final tick1 = DateTime.now().millisecondsSinceEpoch;
    final String signature = NanoSignatures.signBlock(hash, privateKey);
    final tock1 = DateTime.now().millisecondsSinceEpoch;
    print(
        'Time to get signature for one block: ${(tock1 - tick1) / 1000} second');
    return {
      'hash': hash,
      'signature': signature,
    };
  }
}
