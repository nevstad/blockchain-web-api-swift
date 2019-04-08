# ⛓ BlockchainSwift, running on Vapor.

A web API implentation of [BlockchainSwift](https://github.com/nevstad/BlockchainSwift) running on [Vapor](https://github.com/vapor/vapor).

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

## 🤞🏻 Testing

To run the tests, make sure the `.swift` files found in `Sources/App/Model` are added to the `AppTests` target.