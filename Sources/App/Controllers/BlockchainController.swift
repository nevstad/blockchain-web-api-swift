//
//  BlockchainController.swift
//  App
//
//  Created by Magnus Nevstad on 01/04/2019.
//

import Vapor

final class BlockchainController {
    let service = BlockchainService()
    
    enum APIError: Error {
        case missingParameter(String)
    }
    
    struct BalanceResponse: Content {
        let address: String
        let balance: UInt64
        static func invalid() -> BalanceResponse {
            return BalanceResponse(address: "Invalid", balance: 0)
        }
    }
    
    func chain(req: Request) -> Blockchain {
        return service.chain()
    }
    
//    func send(req: Request, transaction: Transaction) -> Int {
//        return service.send(sender: transaction.sender, recipient: transaction.recipient, value: transaction.value, data: transaction.data)
//    }

//    func send(req: Request, transactions: [Transaction]) -> [Int] {
//        return transactions.map { transaction in
//            service.send(sender: transaction.sender, recipient: transaction.recipient, value: transaction.value, data: transaction.data) }
//    }

    
    func mempool(req: Request) -> TransactionPool {
        return service.chain().mempool
    }

    func balance(req: Request) -> BalanceResponse {
        guard let address = try? req.parameters.next(String.self) else {
            return BalanceResponse.invalid()
        }
        return BalanceResponse(address: address, balance: service.balance(address: address))
    }
    
    func mine(req: Request) -> Future<Block> {
        let promise: EventLoopPromise<Block> = req.eventLoop.newPromise()
        guard let recipient = try? req.parameters.next(String.self) else {
            promise.fail(error: APIError.missingParameter("recipient"))
            return promise.futureResult
        }
        service.mine(recipient: recipient, completion: promise.succeed)
        return promise.futureResult
    }
}
