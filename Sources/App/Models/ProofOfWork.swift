//
//  Crypto.swift
//  App
//
//  Created by Magnus Nevstad on 01/04/2019.
//

import Foundation
import CommonCrypto

enum ProofOfWork {
    static private let difficulty = "0000" // The more 0s, the higher the difficulty
    
    /// Simple Proof of Work Algorithm:
    /// - Find a number p' such that hash(pp') contains leading 4 zeroes, where p is the previous p'
    /// - p is the previous proof, and p' is the new proof
    /// - Parameter prevHash: The previous block's hash
    /// - Returns: The new hash and nonce ater successful pow
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
    
    /// Validates that a block was indeed mined correctly according to POW
    static func validate(block: Block) -> Bool {
        let blockData = block.blockData
        let previousHash = block.previousHash
        let nonce = block.nonce
        let hash = prepareData(prevHash: previousHash, nonce: nonce, blockData: blockData)
        return validate(hash: hash)
    }
    
    /// Validates that a hash has passed the requirement of the correct number of starting 0s
    static func validate(hash: Data) -> Bool {
        return hash.hexDigest().prefix(difficulty.count) == difficulty
    }
}

extension Data {
    /// SHA256 encodes a hash of `self`
    func sha256() -> Data {
        var digest = Data(count: Int(CC_SHA256_DIGEST_LENGTH))
        _ = digest.withUnsafeMutableBytes { (digestBytes) in
            withUnsafeBytes { (stringBytes) in
                CC_SHA256(stringBytes, CC_LONG(count), digestBytes)
            }
        }
        return digest
    }
    
    /// Return a hex digest of `self`
    func hexDigest() -> String {
        return self.map({ String(format: "%02x", $0) }).joined()
    }
}
