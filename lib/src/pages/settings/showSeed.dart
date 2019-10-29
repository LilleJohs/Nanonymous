import 'package:Nanonymous/src/pages/settings/baseSettingsPage.dart';
import 'package:flutter/material.dart';

import '../../widgets/bigContainer.dart';
import '../../widgets/bigButton.dart';
import '../../widgets/gradientBackground.dart';
import '../../helper/storage.dart';
import '../../helper/appConfig.dart';

class ShowSeedPage extends StatefulWidget {
  @override
  _ShowSeedPageState createState() => _ShowSeedPageState();
}

class _ShowSeedPageState extends State<ShowSeedPage> with BaseSettingsPage {
  final double blockWidth = AppConfig.blockSizeWidth;
  final double blockHeight = AppConfig.blockSizeHeight;

  Future<String> seed;

  _ShowSeedPageState() {
    seed = getSeed();
  }

  @override
  Widget body(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(height: blockHeight * 2),
        Text(
          'Never show your seed to anyone!',
          style: TextStyle(
              color: Colors.black, fontSize: 25, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        Container(height: blockHeight * 2),
        Text(
          'Knowing your seed is the only way to restore your Nano on another device!',
          style: TextStyle(color: Colors.black, fontSize: 20),
          textAlign: TextAlign.center,
        ),
        Container(height: blockHeight * 2),
        FutureBuilder(
          future: seed,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Text('Loading');
            }
            return Text(snapshot.data);
          },
        ),
        Container(height: blockHeight * 2),
        BigButton(text: 'Go Back', onPressed: () => Navigator.pop(context))
      ],
    );
  }
}
