import 'package:flutter/material.dart';

import '../bloc/wallet.dart';
import '../helper/appConfig.dart';
import './bigButton.dart';
import './gradientBackground.dart';
import './verify.dart';

class AreYouSure extends StatefulWidget {
  final String account;
  final String amount;
  final Wallet wallet;

  AreYouSure({this.amount, this.account, this.wallet});

  _AreYouSureState createState() => _AreYouSureState();
}

class _AreYouSureState extends State<AreYouSure>
    with SingleTickerProviderStateMixin {
  Animation<double> animation;
  AnimationController controller;

  @override
  void initState() {
    super.initState();
    controller =
        AnimationController(duration: const Duration(seconds: 2), vsync: this);
    animation = Tween<double>(begin: 0, end: 1.0).animate(
        CurvedAnimation(parent: controller, curve: Curves.fastOutSlowIn))
      ..addListener(() {
        setState(() {});
      });
  }

  final double blockWidth = AppConfig.blockSizeWidth;
  final double blockHeight = AppConfig.blockSizeHeight;
  final TextStyle textStyle = TextStyle(
    color: Colors.white,
    fontWeight: FontWeight.bold,
    fontSize: AppConfig.blockSizeHeight * 3,
  );
  int index = 0;
  bool processingError = false;

  Widget build(BuildContext context) {
    final double value = animation.value;
    final Color topDef = Colors.blue[500];
    final Color bottDef = Colors.blue[800];
    Color bottomColor;
    Color topColor;
    if (!processingError) {
      bottomColor = Color.fromARGB(
          255,
          bottDef.red,
          bottDef.green + (value * 100).round(),
          (bottDef.blue * (1 - value)).round());
      topColor = Color.fromARGB(
          255,
          topDef.red,
          topDef.green + (value * 100).round(),
          (topDef.blue * (1 - value)).round());
    } else {
      bottomColor = Color.fromARGB(
        255,
        bottDef.red + (value * 220).round(),
        (bottDef.green * (1 - value)).round(),
        (bottDef.blue * (1 - value)).round(),
      );
      topColor = Color.fromARGB(
        255,
        topDef.red + (value * 200).round(),
        (topDef.blue * (1 - value)).round(),
        (topDef.blue * (1 - value)).round(),
      );
    }

    return Scaffold(
      body: GradientBackground(
        child: index == 0 ? firstPage() : secondPage(),
        bottomColor: bottomColor,
        topColor: topColor,
      ),
    );
  }

  firstPage() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          'Send',
          style: textStyle,
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.orange,
            borderRadius: new BorderRadius.all(Radius.circular(7.0)),
          ),
          width: blockWidth * 80,
          height: blockHeight * 8,
          child: Center(child: Text('${widget.amount} Nano', style: textStyle)),
        ),
        Text(
          'to',
          style: textStyle,
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.orange,
            borderRadius: new BorderRadius.all(Radius.circular(7.0)),
          ),
          width: blockWidth * 80,
          height: blockHeight * 15,
          padding: EdgeInsets.all(10.0),
          child: Center(child: Text(widget.account, style: textStyle)),
        ),
        Text(
          'Are you sure?',
          style: textStyle,
        ),
        Container(
          margin: EdgeInsets.all(10.0),
          padding: EdgeInsets.fromLTRB(5.0, 0.0, 5.0, 0.0),
          height: blockHeight * 20,
          decoration: BoxDecoration(
            color: Colors.orange,
            borderRadius: new BorderRadius.all(Radius.circular(7.0)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Expanded(
                child: Container(
                  margin: EdgeInsets.only(right: 2.5),
                  decoration: BoxDecoration(
                      color: Colors.lightGreen[50],
                      borderRadius: BorderRadius.circular(15.0)),
                  child: ListTile(
                    title: Text('Yes', style: TextStyle(color: Colors.green)),
                    trailing:
                        Icon(Icons.check_circle_outline, color: Colors.green),
                    onTap: () {
                      CheckVerify(
                        context: context,
                        callback: () async {
                          setState(() {
                            index = 1;
                          });
                          // Wait 0.5 seconds so that we switch screen before making blocks
                          await Future.delayed(
                              const Duration(milliseconds: 500));
                          waitForServer();
                        },
                      );
                    },
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  margin: EdgeInsets.only(left: 2.5),
                  decoration: BoxDecoration(
                      color: Colors.red[50],
                      borderRadius: BorderRadius.circular(15.0)),
                  child: ListTile(
                      title: Text('No', style: TextStyle(color: Colors.red)),
                      trailing: Icon(Icons.cancel, color: Colors.red),
                      onTap: () {
                        Navigator.pop(context);
                      }),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  secondPage() {
    Widget whatToShow;
    final double value = animation.value;
    if (value == 0.0) {
      whatToShow = CircularProgressIndicator();
    } else {
      final int alpha = (255 * value).round();
      List<Widget> children = [
        Icon(
          processingError ? Icons.cancel : Icons.check_box,
          color: Colors.white,
          size: blockWidth * 40,
        ),
        Container(height: blockHeight * 5),
        Text(
          processingError
              ? 'The transaction partially or fully failed. Your funds are safe, but some of the Nano may have not been sent.'
              : '',
          style: TextStyle(fontSize: blockHeight * 4, color: Colors.white),
          textAlign: TextAlign.center,
        ),
        Container(height: blockHeight * 10),
        BigButton(
          text: 'Continue',
          onPressed: () {
            if (value == 1.0) {
              Navigator.pop(context);
            }
          },
          backgroundColor: Color.fromARGB(alpha, 255, 255, 255),
          textColor: processingError
              ? Color.fromARGB(alpha, 255, 0, 0)
              : Color.fromARGB(alpha, 0, 255, 0),
        ),
      ];
      whatToShow = Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: children,
        ),
      );
    }
    return Center(
      child: whatToShow,
    );
  }

  waitForServer() async {
    final wallet = widget.wallet;
    wallet.waitForResponse.sink.add('');
    wallet.makeSendTransaction(widget.account, widget.amount);
    Future<String> whenTrue(Stream<String> source) {
      //Resolves when the stream receives a 'true' which comes from readMessage() in Wallet
      return source.firstWhere((String item) {
        if (item == 'GETINFO') {
          controller.forward();
          return true;
        } else if (item == 'ERROR_PROCESSING_SEND') {
          setState(() {
            processingError = true;
          });
          controller.forward();
          return false;
        } else {
          return false;
        }
      });
    }

    await whenTrue(wallet.waitForResponse.stream);
  }
}
