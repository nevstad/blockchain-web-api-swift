//
//  BlockchainController.swift
//  App
//
//  Created by Magnus Nevstad on 01/04/2019.
//

import Vapor
import BlockchainSwift

final class BlockchainController {
    let node: Node
    
    init(node: Node) {
        self.node = node
    }
    
    enum APIError: Error {
        case missingParameter(String)
        case invalidParameter(String)
    }

    func chain(req: Request) -> BlockchainResponse {
        return BlockchainResponse(node.chain())
    }
    
    func send(req: Request, transaction: TransactionRequest) throws -> Int  { // TODO: return TX?
        guard let validAddress = Data(hex: transaction.address) else {
            return -1
        }
        return try node.send(recipientAddress: validAddress, value: transaction.value)
    }
    
    func mempool(req: Request) -> [TxResponse] {
        return node.chain().mempool.map { TxResponse($0) }
    }

    func mine(req: Request) -> Future<BlockResponse> {
        let promise: EventLoopPromise<BlockResponse> = req.eventLoop.newPromise()
        node.mine { block in
            promise.succeed(result: BlockResponse(block))
        }
        return promise.futureResult
    }
    
    func balance(req: Request) throws -> BalanceResponse {
        guard let address = try? req.parameters.next(String.self) else {
            throw APIError.missingParameter("No address parameter specified.")
        }
        guard let validAddress = Data(hex: address) else {
            throw APIError.invalidParameter("Specified address is not valid.")
        }
        return BalanceResponse(address: address, balance: node.balance(address: validAddress))
    }
    
    func wallet(req: Request) -> BalanceResponse {
        let address = node.wallet.address
        let balance = node.balance(address: address)
        return BalanceResponse(address: address.hex, balance: balance)
    }
    
    func network(req: Request) -> [NodeAddress] {
        return node.knownNodes
    }
    
    /// VersionMessage
    func getVersion(req: Request) -> VersionMessage {
        return node.versionMessage
    }
    func postVersion(req: Request, version: VersionMessage) -> Int {
        node.handleVersionMessage(version)
        return 1
    }
}
