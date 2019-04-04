//
//  BlockchainService.swift
//  App
//
//  Created by Magnus Nevstad on 01/04/2019.
//

import Foundation

class BlockchainService {
    private let blockchain = Blockchain()
    
//    func send(sender: String, recipient: String, value: UInt64, data: Data?) -> Int {
//        return blockchain.createTransaction(sender: sender, recipient: recipient, value: value, data: data)
//    }
    
    func balance(address: String) -> UInt64 {
        return blockchain.balance(for: address)
    }
    
    func mine(recipient: String, completion: @escaping (Block) -> ()) {
        DispatchQueue.global(qos: .default).async {
            let lastBlock = self.blockchain.lastBlock()
            completion(self.blockchain.mineBlock(previousHash: lastBlock.hash, recipient: recipient))
        }
    }
    
    func chain() -> Blockchain {
        return blockchain
    }
}
