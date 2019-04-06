//
//  TransactionInput.swift
//  App
//
//  Created by Magnus Nevstad on 06/04/2019.
//

import Vapor

/// Inputs to a transaction
struct TransactionInput: Serializable, Content {
    // A reference to the previous Transaction output
    let previousOutput: TransactionOutPoint
    
    /// The raw public key
    let publicKey: Data
    
    /// Computational Script for confirming transaction authorization, usually the sender address/pubkey
    let signature: Data
    
    /// Coinbase transactions have no inputs, and are typically used for block rewards
    var isCoinbase: Bool {
        get {
            return previousOutput.hash == Data()
        }
    }
    
    func serialized() -> Data {
        var data = Data()
        data += previousOutput.serialized()
        data += signature
        return data
    }
}
