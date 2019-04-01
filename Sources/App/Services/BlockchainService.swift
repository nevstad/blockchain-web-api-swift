//
//  BlockchainService.swift
//  App
//
//  Created by Magnus Nevstad on 01/04/2019.
//

import Foundation

class BlockchainService {
    private let blockchain = Blockchain()
    
    func send(sender: String, recipient: String, value: Double) -> Int {
        return blockchain.createTransaction(sender: sender, recipient: recipient, value: value)
    }
    
    func balance(address: String) -> Double {
        return blockchain.balance(for: address)
    }
    
    func mine(recipient: String, completion: @escaping (Block) -> ()) {
        DispatchQueue.global(qos: .default).async {
            let lastBlock = self.blockchain.lastBlock()
            let proof = ProofOfWork.calculateNextProof(lastProof: lastBlock.proof)
            self.blockchain.createTransaction(sender: Blockchain.blockRewardPoolAddress, recipient: recipient, value: Blockchain.blockReward)
            let block = self.blockchain.createBlock(proof: proof)
            completion(block)
        }
    }
    
    func chain() -> Blockchain {
        return blockchain
    }
}
