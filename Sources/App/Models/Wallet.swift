//
//  Wallet.swift
//  App
//
//  Created by Magnus Nevstad on 03/04/2019.
//

import Foundation
import CommonCrypto
import Vapor

final class Wallet {
    let privateKey: Data
    let publicKey: Data
    let address: String
    
    init?() {
        let query: [String: Any] = [
            kSecAttrKeyType as String: kSecAttrKeyTypeECSECPrimeRandom,
            kSecAttrKeySizeInBits as String: 256 as AnyObject
        ]
        var privateKey: SecKey?
        var publicKey: SecKey?
        let status = SecKeyGeneratePair(query as CFDictionary, &publicKey, &privateKey)
        
        guard status == errSecSuccess else {
            print("Could not generate keypair")
            return nil
        }
        
        guard let pubKey = publicKey, let privKey = privateKey else {
            print("Keypair null")
            return nil
        }
        
        var error: Unmanaged<CFError>?
        guard
            let pubKeyData = SecKeyCopyExternalRepresentation(pubKey, &error) as Data?,
            let privKeyData = SecKeyCopyExternalRepresentation(privKey, &error) as Data?
            else {
                print("Could not copy keys to Data")
                return nil
        }
        
        self.privateKey = privKeyData
        self.publicKey = pubKeyData
        self.address = pubKeyData.sha256().hexDigest()
    }
}
