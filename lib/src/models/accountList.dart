import 'dart:math';

import './account.dart';
import '../helper/storage.dart';
import '../helper/nanoHelper.dart';

class AccountList {
  Map<int, Account> _accounts = {};
  Map<int, Account> get getAccounts => _accounts;

  AccountList();
  AccountList.setAccounts(Map<int, Account> accounts) {
    _accounts = accounts;
  }

  Future<String> initFromDb(int receiveIndex) async {
    // returns receiveIndex address

    final tick = DateTime.now().millisecondsSinceEpoch;
    final int startIndex = (receiveIndex >= 51) ? receiveIndex - 50 : 0;
    Map<int, Account> accountList =
        await getAccountByIndexList(startIndex, receiveIndex);
    accountList.forEach((index, account) {
      _accounts[index] = account;
    });
    final tock = DateTime.now().millisecondsSinceEpoch;
    print('Time to get accounts from db: ${(tock - tick) / 1000} second');
    return _accounts[receiveIndex].address;
  }

  List<List<String>> getAccountsHistoryBalance(minimumIndex, receiveIndex) {
    // We want to know the history of every account and balance of every account with index i such that
    // minimumIndex<= i <= receiveIndex
    List<String> accountsWithBalance = [];
    List<String> accountsWithHistory = [];
    for (int index in _accounts.keys) {
      final String address = _accounts[index].address;
      if (index >= minimumIndex && index <= receiveIndex) {
        accountsWithBalance.add(address);
      }
      accountsWithHistory.add(address);
    }
    return [accountsWithBalance, accountsWithHistory];
  }

  bool shouldIncrementReceive(String account, int receiveIndex) {
    return (account == _accounts[receiveIndex].address);
  }

  Account getAccount(String address) {
    for (int index in _accounts.keys) {
      if (_accounts[index].address == address) {
        return _accounts[index];
      }
    }
    return null;
  }

  Account getAccountFromIndex(int index) {
    return _accounts[index];
  }

  int newMinimumIndex(accountProcessed, oldMinimumIndex) {
    int minimumIndex = oldMinimumIndex;
    Account accProcessed = getAccount(accountProcessed);
    int indexProcessed = accProcessed.index;
    String minAddress = _accounts[minimumIndex].address;
    if (minAddress == accountProcessed) {
      if (indexProcessed > oldMinimumIndex) {
        print('Setting new minimumIndex to $indexProcessed');
        print('Minimum address is $minAddress');
        minimumIndex = indexProcessed;
      } else if (indexProcessed == minimumIndex) {
        // If they are equal, there were no change transaction so the account sent from the server is one less
        // than what it should be (since the server is not aware of what the next account in line is)
        minimumIndex = indexProcessed + 1;
      } else {
        print('ERROR THE NEW MINIMUMINDEX IS LESS THAN TO OLD');
        print(
            'New minimumIndex: $indexProcessed Old minimumIndex: $minimumIndex');
      }
    }
    return minimumIndex;
  }

  void setFrontier(String account, String frontier) {
    for (int index in _accounts.keys) {
      Account acc = _accounts[index];
      if (acc.address == account) {
        acc.frontier = frontier;
        break;
      }
    }
  }

  String getReceiveIndexAddress(receiveIndex) {
    return _accounts[receiveIndex].address;
  }

  bool setBalance(String account, String balanceRaw) {
    Account acc = this.getAccount(account);
    if (acc != null) {
      acc.rawBalance = balanceRaw;
      return true;
    } else {
      return false;
    }
  }

  Future<Map<String, String>> makeReceiveBlock(
      {String account, String hashAsLink, String raw}) async {
    Account acc = this.getAccount(account);
    if (acc != null) {
      Map<String, String> receiveBlock = await acc.makeReceiveBlock(
        hashAsLink: hashAsLink,
        raw: raw,
      );
      return receiveBlock;
    } else {
      return null;
    }
  }

  void setNewAccount(Account account) {
    _accounts[account.index] = account;
  }

