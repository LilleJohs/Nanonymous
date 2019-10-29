import 'package:Nanonymous/src/pages/settings/baseSettingsPage.dart';
import 'package:flutter/material.dart';

import '../../widgets/bigButton.dart';
import '../../helper/appConfig.dart';

class ShowDisclaimerPage extends StatelessWidget with BaseSettingsPage {
  final double blockWidth = AppConfig.blockSizeWidth;
  final double blockHeight = AppConfig.blockSizeHeight;

  Widget body(BuildContext context) {
    return Stack(
      children: [
        Align(
          alignment: Alignment.topCenter,
          child: Column(
            children: [
              Text(
                'Disclaimer',
                style: TextStyle(fontSize: blockHeight * 5),
                textAlign: TextAlign.center,
              ),
              Divider(),
              Text(
                'This wallet is not a perfect piece of software and may contain bugs. The developers of this wallet takes no responsibility if the users lose their Nano. \n Use this wallet with caution.',
                style: TextStyle(fontSize: blockHeight * 3),
                textAlign: TextAlign.center,
              ),
            ],
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
