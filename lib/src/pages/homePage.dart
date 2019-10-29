import 'package:flutter/material.dart';

import '../widgets/transactionList.dart';
import '../bloc/wallet.dart';
import '../helper/nanoHelper.dart';
import '../helper/appConfig.dart';

class HomePage extends StatefulWidget {
  final Wallet wallet;
  HomePage({this.wallet});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final double blockWidth = AppConfig.blockSizeWidth;
  final double blockHeight = AppConfig.blockSizeHeight;

  Widget build(BuildContext context) {
    final wallet = widget.wallet;

    return StreamBuilder(
      stream: wallet.balanceStream,
      builder: (context, AsyncSnapshot snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Column(
              children: [
                Text(snapshot.error.toString()),
                CircularProgressIndicator(),
              ],
            ),
          );
        }
        if (!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }

        return Column(
          children: <Widget>[
            Container(height: blockHeight * 3),
            Container(
              height: blockHeight * 15,
              child: Center(
                child: Text('${NanoHelper.rawToNano(snapshot.data)} Nano',
                    style: TextStyle(
                        color: Colors.white, fontSize: blockHeight * 5)),
              ),
            ),
            Container(height: blockHeight * 2.5),
            Center(
              child: Text('History',
                  style: TextStyle(
                      color: Colors.white, fontSize: blockHeight * 5)),
            ),
            Container(height: blockHeight * 5),
            Expanded(
              child: ShowTransactions(wallet: wallet),
            ),
          ],
        );
      },
    );
  }
}
