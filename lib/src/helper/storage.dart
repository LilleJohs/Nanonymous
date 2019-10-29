import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:nanodart/nanodart.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import './representativeList.dart';
import '../models/account.dart';

final _storage = new FlutterSecureStorage();
Database _database;

const String seedKey = 'nanonymousseed';
const String pinKey = 'nanonymouspin';
const String accountMinimumIndexKey = 'nanonymousMINIMUMindex';
const String accountReceiveIndexKey = 'nanonymousRECEIVEindex';

Future<String> getSeed() async {
  final String seed = await _storage.read(key: seedKey);
  if (NanoSeeds.isValidSeed(seed)) {
    return seed;
  } else {
    print('getSeed returns invalid seed: $seed');
    return '';
  }
}

Future<bool> doesSeedExist() async {
  final String seed = await _storage.read(key: seedKey);
  if (seed == null || !NanoSeeds.isValidSeed(seed)) {
    return false;
  } else {
    return true;
  }
}

Future<bool> doesPinExist() async {
  final String pin = await _storage.read(key: pinKey);
  if (pin == null) {
    return false;
  } else {
    return true;
  }
}

Future<void> createSeed() async {
  // Only create new seed if it does not exist already as a failsafe
  bool doesItExist = await doesSeedExist();
  if (!doesItExist) {
    final String newSeed = NanoSeeds.generateSeed();
    await _storage.write(key: seedKey, value: newSeed);
  }
}

Future<void> deleteAll() async {
  await _storage.deleteAll();
}

Future<int> getMinimumIndex() async {
  final String indexString = await _storage.read(key: accountMinimumIndexKey);
  if (indexString == null) {
    return -1;
  }
  final int index = int.tryParse(indexString) ?? -1;
  return index;
}

Future<int> getReceiveIndex() async {
  final String indexString = await _storage.read(key: accountReceiveIndexKey);
  if (indexString == null) {
    return -1;
  }
  final int index = int.tryParse(indexString) ?? -1;
  return index;
}

Future<bool> setMinimumIndex(int index) async {
  final String indexString = index.toString();
  await _storage.write(key: accountMinimumIndexKey, value: indexString);
  return true;
}

Future<bool> setReceiveIndex(int index) async {
  final String indexString = index.toString();
  await _storage.write(key: accountReceiveIndexKey, value: indexString);
  return true;
}

Future<bool> isPinCorrect(String pin) async {
  final String correctPin = await _storage.read(key: pinKey);
  if (correctPin == pin) {
    return true;
  } else {
    return false;
  }
}

Future<void> setPin(String pin) async {
  await _storage.write(key: pinKey, value: pin);
}

Future<Account> getAccountByIndex(int index) async {
  final Database db = _database;
  final List<Map<String, dynamic>> mapsOfAccounts =
      await db.query('accounts', where: 'id = ?', whereArgs: [index]);
  print(mapsOfAccounts);
  if (mapsOfAccounts.length == 0) {
    final String seed = await getSeed();
    final String publicKey =
        NanoKeys.createPublicKey(NanoKeys.seedToPrivate(seed, index));
    final String account =
        NanoAccounts.createAccount(NanoAccountType.NANO, publicKey);
    final Account acc = Account(
      index: index,
      address: account,
      representative: getRandomRepresentative(),
      rawBalance: '0',
      frontier: '',
    );
    insertAccountIntoDb(acc);
    return acc;
  } else {
    Map<String, dynamic> a = mapsOfAccounts[0];
    print(a);
    final Account acc = Account(
      index: a['id'],
      address: a['account'],
      representative: a['representative'],
      rawBalance: a['balance'],
      frontier: a['frontier'],
    );
    return acc;
  }
}

Future<Map<int, Account>> getAccountByIndexList(
    int startIndex, int endIndex) async {
  Map<int, Account> result = {};
  final Database db = _database;
  final List<Map<String, dynamic>> mapsOfAccounts = await db.query('accounts',
      where: 'id >= ? AND id <= ?', whereArgs: [startIndex, endIndex]);
  mapsOfAccounts.forEach((a) {
    result[a['id']] = Account(
      index: a['id'],
      address: a['account'],
      representative: a['representative'],
      rawBalance: a['balance'],
      frontier: a['frontier'],
    );
  });
  String seed = '';
  for (int i = startIndex; i <= endIndex; i++) {
    if (!result.containsKey(i)) {
      seed = (seed == '') ? await getSeed() : seed;
      final String publicKey =
          NanoKeys.createPublicKey(NanoKeys.seedToPrivate(seed, i));
      final String account =
          NanoAccounts.createAccount(NanoAccountType.NANO, publicKey);
      result[i] = Account(
        index: i,
        address: account,
        representative: getRandomRepresentative(),
        rawBalance: '0',
        frontier: '',
      );
      insertAccountIntoDb(result[i]);
    }
  }
  return result;
}

Future<void> getDatabase() async {
  print('Getting db');
  _database = await openDatabase(
    // Set the path to the database.
    join(await getDatabasesPath(), 'account_database.db'),
    onCreate: (db, version) {
      return db.execute(
        "CREATE TABLE accounts(id INTEGER PRIMARY KEY, account TEXT, balance TEXT, representative TEXT, frontier TEXT)",
      );
    },
    version: 1,
  );
}

Future<void> insertAccountIntoDb(Account account) async {
  final Map<String, dynamic> accountObj = {
    'id': account.index,
    'account': account.address,
    'balance': account.rawBalance,
    'frontier': account.frontier,
    'representative': account.representative,
  };
  await _database.insert(
    'accounts',
    accountObj,
    conflictAlgorithm: ConflictAlgorithm.replace,
  );
}

Future<void> deleteDb() async {
  String path = join(await getDatabasesPath(), 'account_database.db');
  await deleteDatabase(path);
}
