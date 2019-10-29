import 'package:flutter/material.dart';

import '../../widgets/bigContainer.dart';
import '../../widgets/gradientBackground.dart';
import '../../widgets/bigButton.dart';
import '../../helper/storage.dart';
import '../../helper/appConfig.dart';
import './baseSettingsPage.dart';

import '../welcomePages/welcomePage.dart';

class ShowDeleteSeedPage extends StatelessWidget with BaseSettingsPage {
  Widget body(BuildContext context) {
    return Stack(
      children: [
        Align(
          alignment: Alignment.topCenter,
          child: Column(
            children: [
              Padding(
                padding:
                    EdgeInsets.fromLTRB(0, blockHeight, 0, blockHeight * 2),
                child: Text(
                  'Are you sure you want to delete your seed?',
                  style: TextStyle(fontSize: blockHeight * 5),
                  textAlign: TextAlign.center,
                ),
              ),
              Text(
                'If you have not backed up your seed, all your Nano will be forever gone.',
                style: TextStyle(fontSize: blockHeight * 3),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        Align(
          alignment: Alignment.center,
          child: BigButton(
            text: 'Delete Seed',
            onPressed: () async {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text("Are you sure you want to delete your seed?"),
                    content: Text(
                        "Your Nano will be forever gone if you have not backed up your seed."),
                    actions: [
                      BigButton(
                        text: 'Delete Seed',
                        onPressed: () async {
                          await deleteDb();
                          await deleteAll();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => WelcomePage()),
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
        Align(
          alignment: Alignment.bottomCenter,
          child: BigButton(
            text: 'Go Back',
            onPressed: () async {
              Navigator.pop(context);
            },
          ),
        ),
      ],
    );
  }
}
