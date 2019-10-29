import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../widgets/bigButton.dart';
import '../../widgets/bigContainer.dart';
import '../../widgets/gradientBackground.dart';
import '../../helper/appConfig.dart';

import './setPinPage.dart';

class WelcomePage extends StatelessWidget {
  final double blockHeight = AppConfig.blockSizeHeight;
  final double blockWidth = AppConfig.blockSizeWidth;

  Widget build(BuildContext context) {
    return Scaffold(
      body: WillPopScope(
        onWillPop: () => SystemNavigator.pop(),
        child: GradientBackground(
          child: BigContainer(
            child: Stack(
              children: [
                Align(
                  alignment: Alignment.topCenter,
                  child: Column(
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.fromLTRB(
                            0, blockHeight * 3, 0, blockHeight * 3),
                        child: Text(
                          'Nanonymous',
                          style: TextStyle(fontSize: blockHeight * 5),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.fromLTRB(
                            0, blockHeight, 0, blockHeight * 3),
                        child: Text(
                          'This Nano wallet is a Proof of Concept that shows how one can create a privacy-focused wallet.',
                          style: TextStyle(fontSize: blockHeight * 3),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Padding(
                        padding:
                            EdgeInsets.fromLTRB(0, blockHeight, 0, blockHeight),
                        child: Text(
                          'This wallet may contain bugs. Please only send small amounts of Nano to this wallet. The developers of this wallet takes no responsibility if any users lose their Nano by using this wallet. You have been warned.',
                          style: TextStyle(fontSize: blockHeight * 3),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: EdgeInsets.only(bottom: blockHeight * 3),
                    child: BigButton(
                      text: 'Continue',
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => SetPinPage()),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
