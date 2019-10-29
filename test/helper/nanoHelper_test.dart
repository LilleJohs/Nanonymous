import 'package:Nanonymous/src/helper/nanoHelper.dart';
import 'package:test_api/test_api.dart';

void main() {
  test('Test NanoToRaw function', () async {
    BigInt balance = BigInt.parse('2803367890000000016777215998');
    String balanceString = '0.002803367890000000016777215998';

    expect(balance, NanoHelper.nanoToRaw(balanceString));
  });

  test('Test NanoToRaw function', () async {
    BigInt balance = BigInt.parse('2803367890000000016777215998');
    String balanceString = '0.002803';

    expect(balanceString, NanoHelper.rawToNano(balance));
  });
}
