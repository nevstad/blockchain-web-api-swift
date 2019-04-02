//
//  Crypto.swift
//  App
//
//  Created by Magnus Nevstad on 01/04/2019.
//

import Foundation

enum ProofOfWork {
    static private let difficulty = "000" // The more 0s, the higher the difficulty
    
    /// Simple Proof of Work Algorithm, based on HashCash/Bitcoin
    /// - Parameter prevHash: The previous block's hash
    /// - Returns: A valid SHA-256 hash & nonce after success, invalid SHA-256 hash & nonce if unsuccessful avter Int.max tries
    static func work(prevHash: Data, blockData: BlockData) -> (hash: Data, nonce: Int) {
        var nonce = 0
        var hash = prepareData(prevHash: prevHash, nonce: nonce, blockData: blockData).sha256()
        while nonce < Int.max {
            if validate(hash: hash) {
                break
            }
            nonce += 1
            hash = prepareData(prevHash: prevHash, nonce: nonce, blockData: blockData).sha256()
        }
        return (hash: hash, nonce: nonce)
    }
    
    /// Builds data based on a previousHash, nonce and BlockData to be used for generating hashes
    static private func prepareData(prevHash: Data, nonce: Int, blockData: BlockData) -> Data {
        var data = prevHash
        data.append("\(nonce)\(blockData.index)\(blockData.timestamp)".data(using: .utf8)!)
        data.append(try! JSONEncoder().encode(blockData.transactions))
        return data
    }
    
    /// Validates that a block was mined correctly according to the PoW algorithm
    /// - SHA-256 Hashing this block's data should produce a valid PoW hash
    static func validate(block: Block) -> Bool {
        let previousHash = block.previousHash
        let nonce = block.nonce
        let blockData = block.blockData
        let data = prepareData(prevHash: previousHash, nonce: nonce, blockData: blockData)
        let hash = data.sha256()
        return validate(hash: hash)
    }
    
    /// Validates that a hash has passed the requirement of the correct number of starting 0s
    static func validate(hash: Data) -> Bool {
        return hash.hexDigest().prefix(difficulty.count) == difficulty
    }
}
