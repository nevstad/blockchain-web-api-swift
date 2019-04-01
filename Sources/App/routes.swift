import Vapor

/// Register your application's routes here.
public func routes(_ router: Router) throws {
    let blockchainController = BlockchainController()

    router.get("api", "blockchain", use: blockchainController.chain)
    router.get("api", "mine", String.parameter, use: blockchainController.mine)
    router.post(Transaction.self, at: "api", "send", use: blockchainController.send)
    router.get("api", "balance", String.parameter, use: blockchainController.balance)
}
