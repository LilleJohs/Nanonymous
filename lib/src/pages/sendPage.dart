import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:decimal/decimal.dart';
import 'package:nanodart/nanodart.dart';
import 'package:barcode_scan/barcode_scan.dart';

import '../bloc/wallet.dart';
import '../helper/nanoHelper.dart';
import '../widgets/areYouSure.dart';
import '../widgets/bigButton.dart';
import '../widgets/sendFormInput.dart';
import '../helper/appConfig.dart';

class SendPage extends StatefulWidget {
  final Wallet wallet;

  SendPage({this.wallet});

  @override
  _SendPageState createState() => _SendPageState();
}

class _SendPageState extends State<SendPage> {
  final sendKey = GlobalKey<FormState>();
  String barcode = "";
  String sendToAccount = '';
  String sendAmount = '';
  final double blockWidth = AppConfig.blockSizeWidth;
  final double blockHeight = AppConfig.blockSizeHeight;

  TextEditingController _amountController = TextEditingController();
  TextEditingController _toAccountController = TextEditingController();

  @override
  initState() {
    super.initState();
    _toAccountController.value =
        _toAccountController.value = TextEditingValue(text: '');
  }

  Widget build(BuildContext context) {
    final Wallet wallet = widget.wallet;
    return Center(
      child: StreamBuilder(
        stream: wallet.balanceStream,
        builder: (BuildContext context, AsyncSnapshot<BigInt> snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          return Column(
            children: [
              Container(height: blockHeight * 3),
              Container(
                height: blockHeight * 15,
                child: Center(
                  child: Text('${NanoHelper.rawToNano(snapshot.data)} Nano',
                      style: TextStyle(
                          color: Colors.white, fontSize: blockHeight * 5)),
                ),
              ),
              Container(
                height: blockHeight * 65,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: new BorderRadius.all(Radius.circular(7.0))),
                alignment: Alignment.bottomCenter,
                margin: EdgeInsets.only(
                    left: blockWidth * 4, right: blockWidth * 4),
                child: Form(
                  key: sendKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      accountField(),
                      amountField(wallet, snapshot.data),
                      sendButton(wallet, context),
                      qrButton(),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget accountField() {
    return SendFormInput(
      controller: _toAccountController,
      onSaved: (String value) {
        print(value);
        sendToAccount = value.trim();
      },
      validator: (String value) {
        return validateAccount(value);
      },
      onButtonPressed: () async {
        ClipboardData data = await Clipboard.getData('text/plain');
        if (data != null) {
          _toAccountController.value = TextEditingValue(text: data.text);
        }
      },
      lines: 3,
      buttonText: 'Paste',
      keyboardType: TextInputType.text,
      labelText: 'Address',
      hintText: 'nano_...',
    );
  }

  Widget amountField(Wallet wallet, BigInt balance) {
    return SendFormInput(
      controller: _amountController,
      onSaved: (String value) {
        sendAmount = value;
      },
      validator: (String value) {
        return validateAmount(wallet.balance.value, value);
      },
      onButtonPressed: () async {
        _amountController.value =
            TextEditingValue(text: NanoHelper.rawToNano(balance));
      },
      lines: 1,
      buttonText: 'All',
      keyboardType: TextInputType.number,
      labelText: 'Amount',
      hintText: '',
    );
  }

  Widget sendButton(Wallet wallet, BuildContext context) {
    return BigButton(
      text: 'Send',
      onPressed: () {
        if (sendKey.currentState.validate()) {
          print(sendToAccount);
          sendKey.currentState.save();
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AreYouSure(
                amount: sendAmount,
                account: sendToAccount,
                wallet: wallet,
              ),
            ),
          );
        }
      },
    );
  }

  Widget qrButton() {
    return BigButton(
      text: 'Scan QR Code',
      onPressed: scan,
    );
  }

  Future scan() async {
    try {
      String barcode = await BarcodeScanner.scan();
      print(barcode);
      if (NanoAccounts.isValid(NanoAccountType.NANO, barcode)) {
        _toAccountController.value = TextEditingValue(text: barcode);
      } else {
        List<String> splitString = barcode.split(':');

        if ((splitString[0] == 'nano' || splitString[0] == 'xrb') &&
            splitString.length >= 2) {
          String account = splitString[1].split('?')[0];
          _toAccountController.value = TextEditingValue(text: account);

          Uri parameters = Uri.parse(splitString[1]);
          parameters.queryParameters.forEach((k, v) {
            if (k == 'amount') {
              if (v.length < 24) {
                throw 'Cant send less than 0.000001 Nano';
              }

              _amountController.value =
                  TextEditingValue(text: NanoHelper.rawToNano(BigInt.parse(v)));
            }
          });
          sendKey.currentState.validate();
        } else {
          throw 'Invalid QR code';
        }
      }
    } on PlatformException catch (e) {
      if (e.code == BarcodeScanner.CameraAccessDenied) {
        setState(() {
          this.barcode = 'The user did not grant the camera permission!';
        });
      } else {
        setState(() => this.barcode = 'Unknown error: $e');
      }
    } on FormatException {
      setState(() => this.barcode =
          'null (User returned using the "back"-button before scanning anything. Result)');
    } catch (e) {
      setState(() => this.barcode = 'Unknown error: $e');
    }
  }

  String validateAccount(String value) {
    if (value == '') {
      return 'No input';
    }
    if (!NanoAccounts.isValid(NanoAccountType.NANO, value)) {
      return 'Account is not valid';
    }
    return null;
  }

  String validateAmount(BigInt balance, String value) {
    if (value.trim() == '') {
      return 'No input';
    }
    var decimal;
    try {
      decimal = Decimal.parse(value);
    } on FormatException {
      return 'That is not a number';
    }
    if (decimal.scale >= 31) {
      return 'Too many digits';
    }

    final amountRaw = NanoHelper.nanoToRaw(value);
    if (balance < amountRaw) {
      return "You don't have enough Nano";
    }
    if (amountRaw == BigInt.from(0)) {
      return "You can't send 0 Nano";
    }
    if (amountRaw < BigInt.from(0)) {
      return "You can't send a negative amount of Nano";
    }

    return null;
  }
}
