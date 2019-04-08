//
//  BlockchainController.swift
//  App
//
//  Created by Magnus Nevstad on 01/04/2019.
//

import Vapor
import BlockchainSwift

final class BlockchainController {
    let service = BlockchainService()
    
    enum APIError: Error {
        case missingParameter(String)
        case invalidParameter(String)
    }


    
    
    func chain(req: Request) -> BlockchainResponse {
        return BlockchainResponse(service.chain())
    }
    
    func send(req: Request, transactions: [TransactionRequest]) -> [Int] {
        return transactions.map { transaction in
            guard let validAddress = Data(hex: transaction.address) else {
                return -1
            }
            return service.send(recipient: validAddress, value: transaction.value)
        }
    }
    
    func mempool(req: Request) -> [TxResponse] {
        return service.chain().mempool.map { TxResponse($0) }
    }

    func mine(req: Request) -> Future<BlockResponse> {
        let promise: EventLoopPromise<BlockResponse> = req.eventLoop.newPromise()
        service.mine { block in
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
        return BalanceResponse(address: address, balance: service.balance(address: validAddress))
    }
    
    func wallet(req: Request) -> BalanceResponse {
        let address = service.address()
        let balance = service.balance(address: address)
        return BalanceResponse(address: address.hex, balance: balance)
    }
}
