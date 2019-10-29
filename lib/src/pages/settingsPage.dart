import 'package:flutter/material.dart';

import '../bloc/wallet.dart';

import './settings/showDeleteSeed.dart';
import './settings/showSeed.dart';
import './settings/showInfo.dart';
import './settings/showAllAccounts.dart';
import './settings/showDisclaimer.dart';
import '../widgets/verify.dart';

class SettingsPage extends StatefulWidget {
  final Wallet wallet;
  SettingsPage({this.wallet});

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final scrollController = ScrollController();

  Widget build(BuildContext context) {
    final Wallet wallet = widget.wallet;
    return ListView(
      controller: scrollController,
      children: <Widget>[
        Card(
          child: ListTile(
            title: Text('Show Seed'),
            trailing: Icon(Icons.account_balance_wallet),
            onTap: () async {
              CheckVerify(
                context: context,
                callback: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ShowSeedPage()),
                  );
                },
              );
            },
          ),
        ),
        Card(
          child: ListTile(
            title: Text('Show All Accounts'),
            trailing: Icon(Icons.list),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => ShowAccountsPage(
                          accountList: wallet.accounts,
                        )),
              );
            },
          ),
        ),
        Card(
          child: ListTile(
            title: Text('Disclaimer'),
            trailing: Icon(Icons.help),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ShowDisclaimerPage()),
              );
            },
          ),
        ),
        Card(
          child: ListTile(
            title: Text('Delete Seed'),
            trailing: Icon(Icons.delete),
            onTap: () {
              CheckVerify(
                context: context,
                callback: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ShowDeleteSeedPage()),
                  );
                },
              );
            },
          ),
        ),
        Card(
          child: ListTile(
            title: Text('How Does This Wallet Work?'),
            trailing: Icon(Icons.info),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ShowInfoPage()),
              );
            },
          ),
        ),
      ],
    );
  }
}
