//
//  BlockchainService.swift
//  App
//
//  Created by Magnus Nevstad on 01/04/2019.
//

import Foundation
import BlockchainSwift

class BlockchainService {
    private let wallet: Wallet
    private let blockchain: Blockchain
    
    init() {
        self.wallet = Wallet()!
        self.blockchain = Blockchain(minerAddress: self.wallet.address)
    }
    
    func address() -> Data {
        return wallet.address
    }
    
    func send(recipient: Data, value: UInt64) -> Int {
        do {
            return try blockchain.createTransaction(sender: wallet, recipientAddress: recipient, value: value)
        } catch Blockchain.TxError.insufficientBalance {
            print("Insufficient balance to send \(value) to \(recipient.hex)")
            return -1
        } catch Blockchain.TxError.unverifiedTransaction {
            print("Signing failed when trying to send \(value) to \(recipient.hex)")
            return -1
        } catch {
            return -1
        }
    }
    
    func balance(address: Data) -> UInt64 {
        return blockchain.balance(for: address)
    }
    
    func mine(completion: @escaping (Block) -> ()) {
        DispatchQueue.global(qos: .default).async {
            let lastBlock = self.blockchain.lastBlock()
            completion(self.blockchain.mineBlock(previousHash: lastBlock.hash, minerAddress: self.wallet.address))
        }
    }
    
    func chain() -> Blockchain {
        return blockchain
    }
}
