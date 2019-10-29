import 'package:Nanonymous/src/models/account.dart';
import 'package:Nanonymous/src/models/accountList.dart';
//import 'package:Nanonymous/src/helper/nanoHelper.dart';
import 'package:test_api/test_api.dart';

import 'package:flutter/services.dart';

void main() {
  test(
    'Test makeSendTransaction',
    () async {
      MethodChannel channel =
          const MethodChannel('plugins.it_nomads.com/flutter_secure_storage');

      //final _storage = FlutterSecureStorage();
      //final String seed = await _storage.read(key: seedKey);

      channel.setMockMethodCallHandler((MethodCall read) async {
        // Dummy seed
        return '5E4CB6605B264F9DE8E5B18247B90CCEC5790AA3247BDADC5F6C5C29FAF209D9';
      });

      final String sendToAccount =
          'nano_1anrzcuwe64rwxzcco8dkhpyxpi8kd7zsjc1oeimpc3ppca4mrjtwnqposrs';

      Map<int, Account> accounts = {
        0: Account(
          index: 0,
          address:
              'nano_1py139c3wjgdu4yumqpif11ew4aeiojfoacaa6ahkp4hpqowmkxtdg33tuh3',
          frontier:
              '62DE83A3DDA53BEF1A176F8907B7B8EDEFCD66E7C04DB46B451DF55C4B5999CA',
          rawBalance: '1000000000000000000000000000',
          representative:
              'nano_3hjo1cehsxrssawmpew98u4ug8bxy4ppht5ch647zpuscdgedfy1xh4yga7z',
        ),
        1: Account(
          index: 1,
          address:
              'nano_1gardcczygwusc5mxi39eu8858t94fux1ch35qa1ibeoazas6ifzdwg1zb5k',
          frontier:
              '9829C8E3AFA9E3475A7C9B2592269909D7DE4EA609CA6358CA8EFDA6441AA872',
          rawBalance: '2000000000000000000000000000',
          representative:
              'nano_1eeiwmnsq6fdhy1m35og1dzt7kdnci8wny3kn771638dfrrgg49so7k1mg7i',
        ),
        2: Account(
          index: 2,
          address:
              'nano_31qot8876hfejck9ht419y97mhm8bhfuxrbessde94nr33qr1o67fbhcp9ky',
          frontier: '',
          rawBalance: '0',
          representative:
              'nano_3uaydiszyup5zwdt93dahp7mri1cwa5ncg9t4657yyn3o4i1pe8sfjbimbas',
        ),
      };
      AccountList accountList = AccountList.setAccounts(accounts);
      Map<String, dynamic> blocks = await accountList.makeSendTransaction(
          sendToAccount: sendToAccount,
          sendNano: '0.0015',
          minimumIndex: 0,
          receiveIndex: 2);
      List<Map<String, String>> firstBlocks = blocks['allFirstBlocks'];
      Map<String, String> lastFirstBlock = blocks['lastFirstBlock'];
      Map<String, String> lastSecondBlock = blocks['lastSecondBlock'];

      // print(firstBlocks);
      // print(lastFirstBlock);
      // print(lastSecondBlock);
      assert(firstBlocks.length == 2);
      assert(lastFirstBlock != null && lastSecondBlock != null);
      assert(lastFirstBlock['subtype'] == 'send');
      assert(lastSecondBlock['subtype'] == 'receive');
      assert(firstBlocks[0]['balance'] == '0');
      assert(lastFirstBlock['balance'] == '0');
      // We try the two possible send scenarios
      if (lastFirstBlock['link'] == accounts[2].address) {
        print('Sent to receiver first');
        assert(lastSecondBlock['link'] == lastFirstBlock['hash'],
            'Receive block has to link to hash of lastFirstBlock');
      } else if (lastFirstBlock['link'] == sendToAccount) {
        print('Sent to ourself first');
        assert(lastFirstBlock['previous'] == firstBlocks[1]['hash']);
      } else {
        // If the reciving address is neither of the two above, return error.
        assert(false,
            'Neither of the two possible addresses is the link in the lastFirstBlock');
      }
    },
  );
}