  Future<Map<String, dynamic>> makeSendTransaction(
      {String sendToAccount,
      String sendNano,
      int minimumIndex,
      int receiveIndex}) async {
    // Send transactions are at least two blocks. At least one to the receiver, and always only one to
    // the account with index = minimumIndex + 1 if the account at
    // index (i) =  minimumIndex (mI) has enough Nano.
    // If account i=mI doesnt have enough, we send everything from i=mI to
    // the receiver and check if the next account has enough (i=mI+1) and we keep
    // going until we have sent enough money. This function should not have been called
    // if the wallet didn't have enough Nano in all accounts combined.

    // 1. First we need to check how many accounts are needed to send the funds, starting
    // from i=mI and incrementing by one for each account.
    // 2. Then we make all the send blocks we have to make to the receiver, and send the left overs (if any)
    // to the account with the highest index that did not send any funds. The blocks has to be shuffled so
    // that one does not know which acocunt the sender has.
    // 3. Make receive block if there were any left over Nano.

    final BigInt sendRaw = NanoHelper.nanoToRaw(sendNano);
    BigInt currentBalance = BigInt.from(0);
    int allAccountsUpToThisIndex = minimumIndex;
    List<Map<String, String>> allFirstBlocks = [];
    Map<String, String> lastFirstBlock;
    Map<String, String> lastSecondBlock;

    // receiveIndex account shouldn't contain any Nano
    while (allAccountsUpToThisIndex < receiveIndex) {
      final curSendAccount = getAccountFromIndex(allAccountsUpToThisIndex);
      BigInt balanceInThisAccount = curSendAccount.getBigIntRawBalance();
      if (balanceInThisAccount == BigInt.from(0)) {
        print('Empty account. Continue');
        allAccountsUpToThisIndex++;
        continue;
      }

      final BigInt tempBalance = currentBalance + balanceInThisAccount;
      if (sendRaw > tempBalance) {
        // Not enough Nano yet, send all Nano in this account and try next account if next account exists
        if (allAccountsUpToThisIndex == receiveIndex - 1) {
          // Error! We don't have enough Nano
          print(
              'Trying to send Nano, but there does not seem to be enough Nano available');
          assert(false, "Trying to send more Nano than we have");
          break;
        } else {
          // We have enough Nano, so make a send block which sends everything, hence newBalance: 0 below.
          // newPreviousHash: '' means that the previous field should be the frontier received form the server
          final sendBlock = await curSendAccount.makeSendBlock(
            sendToAccount: sendToAccount,
            newBalance: '0',
            newPreviousHash: '',
          );
          allFirstBlocks.add(sendBlock);
          allAccountsUpToThisIndex++;
        }
        currentBalance = tempBalance;
      } else {
        // Last account which all accounts combined have enough Nano
        final BigInt amountToSendFromThisAccount = sendRaw - currentBalance;
        final String balanceAfterOneSend =
            (BigInt.parse(curSendAccount.rawBalance) -
                    amountToSendFromThisAccount)
                .toString();

        if (balanceAfterOneSend == '0') {
          // We only have enough to make one send block, so we send everything
          final lastSendBlock = await curSendAccount.makeSendBlock(
            sendToAccount: sendToAccount,
            newBalance: '0',
            newPreviousHash: '',
          );
          allFirstBlocks.add(lastSendBlock);
        } else {
          final rng = new Random();
          final int randomInt = rng.nextInt(2);
          // Leftover are sent to this account
          final Account receiveNewAccount =
              getAccountFromIndex(allAccountsUpToThisIndex + 1);
          // We have leftover Nano, so we make one send block to receiver and one send block to out wallet
          // but next address in line (index+1). The order of the two blocks is random
          if (randomInt == 1) {
            print('Last block is to ourself');
            // In this case we make send block to receiver first and the second block to ourself
            final lastSendBlockToReceiver = await curSendAccount.makeSendBlock(
              sendToAccount: sendToAccount,
              newBalance: balanceAfterOneSend,
              newPreviousHash: '',
            );
            allFirstBlocks.add(lastSendBlockToReceiver);

            // Use the hash of last block as previous
            String newPreviousHash = lastSendBlockToReceiver['hash'];
            final sendBlockToOurself = await curSendAccount.makeSendBlock(
              sendToAccount: receiveNewAccount.address,
              newBalance: '0',
              newPreviousHash: newPreviousHash,
            );

            // We also make the open block for senderBlock which is where the leftover Nano are sent
            final receiveChangeBlock = await receiveNewAccount.makeReceiveBlock(
              hashAsLink: sendBlockToOurself['hash'],
              raw: balanceAfterOneSend,
            );
            lastFirstBlock = sendBlockToOurself;
            lastSecondBlock = receiveChangeBlock;
          } else {
            print('Last block is to receiver');
            // In this case we send the leftover to ourself first, and then the rest to receiver
            final sendBlockToOurself = await curSendAccount.makeSendBlock(
              sendToAccount: receiveNewAccount.address,
              newBalance: sendRaw.toString(),
              newPreviousHash: '',
            );
            allFirstBlocks.add(sendBlockToOurself);
            String newPreviousHash = sendBlockToOurself['hash'];

            final sendBlockToReceiver = await curSendAccount.makeSendBlock(
              sendToAccount: sendToAccount,
              newBalance: '0',
              newPreviousHash: newPreviousHash,
            );
            final String rawReceive =
                (balanceInThisAccount - sendRaw).toString();
            final receiveChangeBlock = await receiveNewAccount.makeReceiveBlock(
              hashAsLink: sendBlockToOurself['hash'],
              raw: rawReceive,
            );

            lastFirstBlock = sendBlockToReceiver;
            lastSecondBlock = receiveChangeBlock;
          }
        }
        break;
      }
    }

    Map<String, dynamic> blocks = {
      'allFirstBlocks': allFirstBlocks,
      'lastFirstBlock': lastFirstBlock,
      'lastSecondBlock': lastSecondBlock,
      'newMinimum': allAccountsUpToThisIndex + 1,
    };
    return blocks;
  }
}
