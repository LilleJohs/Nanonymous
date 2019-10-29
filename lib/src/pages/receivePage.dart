import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:qr_flutter/qr_flutter.dart';

import '../bloc/wallet.dart';
import '../widgets/textWithBackground.dart';
import '../widgets/bigContainer.dart';
import '../widgets/bigButton.dart';
import '../helper/appConfig.dart';

class ReceivePage extends StatefulWidget {
  final Wallet wallet;

  ReceivePage({this.wallet});

  @override
  _ReceivePageState createState() => _ReceivePageState();
}

class _ReceivePageState extends State<ReceivePage> {
  final double blockWidth = AppConfig.blockSizeWidth;
  final double blockHeight = AppConfig.blockSizeHeight;

  Widget build(BuildContext context) {
    final wallet = widget.wallet;
    final scaffold = Scaffold.of(context, nullOk: true);

    return Center(
      child: StreamBuilder(
        stream: wallet.receiveAccountStream,
        builder: (context, AsyncSnapshot<String> snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          final account = snapshot.data;
          return BigContainer(
            height: 80,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Always use the address shown on this page. It will update itself everytime you receive a new transaction.',
                  style: TextStyle(fontSize: blockHeight * 3),
                  textAlign: TextAlign.center,
                ),
                QrImage(
                  data: account,
                  size: blockHeight * 28,
                ),
                TextWithBackground(
                  text:
                      '${account.substring(0, 21)}\n${account.substring(22, 43)}\n${account.substring(44, 65)}',
                  width: 70,
                  fontMultiplier: 5,
                ),
                Container(height: blockHeight * 5),
                BigButton(
                  text: 'Copy',
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: account));
                    if (scaffold != null) {
                      scaffold.showSnackBar(SnackBar(
                        duration: Duration(seconds: 2),
                        content: Text("Address Copied to Clipboard"),
                      ));
                    }
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
