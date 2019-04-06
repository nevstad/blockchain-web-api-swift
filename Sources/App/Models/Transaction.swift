//
//  Transaction.swift
//  App
//
//  Created by Magnus Nevstad on 01/04/2019.
//

import Vapor
import Crypto


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
    
    static func coinbase(address: Data, blockValue: UInt64) -> Transaction {
        let coinbaseTxOutPoint = TransactionOutPoint(hash: Data(), index: 0)
        let coinbaseTxIn = TransactionInput(previousOutput: coinbaseTxOutPoint, publicKey: address, signature: Data())
        let txIns:[TransactionInput] = [coinbaseTxIn]
        let txOuts:[TransactionOutput] = [TransactionOutput(value: blockValue, address: address)]
        return Transaction(inputs: txIns, outputs: txOuts)
    }
}
