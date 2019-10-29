import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';

import '../helper/appConfig.dart';
import './textWithBackground.dart';
import './keyboard.dart';
import './bigContainer.dart';
import '../helper/storage.dart';

class CheckVerify {
  final Function() callback;
  final BuildContext context;
  final localAuth;

  CheckVerify({this.callback, @required this.context})
      : localAuth = LocalAuthentication() {
    checkVerify();
  }

  checkVerify() async {
    try {
      bool didAuthenticate = await localAuth.authenticateWithBiometrics(
          localizedReason: 'Please authenticate to show seed');
      if (didAuthenticate) {
        callback();
      } else {
        throw 'Could not authenticate with biometrics';
      }
    } catch (e) {
      print(e);
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return Verify(callback: callback);
        },
      );
    }
  }
}

class Verify extends StatefulWidget {
  final Function() callback;
  final BuildContext context;

  Verify({this.callback, this.context});

  _VerifyState createState() => _VerifyState();
}

class _VerifyState extends State<Verify> {
  final double blockWidth = AppConfig.blockSizeWidth;
  final double blockHeight = AppConfig.blockSizeHeight;

  String pinCode = '';
  int tries = 3;

  addNumber(String number) async {
    String newPin = pinCode + number;
    setState(() {
      pinCode = newPin;
    });
    if (newPin.length == 6) {
      if (await isPinCorrect(newPin)) {
        Navigator.pop(context);
        widget.callback();
      } else {
        final int newTries = tries - 1;
        if (newTries == 0) {
          Navigator.pop(context);
        } else {
          setState(() {
            tries = newTries;
            pinCode = '';
          });
        }
      }
    }
  }

  removeNumber() {
    if (pinCode.length >= 1) {
      setState(() {
        pinCode = pinCode.substring(0, pinCode.length - 1);
      });
    }
  }

  Widget build(BuildContext context) {
    // return object of type Dialog
    return Dialog(
      child: BigContainer(
        child: Stack(
          children: [
            Align(
              alignment: Alignment.topCenter,
              child: TextWithBackground(
                text: 'Enter your PIN',
                width: 70,
                fontMultiplier: 7,
              ),
            ),
            Align(
              alignment: Alignment(0, -0.7),
              child: Text((tries == 3) ? '' : '$tries tries',
                  style: TextStyle(fontSize: blockWidth * 10)),
            ),
            Align(
              alignment: Alignment(0, -0.3),
              child: Text(
                pinCode,
                style: TextStyle(fontSize: blockWidth * 15),
                textAlign: TextAlign.left,
              ),
            ),
            Align(
              alignment: Alignment(0, -0.15),
              child: Container(
                  width: blockWidth * 50,
                  height: blockHeight / 2,
                  color: Colors.black),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Keyboard(
                  addNumber: this.addNumber, removeNumber: this.removeNumber),
            ),
          ],
        ),
      ),
    );
  }
}
