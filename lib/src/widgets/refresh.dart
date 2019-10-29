import 'package:flutter/material.dart';

import '../bloc/wallet.dart';

class Refresh extends StatelessWidget {
  final Widget child;
  final Wallet wallet;

  Refresh({this.child, this.wallet});

  Widget build(context) {
    return RefreshIndicator(
      child: child,
      onRefresh: () async {
        wallet.waitForResponse.sink.add('');
        wallet.getAccountInfo();
        Future<String> whenTrue(Stream<String> source) {
          //Resolves when the stream receives a 'true' which comes from readMessage() in wallet bloc
          return source.firstWhere((String item) => item == 'GETINFO');
        }

        await whenTrue(wallet.waitForResponse.stream);
      },
    );
  }
}
