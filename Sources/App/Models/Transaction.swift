//
//  Transaction.swift
//  App
//
//  Created by Magnus Nevstad on 01/04/2019.
//

import Vapor
import Crypto


/// The out-point of a transaction, referened in TransactionInput
struct TransactionOutPoint: Serializable, Content {
    /// The hash of the referenced transaction
    let hash: Data
    
    /// Index of the specified output in the transaction
    let index: UInt32
    
    func serialized() -> Data {
        var data = Data()
        data += hash
        data += index
        return data
    }
}

/// Inputs to a transaction
struct TransactionInput: Serializable, Content {
    // A reference to the previous Transaction output
    let previousOutput: TransactionOutPoint
    
    /// Computational Script for confirming transaction authorization, usually the sender address/pubkey
    let signatureScript: String
    
    /// Transaction version as defined by the sender, allows for modifying transaction before it's added to a block
    let sequence: UInt32
    
    /// Coinbase transactions have no inputs, and are typically used for block rewards
    var isCoinbase: Bool {
        get {
            return previousOutput.hash == Data()
        }
    }
    
    func serialized() -> Data {
        var data = Data()
        data += previousOutput.serialized()
        data += signatureScript
        data += sequence
        return data
    }
}

struct TransactionOutput: Serializable, Content {
    /// Transaction value
    let value: UInt64
    
    // Usually contains the public key of the receiver, for claiming output
    let lockingScript: String
    
    func serialized() -> Data {
        var data = Data()
        data += value
        data += lockingScript.data(using: .utf8)!
        return data
    }
}

struct Transaction: Serializable, Content {
    /// Transaction inputs, which are sources for coins
    let inputs: [TransactionInput]
    
    /// Transaction outputs, which are destinations for coins
    let outputs: [TransactionOutput]
    
    /// Transaction hash
    var txHash: Data {
        get {
            return self.serialized().sha256()
        }
    }
    
    /// Transaction ID
    var txId: String {
        return Data(txHash.reversed()).hex
    }
    
    /// Coinbase transactions have only one TransactionInput which itself has no previus output reference
    var isCoinbase: Bool {
        get {
            return inputs.count == 1 && inputs[0].isCoinbase
        }
    }
    
    func serialized() -> Data {
        var data = Data()
        data += inputs.flatMap { $0.serialized() }
        data += outputs.flatMap { $0.serialized() }
        return data
    }
}
