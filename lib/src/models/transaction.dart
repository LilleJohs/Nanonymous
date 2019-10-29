class Transaction {
  String type;
  String fromAccount;
  BigInt amountRaw;
  String hash;
  int timeStamp;
  DateTime timeStampDate;

  Transaction({this.fromAccount, this.amountRaw, this.type});

  Transaction.fromJson(Map<String, dynamic> parsedJson)
      : type = parsedJson['type'],
        fromAccount = parsedJson['account'],
        amountRaw = BigInt.parse(parsedJson['amount']),
        hash = parsedJson['hash'],
        timeStamp = int.parse(parsedJson['local_timestamp']),
        timeStampDate = DateTime.fromMillisecondsSinceEpoch(
            1000 * int.parse(parsedJson['local_timestamp']));
}
