//
//  Block.swift
//  App
//
//  Created by Magnus Nevstad on 01/04/2019.
//

import Vapor

typealias BlockData = (index: Int, timestamp: Double, transactions: [Transaction])

final class Block: Content {
    /// The index of this block in the chain
    let index: Int
    
    /// The timestamp for when the block was generated and added to the chain
    let timestamp: Double
    
    /// The transactions on this block
    let transactions: [Transaction]
    
    /// The proof used to solve the Proof of Work for this block
    let nonce: Int
    
    /// The hash of this block on the chain, becomes `previousHash` for the next block.
    /// THe hash is a SHA256 generated hash bashed on all other instance variables.
    let hash: Data
    
    /// The hash of the previous block
    let previousHash: Data
    
    /// Convenience getter for data fields used in Proof of Work
    var blockData: BlockData {
        get {
            return (index: index, timestamp: timestamp, transactions: transactions)
        }
    }
    
    init(index: Int, timestamp: Double, transactions: [Transaction], nonce: Int, hash: Data, previousHash: Data) {
        self.index = index
        self.timestamp = timestamp
        self.transactions = transactions
        self.nonce = nonce
        self.hash = hash
        self.previousHash = previousHash
    }
}
