//
//  TransactionOutPoint.swift
//  App
//
//  Created by Magnus Nevstad on 06/04/2019.
//

import Vapor

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

