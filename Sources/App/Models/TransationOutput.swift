//
//  TransationOutput.swift
//  App
//
//  Created by Magnus Nevstad on 06/04/2019.
//

import Vapor


struct TransactionOutput: Serializable, Content {
    /// Transaction value
    let value: UInt64
    
    // The public key hash of the receiver, for claiming output
    let address: Data
    
    func serialized() -> Data {
        var data = Data()
        data += value
        data += address
        return data
    }
    
    var hash: Data {
        return serialized().sha256()
    }
}
