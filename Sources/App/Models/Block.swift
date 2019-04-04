//
//  Block.swift
//  App
//
//  Created by Magnus Nevstad on 01/04/2019.
//

import Vapor

struct Block: Serializable, Content {
    /// The timestamp for when the block was generated and added to the chain
    let timestamp: UInt32
    
    /// The transactions on this block
    let transactions: [Transaction]
    
    /// The proof used to solve the Proof of Work for this block
    let nonce: UInt32
    
    /// The hash of this block on the chain, becomes `previousHash` for the next block.
    /// THe hash is a SHA256 generated hash bashed on all other instance variables.
    let hash: Data
    
    /// The hash of the previous block
    let previousHash: Data
    
    func serialized() -> Data {
        var data = Data()
        data += previousHash
        data += timestamp
        data += nonce
        data += transactions.flatMap { $0.serialized() }
        return data
    }
}
