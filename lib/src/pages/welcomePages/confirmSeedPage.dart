import 'package:flutter/material.dart';

import '../../widgets/bigButton.dart';
import '../../widgets/bigContainer.dart';
import '../../widgets/gradientBackground.dart';
import '../../widgets/textWithBackground.dart';
import '../../helper/storage.dart';
import '../../app.dart';
import '../../helper/appConfig.dart';

class ConfirmSeedPage extends StatefulWidget {
  final String finalPin;
  final Future<String> seed;

  ConfirmSeedPage({this.finalPin}) : seed = getSeed();

  @override
  _ConfirmSeedPageState createState() => _ConfirmSeedPageState();
}

class _ConfirmSeedPageState extends State<ConfirmSeedPage> {
  final double blockHeight = AppConfig.blockSizeHeight;
  final double blockWidth = AppConfig.blockSizeWidth;

  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        child: BigContainer(
          child: Stack(
            children: [
              Align(
                alignment: Alignment.topCenter,
                child: Text(
                  'Here is your seed',
                  style: TextStyle(fontSize: blockHeight * 4),
                ),
              ),
              Align(
                alignment: Alignment(0, -0.7),
                child: Text(
                  'Make sure you save your seed. Without your seed you will lose your money if your device gets broken or lost.',
                  style: TextStyle(fontSize: blockHeight * 3),
                  textAlign: TextAlign.center,
                ),
              ),
              Align(
                alignment: Alignment(0, 0),
                child: FutureBuilder<String>(
                  future: widget.seed,
                  builder:
                      (BuildContext context, AsyncSnapshot<String> snapshot) {
                    if (snapshot.hasData) {
                      return TextWithBackground(
                        text: snapshot.data,
                        width: 75,
                        fontMultiplier: 5,
                      );
                    } else {
                      return Text('Loading...');
                    }
                  },
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: EdgeInsets.only(bottom: blockHeight * 3),
                  child: BigButton(
                    text: 'Continue',
                    onPressed: () async {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text("Confirm you have backed up your seed"),
                            content: Text(
                                "If you have not backed up your seed, your Nano will be lost if you lose or break your device."),
                            actions: [
                              BigButton(
                                text: 'I Understand',
                                onPressed: () async {
                                  await setPin(widget.finalPin);
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => MainPage()),
                                  );
                                },
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
