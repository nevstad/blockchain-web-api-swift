//
//  Blockchain.swift
//  App
//
//  Created by Magnus Nevstad on 01/04/2019.
//

import Vapor

final class Blockchain: Content {
    /// Block reward for a mined block
    static let blockReward = 1337.0
    
    /// Block reward wallet address, owner of circulating supply
    static let blockRewardPoolAddress = "0xd34db33fl337h4x0r5"
    
    /// Circulating supply
    let circulatingSupply = blockReward * 100_000.0
    
    /// Transation pool holds all transactions to go into the next block
    private(set) var mempool = TransactionPool()
    
    /// The blockchain
    private(set) var chain: [Block] = []
    
    /// Proof of Work Algorithm
    private(set) var pow = ProofOfWork(difficulty: 3)
    

    private enum CodingKeys: CodingKey {
        case circulatingSupply
        case mempool
        case chain
    }
    
    /// Initialises our blockchain with a genesis block
    init() {
        mineGenesisBlock()
    }

    /// Mines our genesis block placing circulating supply in the reward pool,
    /// and awarding the first block to Magnus
    @discardableResult
    private func mineGenesisBlock() -> Block {
        createTransaction(sender: "0x0", recipient: Blockchain.blockRewardPoolAddress, value: circulatingSupply)
        return mineBlock(previousHash: Data(), recipient: "Magnus")
    }
    
    /// Create a transaction to be added to the next block.
    /// - Parameters:
    ///     - sender: The sender
    ///     - recipient: The recipient
    ///     - value: The value to transact
    /// - Returns: The index of the block to whitch this transaction will be added
    @discardableResult
    func createTransaction(sender: String, recipient: String, value: Double, data: Data? = nil) -> Int {
        let transaction = Transaction(sender: sender, recipient: recipient, value: value, data: data)
        self.mempool.addTransaction(transaction)
        return self.chain.count + 1
    }
    
    /// Create a new block in the chain, adding transactions curently in the mempool to the block
    /// - Parameter proof: The proof of the PoW
    @discardableResult
    func createBlock(nonce: Int, hash: Data, previousHash: Data, blockData: BlockData) -> Block {
        let block = Block(blockData: blockData, nonce: nonce, hash: hash, previousHash: previousHash)
        chain.append(block)
        return block
    }
    
    /// Mines the next block using Proof of Work
    /// - Parameter recipient: The miners address for block reward
    func mineBlock(previousHash: Data, recipient: String) -> Block {
        createTransaction(sender: Blockchain.blockRewardPoolAddress, recipient: recipient, value: Blockchain.blockReward)
        let blockData = (
            index: chain.count + 1,
            timestamp: Date().timeIntervalSince1970,
            transactions: mempool.drain()
        )
        let proof = pow.work(prevHash: previousHash, blockData: blockData)
        return createBlock(nonce: proof.nonce, hash: proof.hash, previousHash: previousHash, blockData: blockData)
    }
    
    /// Returns the last block in the blockchain. Fatal error if we have no blocks.
    func lastBlock() -> Block {
        guard let last = chain.last else {
            fatalError("Blockchain needs at least a genesis block!")
        }
        return last
    }
    
    /// A very un-optimezed way to iterate every transaction in history to calculate the balance for an address
    /// - Parameter address: The address whose balance to calculate
    func balance(for address: String) -> Double {
        var balance = 0.0
        for block in chain {
            for transaction in block.transactions {
                if transaction.sender == address {
                    balance -= transaction.value
                } else if transaction.recipient == address {
                    balance += transaction.value
                }
            }
        }
        return balance
    }
}


final class TransactionPool: Content {
    /// Transactions in the pool
    private var transactions = [Transaction]()
    
    /// Add a transaction to the pool
    /// - Parameter transaction: The transaction to be added
    func addTransaction(_ transaction: Transaction) {
        self.transactions.append(transaction)
    }
    
    /// Drains the pool of transactions
    /// - Returns: All transations currently in the pool
    func drain() -> [Transaction] {
        let txs = transactions
        transactions.removeAll()
        return txs
    }
}
