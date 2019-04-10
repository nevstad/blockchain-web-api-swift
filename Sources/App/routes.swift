import Vapor

extension CommandLine {
    static func getHostPortArgs() -> (host: String, port: UInt32) {
        var port: UInt32 = 8080
        if let portArgIndex = CommandLine.arguments.firstIndex(where: { $0 == "--port" }), let portArg = UInt32(CommandLine.arguments[portArgIndex + 1]) {
            port = portArg
        }
        var host = "localhost"
        if let hostArgIndex = CommandLine.arguments.firstIndex(where: { $0 == "--host" }) {
            host = CommandLine.arguments[hostArgIndex + 1]
        }
        return (host: host, port: port)
    }
}

/// Register your application's routes here.
public func routes(_ router: Router) throws {
    let args = CommandLine.getHostPortArgs()
    let node = Node(address: NodeAddress(host: args.host, port: args.port))
    let blockchainController = BlockchainController(node: node)

    router.group("api", "v1") { group in
        // General blockchain info
        group.get("blockchain", use: blockchainController.chain)
        group.get("mempool", use: blockchainController.mempool)
        group.get("balance", String.parameter, use: blockchainController.balance)
        group.get("wallet", use: blockchainController.wallet)
        group.get("net", use: blockchainController.network)

        // Node network messaging
        group.post(VersionMessage.self, at: "version", use: blockchainController.postVersion)
        group.get("version", use: blockchainController.getVersion)
        
        // TODO: Remove this, and place mining in Node to mine when tx pool reaches a certain limit
        group.get("mine", use: blockchainController.mine)
        
        // TODO: Write separate wallet apps for macOS/iOS for sending transactions and viewing balance etc.
        group.post(TransactionRequest.self, at: "send", use: blockchainController.send)
    }
}
