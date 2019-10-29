import 'dart:convert';

import 'package:rxdart/rxdart.dart';

import '../models/account.dart';
import '../models/accountList.dart';
import '../models/transaction.dart';
import '../helper/storage.dart';
import '../bloc/webSocketConnection.dart';

class Wallet {
  // Receive index is the smallest account index that has no open block.
  // If the user receives on this account, the sender will not know the amount of Nano the receiver has.
  // New wallet will have receiveIndex = 0
  int receiveIndex;

  // minimumIndex is the smallest account index where there is any Nano, every payment the user makes will start
  // from this index. minimumIndex will be lower than the reveiveIndex unless the wallet has no open block.
  // The total amount of Nano the wallet has, will be the sum of Nano in the sets of account from indices
  // [minimumIndex, minimumIndex + 1, ..., receiveIndex - 1, receiveIndex].
  // New wallet will have minimumIndex = 0.
  int minimumIndex;

  PublishSubject<Map<String, dynamic>> _wsChannel =
      PublishSubject<Map<String, dynamic>>();
  WebSocketConnection _webSocketConnection;

  // Map instead of list because we might not care about the first account(s)
  // Example: minimumIndex = 50, receiveIndex = 53, then we don't care about index=0, and so a List wouldn't work
  AccountList accounts = AccountList();

  bool hasShownAlert = false;
  BehaviorSubject<String> _alertFromServer = BehaviorSubject<String>();
  BehaviorSubject<String> _receiveAccount = BehaviorSubject<String>();
  BehaviorSubject<BigInt> _balance = BehaviorSubject<BigInt>();
  BehaviorSubject<List<Transaction>> _transactions =
      BehaviorSubject<List<Transaction>>();
  BehaviorSubject<String> _waitForResponse = BehaviorSubject<String>();

  BehaviorSubject<String> get waitForResponse => _waitForResponse;
  BehaviorSubject<String> get alertFromServer => _alertFromServer;
  BehaviorSubject<BigInt> get balance => _balance;
  Observable<String> get receiveAccountStream => _receiveAccount.stream;
  Observable<BigInt> get balanceStream => _balance.stream;
  Observable<List<Transaction>> get transactionsStream => _transactions.stream;

  // Timestamp to make sure the user doesn't spam the server
  int lastAccountUpdate = 0;

  // Temporary minimumIndex which becomes the new minimumIndex if send transaction was success
  int _tempMin;

  Wallet() {
    // Initialize wallet
    startWallet();
  }

  Future<void> startWallet() async {
    int minIndex = await getMinimumIndex();
    int recIndex = await getReceiveIndex();
    // Open or create database for storing accounts
    await getDatabase();
    if (minIndex == -1 || recIndex == -1) {
      //Do initial setup
      receiveIndex = 0;
      minimumIndex = 0;
      await setReceiveIndex(receiveIndex);
      await setMinimumIndex(minimumIndex);
    } else {
      // Get current indices
      minimumIndex = minIndex;
      receiveIndex = recIndex;
    }
    String receiveAddress = await accounts.initFromDb(receiveIndex);
    _wsChannel.stream.listen(readMessageFromWS);
    _webSocketConnection = WebSocketConnection(_wsChannel.sink);

    _receiveAccount.sink.add(receiveAddress);
  }

  readMessageFromWS(Map<String, dynamic> input) {
    // JSON from server which always have a title field
    switch (input['title']) {
      case 'ACCOUNTS_INFO':
        {
          readAccountInfo(input);
        }
        break;
      case 'TX_IS_PROCESSED':
        {
          readTxProcessed(input);
        }
        break;
      case 'MESSAGE_FROM_SERVER':
        {
          // In case there is a critical bug and the user should update.
          _alertFromServer.sink.add(input['message']);
        }
        break;
      case 'FIRST_TIME_CONNECTED':
        {
          // When we first connect with back-end we ask for account info
          getAccountInfo();
        }
        break;
      case 'ERROR_PROCESSING_SEND':
        {
          // Not all blocks were sent. Will give the user an error when sending
          _waitForResponse.sink.add('ERROR_PROCESSING_SEND');
        }
        break;
      default:
        {
          print('Error! The following title can not be processed:');
          print(input);
        }
    }
  }

  void readTxProcessed(dynamic message) async {
    // A transaction has been processed by the server
    // If the block was of type 'receive' then we need to make
    // a new receive account by increasing receiveIndex and get a new
    // pair of private and public keys. This is the address that will be showed
    // as QR code in the left screen in app

    // If type is send, then set minimumIndex to _tempMin. _tempMin was set to minimumIndex+1
    // when the transaction was sent, but if there was an error then it shouldn't be increased
    final String account = message['account'];
    if (message['subtype'] == 'receive') {
      if (accounts.shouldIncrementReceive(account, receiveIndex)) {
        await incrementReceive();
      }
    } else if (message['subtype'] == 'send') {
      if (_tempMin != null && _tempMin != minimumIndex) {
        minimumIndex = _tempMin;
        await setMinimumIndex(minimumIndex);
      }
    }

    getAccountInfo();
  }

