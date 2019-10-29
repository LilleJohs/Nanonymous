import 'dart:core';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import './widgets/gradientBackground.dart';
import './bloc/wallet.dart';
import './pages/homePage.dart';
import './pages/sendPage.dart';
import './pages/receivePage.dart';
import './pages/settingsPage.dart';
import './pages/welcomePages/welcomePage.dart';
import './helper/storage.dart';
import './helper/appConfig.dart';

class MyApp extends StatelessWidget {
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Nanonymous',
      home: Splash(),
    );
  }
}

class Splash extends StatefulWidget {
  _SplashState createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  initState() {
    super.initState();
    nextPage(context);
  }

  nextPage(BuildContext context) async {
    bool seedExists = await doesSeedExist();
    bool pinExists = await doesPinExist();
    // If not both seed and pin exist, then do welcome screen
    if (seedExists && pinExists) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => MainPage()),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => WelcomePage()),
      );
    }
  }

  Widget build(BuildContext context) {
    AppConfig(context);
    return Scaffold(
      body: GradientBackground(),
    );
  }
}

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final Wallet _wallet = Wallet();

  List<BottomNavigationBarItem> _navigationBarItems = [
    BottomNavigationBarItem(
      title: Container(height: 0.0),
      icon: Icon(Icons.arrow_downward),
    ),
    BottomNavigationBarItem(
      title: Container(height: 0.0),
      icon: Icon(Icons.home),
    ),
    BottomNavigationBarItem(
      title: Container(height: 0.0),
      icon: Icon(Icons.send),
    ),
    BottomNavigationBarItem(
      title: Container(height: 0.0),
      icon: Icon(Icons.settings),
    ),
  ];
  List<Widget> _pages;
  int _index = 1;
  PageController _pageController = PageController(
    initialPage: 1,
    keepPage: true,
  );

  @override
  void initState() {
    _pages = [
      ReceivePage(wallet: _wallet),
      HomePage(wallet: _wallet),
      SendPage(wallet: _wallet),
      SettingsPage(wallet: _wallet)
    ];
    super.initState();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      body: WillPopScope(
        onWillPop: () => SystemNavigator.pop(),
        child: GradientBackground(
          wallet: _wallet,
          child: PageView(
            controller: _pageController,
            children: _pages,
            onPageChanged: (index) {
              setState(() {
                _index = index;
              });
            },
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _index,
        items: _navigationBarItems,
        selectedItemColor: Colors.orange,
        unselectedItemColor: Colors.black,
        onTap: (index) {
          switchPage(index);
        },
      ),
    );
  }

  void switchPage(index) {
    setState(() => _index = index);
    _pageController.animateToPage(index,
        duration: Duration(milliseconds: 500), curve: Curves.ease);
  }
}
