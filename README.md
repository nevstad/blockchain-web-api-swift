# ⛓ A simple Blockchain implementation for macOS, written in Swift, running on Vapor.

A Blockchain that loosely mimics Bitcoin's key features:

## ✅ Features

* 🎭 Secure and anonymous Wallets
* 🔐 Verified Transations
* 🛠 A Proof-of-Work system


## ⛔️ Missing features: 

* 🗄 Persitent block store
* 🌐 Decentralization

## 🤖 Building
Don't use `vapor xcode` as this sets the `macOS` target to `10.10` and we need `10.12` for ECDSA. Instead use the specified `Package.xcconfig` and run:

`swift package generate-xcodeproj --xcconfig-overrides Package.xcconfig`

## 🚀 Running

Ensure you have selected the `Run` target, and run from XCode. The server runs by default on port `8080`.

Once running, the API has the following endpoints:

* `GET /api/v1/blockchain` - Returns the entire Blockchain
* `GET /api/v1/wallet` - Returns your wallet 
* `GET /api/v1/balance/{address}` - Returns the balance for the specified Wallet address
* `POST /api/v1/send` - Creates a transaction on the blockchain taking a `TransactionRequest` encoded as JSON/application in the `body`
* `GET /api/v1/mine` - Mines the next block, adding all verified transactions in the mempool

A great tool for interacting with APIs is [Postman](https://www.getpostman.com/), and once you have it installed you can easily import `Blockchain.postman_collection.json` and get started.

### 📣 Shoutout
Big thanks for inspiration and learning from [Ivan Kuznetsov's Building Blockchain in Go](https://github.com/Jeiwan/blockchain_go/tree/part_4) and [BitcoinKit](https://github.com/yenom/BitcoinKit).
