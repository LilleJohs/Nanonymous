# Nanonymous: A privacy-focused Android wallet for the cryptocurrency Nano

This wallet is a proof of concept wallet which shows how one can create a privacy-focused wallet by taking use of the no-fee feature of Nano.

## How Does It Work?

The privacy is constructed by taking use of multiple addresses created by one seed. Every address has a corresponding index which starts at 0. When you first start using the wallet it will only create one address which is shown on the main page. If you send Nano to this address it will then increment the index and create a new address with index 1 and show this on the main page. Thus the address which is shown will always have zero Nano and blocks associated with it. Thus friends can send Nano to you without knowing the balance in your other addresses.

Thus, the amount of Nano this wallet stores can be distributed amongst a big set of addresses. That means that if people send money to your wallet, they will not see how much Nano is in your wallet. Only the amount they sent since every address is ment to only receive one transaction.

When you wanna send Nano to one of your friends, the wallet will take the smallest index that has a non-zero balance and see if there is enough balance in that to send the money. If there is not, it looks at the next index, adds the balance in that address and see if that is enough Nano. It keeps incrementing the index until it has enough addresses with enough balance in total. Then it empties the accounts by making one send block per address. For the last address, it sends the required Nano left over to the receiver, and the rest is sent back to the user by looking at the next index address.

Here is an example: Addresses with index 0-4 has 5 Nano each which totals 25 Nano. You wanna send 12 Nano to your friend with address A. You first send all Nano in address with index 0 to A. Then all Nano in address with index 1 to A. That is a total of 10 Nano. Then you send 2 Nano from address with index 2 to A. Now your friend is happy since he has received all 12 Nano. You have 3 Nano left in address with index 2, and so that is sent to your next address in line which is index 3. So now address with index 3 has a total of 8 Nano.

This makes it much harder for a third-party to track your Nano. You can also receive Nano from people without revealing how much Nano you have. Also, since Nano has no fees making all these transactions do not hurt the user in any way. It requires more from the wallet creators since they have to produce more work, but the users benefit.

Nanonymous is of course not a 100% anonymous, but it certainly makes it much harder for someone else to track your Nano. I hope this proof of concept wallet will convince people that it is possible to create more privacy-focused wallets, and that it will start a discussion in how to most effectively achieve privacy.

## Development

This wallet was developed for Android, but since it is created in Flutter it shouldn't be very hard to port it over to iOS.

At this moment, I do not have enough time to keep this wallet feature-rich and bug free. It is therefore only ment as a proof of concept. If anyone is willing to spend their time helping me further develop this wallet, please reach out! But at this time, I can not maintain this wallet to the standard that cryptoicurrency wallets should meet.