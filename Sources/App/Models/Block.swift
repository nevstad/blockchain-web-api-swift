//
//  Block.swift
//  App
//
//  Created by Magnus Nevstad on 01/04/2019.
//

import Vapor

final class Block: Content {
    /// The index of this block in the chain
    let index: Int
    
    /// The timestamp for when the block was generated and added to the chain
    let timestamp: Double
    
    /// The transactions on this block
    let transactions: [Transaction]
    
    /// The proof used to solve the Proof of Work for this block
    let proof: Int
    
    /// The hash of this block on the chain, becomes `previousHash` for the next block.
    /// THe hash is a SHA256 generated hash bashed on all other instance variables.
    let hash: Data
    
    /// The hash of the previous block
    let previousHash: Data
    
    init(index: Int, timestamp: Double, transactions: [Transaction], proof: Int, previousHash: Data) {
        self.index = index
        self.timestamp = timestamp
        self.transactions = transactions
        self.proof = proof
        self.previousHash = previousHash
        let transactionsJSON = String(describing: String(data: try! JSONEncoder().encode(transactions), encoding: .utf8))
        self.hash = "\(index)\(timestamp)\(transactionsJSON)\(proof)\(previousHash)".data(using: .utf8)!.sha256()
    }
}
