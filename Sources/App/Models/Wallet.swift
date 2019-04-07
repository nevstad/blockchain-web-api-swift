//
//  Wallet.swift
//  App
//
//  Created by Magnus Nevstad on 03/04/2019.
//

import Foundation


final class Wallet {
    /// Key pair
    private let secPrivateKey: SecKey
    private let secPublicKey: SecKey
    
    /// Public Key represented as data
    let publicKey: Data
    
    /// This wallet's address in readable format, double SHA256 hash'ed
    var address: Data
    
    init?() {
        if let keyPair = ECDSA.generateKeyPair(), let publicKeyCopy = ECDSA.copyExternalRepresentation(key: keyPair.publicKey) {
            self.secPrivateKey = keyPair.privateKey
            self.secPublicKey = keyPair.publicKey
            self.publicKey = publicKeyCopy
            self.address = self.publicKey.sha256().sha256()
        } else {
            return nil
        }
    }

    /// Signs a Transaction
    /// - Unspent transaction outputs (txos) represent spendable coins
    func sign(utxos: [TransactionOutput]) throws -> [TransactionInput] {
        // Define Transaction
        var signedInputs = [TransactionInput]()
        for (i, utxo) in utxos.enumerated() {
            // Sign transaction hash
            var error: Unmanaged<CFError>?
            let txOutputDataHash = utxo.serialized().sha256()
            guard let signature = SecKeyCreateSignature(self.secPrivateKey,
                                                        .ecdsaSignatureDigestX962SHA256,
                                                        txOutputDataHash as CFData,
                                                        &error) as Data? else {
                                                            throw error!.takeRetainedValue() as Error
            }
            // Update TransactionInput
            let prevOut = TransactionOutPoint(hash: txOutputDataHash, index: UInt32(i))
            let signedTxIn = TransactionInput(previousOutput: prevOut, publicKey: self.publicKey, signature: signature)
            signedInputs.append(signedTxIn)
        }
        return signedInputs
    }

    func sign(utxo: TransactionOutput) throws -> Data {
        // Sign transaction hash
        var error: Unmanaged<CFError>?
        let txOutputDataHash = utxo.serialized().sha256()
        guard let signature = SecKeyCreateSignature(self.secPrivateKey,
                                                    .ecdsaSignatureDigestX962SHA256,
                                                    txOutputDataHash as CFData,
                                                    &error) as Data? else {
                                                        throw error!.takeRetainedValue() as Error
        }
        return signature
    }

    
    func canUnlock(utxo: TransactionOutput) -> Bool {
        return utxo.address == self.address
    }

    func canUnlock(utxos: [TransactionOutput]) -> Bool {
        for utxo in utxos {
            if !canUnlock(utxo: utxo) {
                return false
            }
        }
        return true
    }
}
