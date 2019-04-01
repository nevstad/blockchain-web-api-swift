//
//  Crypto.swift
//  App
//
//  Created by Magnus Nevstad on 01/04/2019.
//

import Foundation
import CommonCrypto

enum ProofOfWork {
    static let difficulty = "0000" // The more 0s, the higher the difficulty
    
    /// Simple Proof of Work Algorithm:
    /// - Find a number p' such that hash(pp') contains leading 4 zeroes, where p is the previous p'
    /// - p is the previous proof, and p' is the new proof
    /// - Parameter lastProff: The last proof used successfully
    /// - Returns: The calculated proof value that led to a correct hash
    static func calculateNextProof(lastProof: Int) -> Int {
        var proof = 0
        while !validProof(lastProof: lastProof, proof: proof) {
            proof += 1
        }
        return proof
    }
    
    /// Validates the Proof
    /// - Parameters:
    ///     - lastProof: The last successful proof
    ///     - proof: The currently attempted proof
    /// - Returns: `true` if hash(last_proof, proof) contain 4 leading zeroes
    static func validProof(lastProof: Int, proof: Int) -> Bool {
        guard let base = String("\(lastProof)\(proof)").data(using: .utf8) else {
            fatalError()
        }
        let guess_hash = base.sha256().hexDigest()
        return guess_hash.prefix(difficulty.count) == difficulty
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