  void readAccountInfo(dynamic message) async {
    // A lot of information from the server about balances, transactions
    // are being processed here.
    final jsonData = message['data'];
    final balancesJson = jsonData['balancesInfoData'];
    final historyJson = jsonData['historyData'];
    final pendingJson = jsonData['pendingData'];
    final frontiersJson = jsonData['frontiersData'];

    if (frontiersJson.length != 0) {
      // Set frontiers for all accounts
      for (var account in frontiersJson.entries) {
        accounts.setFrontier(account.key, account.value);
      }
      if (frontiersJson
          .containsKey(accounts.getReceiveIndexAddress(receiveIndex))) {
        // receiveIndex should not have an open block, so we need to increase receiveIndex
        incrementReceive();
      }
    }

    BigInt totalBalance = BigInt.from(0);
    if (balancesJson.length != 0) {
      for (var account in balancesJson.entries) {
        String balanceRaw = account.value['balance'];
        if (accounts.setBalance(account.key, balanceRaw)) {
          // totalBalance is a sum of all balances
          totalBalance += BigInt.parse(balanceRaw);
        }
      }
    }
    _balance.add(totalBalance);

    for (int i = minimumIndex; i <= receiveIndex; i++) {
      BigInt balance = BigInt.parse(accounts.getAccountFromIndex(i).rawBalance);
      if (balance > BigInt.from(1e24)) {
        // 1 Nano = 10^30 raw. THerefore balances less than 10^(-6) Nano is ignored.
        // This is the smallest amount of Nano the wallet will care about
        setMinimumIndex(i);
        break;
      }
      if (i == receiveIndex) {
        // If we get here, then there is no balance in any of the previous accounts and so totalBalance=0
        // and thus we need to set minimumIndex equal to receiveIndex.
        setMinimumIndex(receiveIndex);
      }
    }

    // Do not show internal transactions, namley transactions from one account
    // the wallet controls to another one the wallet also controls.
    List<Transaction> transactionsList = [];
    for (var j = 0; j < historyJson.length; j++) {
      for (var i = 0; i < historyJson[j]['history'].length; i++) {
        final curAcc = historyJson[j]['history'][i];
        final linkAccount = curAcc['account'];
        bool doNotAdd = false;
        if (accounts.getAccount(linkAccount) != null) {
          doNotAdd = true;
        }
        if (!doNotAdd) {
          Transaction curTx = Transaction.fromJson(curAcc);
          transactionsList.add(curTx);
        }
      }
    }
    transactionsList.sort((a, b) => b.timeStamp.compareTo(a.timeStamp));
    _transactions.sink.add(transactionsList);

    for (var accountMap in pendingJson.entries) {
      if (accountMap.value != '') {
        for (var hashMap in accountMap.value.entries) {
          Map<String, String> receiveBlock = await accounts.makeReceiveBlock(
              account: accountMap.key,
              hashAsLink: hashMap.key,
              raw: hashMap.value);
          if (receiveBlock != null) {
            Map<String, String> message = {
              'title': 'PROCESS_RECEIVE_BLOCK',
              'block': json.encode(receiveBlock),
            };
            _webSocketConnection.wsChannel.sink.add(json.encode(message));
            break;
          }
        }
      }
    }

    // To prevent (un)intentional spam. Only ask for update every 1 second
    lastAccountUpdate = DateTime.now().millisecondsSinceEpoch;
    _waitForResponse.sink.add('GETINFO');
  }

  void getAccountInfo() async {
    // Ask for an update on the list of accounts this wallet has. Pending blocks, current balance,
    // list of transactions

    if (!_webSocketConnection.connected) {
      final bool didWeConnect =
          await _webSocketConnection.connectingToWebSocket();
      if (!didWeConnect) {
        _waitForResponse.sink.add('GETINFO');
        return;
      }
    }
    int currentTime = DateTime.now().millisecondsSinceEpoch;
    if ((currentTime - lastAccountUpdate) < 1000) {
      // Don't spam the server! Only one request per second allowed
      _waitForResponse.sink.add('GETINFO');
      lastAccountUpdate = currentTime;
      return;
    }
    lastAccountUpdate = currentTime;

    // Ask the server for the account info of the accounts with
    // indices minimumIndex <= index <= receiveIndex.
    // No other accounts should contain any Nano
    List<List<String>> accs =
        accounts.getAccountsHistoryBalance(minimumIndex, receiveIndex);
    // The accounts with potential balance will also need to have their work precached
    List<String> accountsWithPotentialBalance = accs[0];
    List<String> accountsWithHistoryWeWant = accs[1];

    Map<String, dynamic> message = {
      'title': 'GET_ACCOUNTS_INFO',
      'accounts': accountsWithPotentialBalance,
      'accountsHistory': accountsWithHistoryWeWant,
    };
    _webSocketConnection.wsChannel.sink.add(json.encode(message));
  }

  Future<void> incrementReceive() async {
    // Make new account after receiving new transaction.
    receiveIndex++;
    setReceiveIndex(receiveIndex);
    final Account account = await getAccountByIndex(receiveIndex);
    accounts.setNewAccount(account);
    _receiveAccount.sink.add(account.address);
  }

  void makeSendTransaction(String sendToAccount, String sendNano) async {
    Map<String, dynamic> blocks = await accounts.makeSendTransaction(
      sendToAccount: sendToAccount,
      sendNano: sendNano,
      minimumIndex: minimumIndex,
      receiveIndex: receiveIndex,
    );

    Map<String, String> message = {
      'title': 'PROCESS_SEND_BLOCKS',
      'firstBlocks': json.encode(blocks['allFirstBlocks']),
      'lastFirstBlock': json.encode(blocks['lastFirstBlock']),
      'lastSecondBlock': json.encode(blocks['lastSecondBlock']),
    };
    _tempMin = blocks['newMinimum'];
    _webSocketConnection.wsChannel.sink.add(json.encode(message));
  }

  dispose() {
    _receiveAccount.close();
    _waitForResponse.close();
    _transactions.close();
    _balance.close();
    _alertFromServer.close();
    _wsChannel.close();
  }
}
