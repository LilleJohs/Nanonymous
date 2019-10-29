import 'package:flutter/material.dart';

import '../bloc/wallet.dart';
import '../widgets/bigButton.dart';

class GradientBackground extends StatelessWidget {
  final Widget child;
  final Wallet wallet;
  final Color topColor;
  final Color bottomColor;

  GradientBackground(
      {this.child, this.wallet, this.topColor, this.bottomColor});

  Widget build(BuildContext context) {
    if (wallet != null && !wallet.hasShownAlert) {
      // Show alert box if the server has a message. Used if there is a critical bug
      // and the user should update app.
      wallet.alertFromServer.stream.listen((String message) {
        wallet.hasShownAlert = true;
        showDialog(
          barrierDismissible: false,
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("Alert From Server"),
              content: Text(message),
              actions: <Widget>[
                BigButton(
                    text: 'I Understand',
                    onPressed: () {
                      Navigator.pop(context);
                    })
              ],
            );
          },
        );
      });
    }

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: [0.0, 1.0],
          colors: [
            (this.topColor == null) ? Colors.blue[500] : this.topColor,
            (this.bottomColor == null) ? Colors.blue[800] : this.bottomColor,
          ],
        ),
      ),
      child: child,
    );
  }
}
