import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../helper/appConfig.dart';

class SendFormInput extends StatelessWidget {
  final blockHeight = AppConfig.blockSizeHeight;
  final blockWidth = AppConfig.blockSizeWidth;

  final TextEditingController controller;
  final Function(String) onSaved;
  final Function(String) validator;
  final Function() onButtonPressed;
  final String buttonText;
  final int lines;
  final TextInputType keyboardType;
  final String labelText;
  final String hintText;

  SendFormInput({
    this.controller,
    this.onSaved,
    this.validator,
    this.onButtonPressed,
    this.buttonText,
    this.lines,
    this.keyboardType,
    this.labelText,
    this.hintText,
  });

  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(blockHeight * 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Expanded(
            flex: 11,
            child: TextFormField(
              style: TextStyle(fontSize: blockWidth * 4),
              keyboardType: keyboardType,
              controller: controller,
              maxLines: lines,
              minLines: lines,
              onSaved: (String value) => onSaved(value),
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25.0),
                  borderSide: BorderSide(),
                ),
                labelText: labelText,
                hintText: hintText,
              ),
              validator: validator,
            ),
          ),
          Spacer(),
          Expanded(
            flex: 4,
            child: RaisedButton(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0)),
              color: Colors.orange,
              child: Text(buttonText,
                  style:
                      TextStyle(color: Colors.white, fontSize: blockWidth * 4)),
              onPressed: onButtonPressed,
            ),
          ),
        ],
      ),
    );
  }
}
