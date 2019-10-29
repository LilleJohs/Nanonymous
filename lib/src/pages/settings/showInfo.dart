import 'package:Nanonymous/src/pages/settings/baseSettingsPage.dart';
import 'package:flutter/material.dart';

import '../../widgets/bigButton.dart';
import '../../helper/appConfig.dart';

class ShowInfoPage extends StatelessWidget with BaseSettingsPage {
  final double blockWidth = AppConfig.blockSizeWidth;
  final double blockHeight = AppConfig.blockSizeHeight;

  Widget body(BuildContext context) {
    return Stack(
      children: [
        Align(
          alignment: Alignment.topCenter,
          child: Container(
            height: blockHeight * 70,
            child: ListView(
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(0, 0, 0, blockHeight * 2),
                  child: Text(
                    'How Does This Wallet Work?',
                    style: TextStyle(fontSize: blockHeight * 4),
                    textAlign: TextAlign.center,
                  ),
                ),
                Text(
                  '''Most Nano wallets these days use only one single address which the users use for every transaction.
                  
                  \nThis is considered a bad practice in other cryptocurrencies such as Bitcoin since it makes it easy for people to see how much money you have and who you are sending them to and receiving from.
                  
                  \nNanonymous aims to show how one can take inspiration from modern Bitcoin wallets by using multiple addresses, and thus, make it harder for other people to track your money.
                  
                  \nThis wallet takes use of one single seed which can generate an almost infinite amount of private-public key pairs. By using an index starting at 0, we can create a new address by incrementing this index.

                  \nOn the main page of this wallet an address with the leading index is shown. This address will always have a zero balance and no blocks associated with it. When you send Nano to this address, the wallet will add that amount to the total balance, increment the index and show the new, corresponding address on the home page.

                  \nThus, the amount of Nano this wallet stores can be distributed amongst a big set of addresses. That means that if people send money to your wallet, they will not see how much Nano is in your wallet. Only the amount they sent since every address is ment to only receive one transaction.

                  \nWhen you wanna send Nano to one of your friends, the wallet will take the smallest index that has a non-zero balance and see if there is enough balance in that to send the money. If there is not, it looks at the next index, adds the balance in that address and see if that is enough Nano. It keeps incrementing the index until it has enough addresses with enough balance in total. Then it empties the accounts by making one send block per address. For the last address, it sends the required Nano left over to the receiver, and the rest is sent back to the user by looking at the next index address.

                  \nHere is an example: Index 0-4 has 5 Nano each which totals 25 Nano. You wanna send 12 Nano to your friend with address A. You first send all Nano in address with index 0 to A. Then all Nano in address with index 1 to A. That is a total of 10 Nano. Then you send 2 Nano from address with index 2 to A. Now your friend is happy since he has received all 12 Nano. You have 3 Nano left in address with index 2, and so that is sent to your next address in line which is index 3. So now address with index 3 has a total of 8 Nano.

                  \nThis makes it much harder for a third-party to track your Nano. You can also receive Nano from people without revealing how much Nano you have. Also, since Nano has no fees, making all these transactions do not hurt the user in any way. It requires more from the wallet creators since they have to produce more work, but the users benefit.
                  ''',
                  style: TextStyle(fontSize: blockHeight * 3),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: BigButton(
              text: 'Go Back', onPressed: () => Navigator.pop(context)),
        ),
      ],
    );
  }
}
