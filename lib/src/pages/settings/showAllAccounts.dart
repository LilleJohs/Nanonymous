import 'package:flutter/material.dart';

import 'package:url_launcher/url_launcher.dart';

import '../../widgets/gradientBackground.dart';
import '../../models/account.dart';
import '../../models/accountList.dart';

class ShowAccountsPage extends StatelessWidget {
  final AccountList accountList;

  ShowAccountsPage({this.accountList});

  @override
  Widget build(BuildContext context) {
    final Map<int, Account> accounts = accountList.getAccounts;
    final List<int> keys = accounts.keys.toList();
    return Scaffold(
      body: GradientBackground(
        child: Center(
          child: ListView.builder(
            padding: EdgeInsets.only(top: 20.0),
            itemCount: keys.length,
            itemBuilder: (BuildContext context, int index) {
              final int curIndex = keys.length - index - 1;
              final int curKey = keys[curIndex];
              final Account accountObj = accounts[curKey];
              final String balance = accountObj.getStringNanoBalance();
              final String account = accountObj.address;
              final String showAccount =
                  account.substring(0, 10) + '....' + account.substring(60);
              return Card(
                child: ExpansionTile(
                  title: ListTile(
                    title: Text('$showAccount'),
                    subtitle: Text('Index: $curKey | Balance: $balance Nano'),
                  ),
                  children: <Widget>[
                    ListTile(
                      title: Text('Open in NanoCrawler'),
                      trailing: Icon(Icons.open_in_browser),
                      onTap: () => _openUrl(account),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

_openUrl(String account) async {
  final url = 'https://nanocrawler.cc/explorer/account/$account';
  if (await canLaunch(url)) {
    await launch(url);
  } else {
    throw 'Could not launch $url';
  }
}
