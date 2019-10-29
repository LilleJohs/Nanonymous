import 'package:flutter/material.dart';

import '../../widgets/keyboard.dart';
import '../../widgets/bigContainer.dart';
import '../../widgets/gradientBackground.dart';
import '../../helper/storage.dart';
import '../../helper/appConfig.dart';
import '../../widgets/textWithBackground.dart';

import './confirmSeedPage.dart';

class SetPinPage extends StatefulWidget {
  @override
  _SetPinPageState createState() => _SetPinPageState();
}

class _SetPinPageState extends State<SetPinPage> {
  final double blockHeight = AppConfig.blockSizeHeight;
  final double blockWidth = AppConfig.blockSizeWidth;
  String firstPin = '';
  String secondPin = '';
  String errorMessage = '';
  bool repeatPin = false;

  addNumber(String number) async {
    if (!repeatPin) {
      String newPin = firstPin + number;
      setState(() {
        firstPin = newPin;
      });
      if (firstPin.length == 6) {
        setState(() {
          errorMessage = 'Repeat';
          repeatPin = true;
        });
      }
    } else {
      String newPin = secondPin + number;
      setState(() {
        secondPin = newPin;
      });
      if (secondPin.length == 6) {
        if (secondPin == firstPin) {
          bool doesSeedExistAlready = await doesSeedExist();
          if (!doesSeedExistAlready) {
            await createSeed();
          }
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ConfirmSeedPage(finalPin: firstPin)),
          );
        } else {
          setState(() {
            errorMessage = 'Wrong, try again';
            firstPin = '';
            secondPin = '';
            repeatPin = false;
          });
        }
      }
    }
  }

  removeNumber() {
    if (!repeatPin) {
      if (firstPin.length >= 1) {
        setState(() {
          firstPin = firstPin.substring(0, firstPin.length - 1);
        });
      }
    } else {
      if (secondPin.length >= 1) {
        setState(() {
          secondPin = secondPin.substring(0, secondPin.length - 1);
        });
      }
    }
  }

  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        child: BigContainer(
          child: Stack(
            children: [
              Align(
                alignment: Alignment.topCenter,
                child: TextWithBackground(
                  text: 'Set your PIN',
                  width: 75,
                  fontMultiplier: 7,
                ),
              ),
              Align(
                alignment: Alignment(0, -0.7),
                child: Text(
                  errorMessage,
                  style: TextStyle(fontSize: blockHeight * 5),
                ),
              ),
              Align(
                alignment: Alignment(0, -0.4),
                child: Text(
                  (!repeatPin) ? firstPin : secondPin,
                  style: TextStyle(fontSize: blockHeight * 10),
                ),
              ),
              Align(
                alignment: Alignment(0, -0.2),
                child: Container(
                  width: blockWidth * 60,
                  height: blockHeight,
                  color: Colors.black,
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Keyboard(
                    addNumber: this.addNumber, removeNumber: this.removeNumber),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
