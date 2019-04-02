//
//  SHA.swift
//  App
//
//  Created by Magnus Nevstad on 02/04/2019.
//

import Foundation
import CommonCrypto

extension Data {
    /// SHA-256 encodes a hash of `self`
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
