import 'package:flutter/foundation.dart';

import 'package:nanodart/nanodart.dart';

import '../helper/nanoHelper.dart';

class Account {
  int index;
  String address;
  String frontier;
  String rawBalance;
  String representative;

  Account({
    @required this.index,
    @required this.address,
    @required this.frontier,
    @required this.rawBalance,
    @required this.representative,
  });

  BigInt getBigIntRawBalance() {
    return BigInt.parse(this.rawBalance);
  }

  String getStringNanoBalance() {
    return NanoHelper.rawToNano(this.getBigIntRawBalance());
  }

  Future<Map<String, String>> makeSendBlock(
      {String sendToAccount, String newBalance, String newPreviousHash}) async {
    // Unless newPreviousHash is not empty, the previous is simply the frontier from the server.
    // If we are making two send blocks, the previous of the second block will be the hash of the first
    // block. If we are only making one send block then previous should be the frontier received from the server
    final previous = (newPreviousHash == '') ? frontier : newPreviousHash;
    final tick = DateTime.now().millisecondsSinceEpoch;
    final Map<String, String> hashAndSignature =
        await NanoHelper.getHashAndSignature(
      index: index,
      account: address,
      previous: previous,
      representative: representative,
      newBalance: BigInt.parse(newBalance),
      link: sendToAccount,
    );
    final tock = DateTime.now().millisecondsSinceEpoch;
    print(
        'Time getHashAndSignature for one block: ${(tock - tick) / 1000} second');
    final hash = hashAndSignature['hash'];
    final signature = hashAndSignature['signature'];

    final Map<String, String> block = {
      'subtype': 'send',
      'representative': representative,
      'previous': previous,
      'account': address,
      'balance': newBalance,
      'link': sendToAccount,
      'signature': signature,
      'work': previous,
      'hash': hash,
    };

    // Assume blocks have been processed successfully
    this.rawBalance = newBalance;
    this.frontier = block['hash'];

    return block;
  }

  Future<Map<String, String>> makeReceiveBlock(
      {String hashAsLink, String raw}) async {
    BigInt oldBalance = this.getBigIntRawBalance();
    String frontier = this.frontier;
    final BigInt newBalance = oldBalance + BigInt.parse(raw);
    print(hashAsLink);
    print(frontier);
    print(raw);

    final previous =
        (frontier == '') ? '00000000000000000000000000000000' : frontier;
    final work = (frontier == '')
        ? NanoAccounts.extractPublicKey(this.address)
        : frontier;
    final Map<String, String> hashAndSignature =
        await NanoHelper.getHashAndSignature(
      index: index,
      account: this.address,
      previous: previous,
      representative: representative,
      newBalance: newBalance,
      link: hashAsLink,
    );
    final signature = hashAndSignature['signature'];
    final newBalanceString = newBalance.toString();

    final block = {
      'subtype': 'receive',
      'representative': representative,
      'previous': previous,
      'account': this.address,
      'balance': newBalanceString,
      'link': hashAsLink,
      'signature': signature,
      'work': work,
    };

    // Assume block was processed successfully
    this.rawBalance = newBalanceString;
    this.frontier = block['hash'];

    return block;
  }
}
