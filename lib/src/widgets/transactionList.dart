import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../widgets/refresh.dart';
import '../bloc/wallet.dart';
import '../helper/nanoHelper.dart';
import '../helper/appConfig.dart';

class ShowTransactions extends StatelessWidget {
  final double blockWidth = AppConfig.blockSizeWidth;
  final double blockHeight = AppConfig.blockSizeHeight;

  final Wallet wallet;
  final DateFormat formatter = new DateFormat('yMMMMd');

  ShowTransactions({this.wallet});

  Widget build(BuildContext context) {
    return Refresh(
      wallet: wallet,
      child: StreamBuilder(
        stream: wallet.transactionsStream,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Text('');
          }

          if (snapshot.data.length == 0) {
            return ListView(
              children: [
                Container(
                  height: blockHeight * 50,
                  child: Center(
                    child: Text(
                      'This wallet has no transactions yet',
                      style: TextStyle(color: Colors.white, fontSize: 30),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            );
          }

          return ListView.builder(
            padding: EdgeInsets.only(top: 0.0),
            itemCount: snapshot.data.length,
            itemBuilder: (context, int index) {
              var curTx = snapshot.data[index];
              IconData curIcon;
              Color iconCol;
              Color textCol;
              if (curTx.type == 'receive') {
                curIcon = Icons.arrow_downward;
                iconCol = Colors.green;
                textCol = Colors.green[400];
              } else if (curTx.type == 'send') {
                curIcon = Icons.send;
                iconCol = Colors.red;
                textCol = Colors.red[400];
              }
              final showAccount = curTx.fromAccount.substring(0, 10) +
                  '....' +
                  curTx.fromAccount.substring(60);
              return Card(
                child: ListTile(
                  title: Text('${NanoHelper.rawToNano(curTx.amountRaw)} Nano',
                      style: TextStyle(color: textCol)),
                  subtitle: Text(
                      '$showAccount  | ${formatter.format(curTx.timeStampDate)}',
                      style: TextStyle(color: Colors.black)),
                  trailing: Icon(curIcon, color: iconCol),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
