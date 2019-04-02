import Vapor

/// Register your application's routes here.
public func routes(_ router: Router) throws {
    let blockchainController = BlockchainController()

    router.group("api", "v1") { group in
        group.get("blockchain", use: blockchainController.chain)
        group.get("balance", String.parameter, use: blockchainController.balance)
        group.get("mine", String.parameter, use: blockchainController.mine)
        group.post(Transaction.self, at: "send", use: blockchainController.send)
    }
}
