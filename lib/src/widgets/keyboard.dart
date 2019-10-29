import 'package:flutter/material.dart';

import '../helper/appConfig.dart';

class Keyboard extends StatefulWidget {
  final Function(String) addNumber;
  final Function() removeNumber;

  Keyboard({this.addNumber, this.removeNumber});

  _KeyboardState createState() => _KeyboardState();
}

class _KeyboardState extends State<Keyboard> {
  final double blockHeight = AppConfig.blockSizeHeight;

  Widget build(BuildContext context) {
    return Container(
      height: blockHeight * 40,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              PinButton('1', widget.addNumber),
              PinButton('2', widget.addNumber),
              PinButton('3', widget.addNumber),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              PinButton('4', widget.addNumber),
              PinButton('5', widget.addNumber),
              PinButton('6', widget.addNumber),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              PinButton('7', widget.addNumber),
              PinButton('8', widget.addNumber),
              PinButton('9', widget.addNumber),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              PinButton('0', widget.addNumber),
              PinButton.back(widget.removeNumber),
            ],
          )
        ],
      ),
    );
  }
}

class PinButton extends StatelessWidget {
  final String number;
  final Function(String) addNumber;

  final Function() removeNumber;
  final bool backButton;

  final double blockWidth = AppConfig.blockSizeWidth;

  PinButton(this.number, this.addNumber)
      : backButton = false,
        removeNumber = null;
  PinButton.back(this.removeNumber)
      : number = '',
        addNumber = null,
        backButton = true;

  Widget build(BuildContext context) {
    Widget childWidget = backButton
        ? Icon(
            Icons.backspace,
            size: blockWidth * 8,
            color: Colors.white,
          )
        : Text(number,
            style: TextStyle(color: Colors.white, fontSize: blockWidth * 7));

    return Expanded(
      child: Padding(
        padding: EdgeInsets.all(blockWidth),
        child: RaisedButton(
          padding: EdgeInsets.fromLTRB(0, blockWidth * 3, 0, blockWidth * 3),
          color: Colors.orange,
          child: childWidget,
          onPressed: () => backButton ? removeNumber() : addNumber(number),
        ),
      ),
    );
  }
}
