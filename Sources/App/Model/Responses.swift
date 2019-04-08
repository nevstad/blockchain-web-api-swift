//
//  Responses.swift
//  App
//
//  Created by Magnus Nevstad on 08/04/2019.
//

import Vapor
import BlockchainSwift

struct BalanceResponse: Content {
    let address: String
    let balance: UInt64
    static func invalid() -> BalanceResponse {
        return BalanceResponse(address: "Invalid", balance: 0)
    }
}

struct TxResponse: Content {
    struct TxInput: Content {
        let referencedOutputTxHash: Data
        let publicKey: Data
        let signature: Data
        init(_ txIn: TransactionInput) {
            self.referencedOutputTxHash = txIn.previousOutput.hash
            self.publicKey = txIn.publicKey
            self.signature = txIn.signature
        }
    }
    struct TxOutput: Content {
        let value: UInt64
        let address: Data
        init(_ txOut: TransactionOutput) {
            self.value = txOut.value
            self.address = txOut.address
        }
    }
    
    let txInputs: [TxInput]
    let txOutputs: [TxOutput]
    
    init(_ tx: Transaction) {
        self.txInputs = tx.inputs.map { TxInput($0) }
        self.txOutputs = tx.outputs.map { TxOutput($0) }
    }
}

struct BlockResponse: Content {
    let timestamp: UInt32
    let transactions: [TxResponse]
    let nonce: UInt32
    let hash: Data
    let previousHash: Data
    init(_ block: Block) {
        self.timestamp = block.timestamp
        self.transactions = block.transactions.map { TxResponse($0) }
        self.nonce = block.nonce
        self.hash = block.hash
        self.previousHash = block.previousHash
    }
}

struct BlockchainResponse: Content {
    let blocks: [BlockResponse]
    let mempool: [TxResponse]
    let utxos: [TxResponse.TxOutput]
    init(_ blockchain: Blockchain) {
        self.blocks = blockchain.chain.map { BlockResponse($0) }
        self.mempool = blockchain.mempool.map { TxResponse($0) }
        self.utxos = blockchain.utxos.map { TxResponse.TxOutput($0)}
    }
}
