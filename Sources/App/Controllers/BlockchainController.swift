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
    
    struct TransactionRequest: Content {
        let address: String
        let value: UInt64
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
    
    func send(req: Request, transactions: [TransactionRequest]) -> [Int] {
        return transactions.map { transaction in
            guard let validAddress = Data(hex: transaction.address) else {
                return -1
            }
            return service.send(recipient: validAddress, value: transaction.value)
        }
    }
    
    func mempool(req: Request) -> [Transaction] {
        return service.chain().mempool
    }

    func balance(req: Request) -> BalanceResponse {
        guard let address = try? req.parameters.next(String.self), let validAddress = Data(hex: address) else {
            return BalanceResponse.invalid()
        }
        return BalanceResponse(address: address, balance: service.balance(address: validAddress))
    }
    
    func mine(req: Request) -> Future<Block> {
        let promise: EventLoopPromise<Block> = req.eventLoop.newPromise()
        service.mine(completion: promise.succeed)
        return promise.futureResult
    }
    
    func wallet(req: Request) -> BalanceResponse {
        let address = service.address()
        return BalanceResponse(address: address.hex, balance: service.balance(address: address))
    }
}
