//
//  Node.swift
//  App
//
//  Created by Magnus Nevstad on 10/04/2019.
//

import Foundation
import BlockchainSwift
import Vapor


/// In our simplistic network, we have _one_ central Node, with an arbitrary amount of Miners and Wallets.
/// - Central: The hub which all others connect to, and is responsible for syncronizing data accross them. There can only be one.
/// - Miner: Stores new transactions in a mempool, and will put them into blocks once mined. Needs to store the entire chainstate.
/// - Wallet: Sends coins between wallets, and (unlike Bitcoins optimized SPV nodes) needs to store the entire chainstate.
public class Node {
    /// Version lets us make sure all nodes run the same version of the blockchain
    public let version: Int = 1
    
    /// Our address in the Node network
    public let address: NodeAddress
    
    /// Our network of nodes
    public var knownNodes = [NodeAddress]()
    
    /// Local copy of the blockchain
    public let blockchain: Blockchain
    
    public let wallet: Wallet
    
    init(address: NodeAddress, wallet: Wallet? = nil) {
        self.address = address
        self.wallet = wallet ?? Wallet()!
        self.blockchain = Blockchain(minerAddress: self.wallet.address)
        
        // Every node must know of our central node
        self.knownNodes.append(NodeAddress.centralAddress())
        connect()
    }
    
    var versionMessage: VersionMessage {
        get {
            return VersionMessage(version: self.version, blockHeight: self.blockchain.chain.count, fromAddress: self.address)
        }
    }
        
    ///
    /// Connections to network
    ///
    
    public func connect() {
        if self.address.isCentralNode {
            // Central device doesn't need to send initial VersionMessage anywhere
        } else {
            // Send our version to the central, registering ourselves
            // Central will respond back, and if there is a genesis block present there, we will get
            // a VersionMessage back - which should trigger us to request blocks
            sendVersionMessage(to: self.knownNodes[0], versionMessage: self.versionMessage)
        }
    }
    
    public func disconnect() {
        // TODO - for now the central is never notified when a Node disappears
    }
    
    
    ///
    /// Interaction with the Blockchain
    ///
    
    public func chain() -> Blockchain {
        return blockchain
    }
    
    public func balance(address: Data) -> UInt64 {
        return blockchain.balance(for: wallet.address)
    }
    
    public func mine(completion: @escaping (Block) -> ()) {
        DispatchQueue.global(qos: .default).async {
            let lastBlock = self.blockchain.lastBlock()
            completion(self.blockchain.mineBlock(previousHash: lastBlock.hash, minerAddress: self.wallet.address))
        }
    }
    
    // TODO: Move functionality into a "client" app
    public func send(recipientAddress: Data, value: UInt64) throws -> Int {
        let targetBlockHeight = try blockchain.createTransaction(sender: wallet, recipientAddress: recipientAddress, value: value)
        
        // TODO: Broadcast new transaction to network
        for nodeAddress in knownNodes {
            if !nodeAddress.isCentralNode {
//                sendTxsMessage(to: nodeAddress, txsMessage: ...)
            }
        }
        
        return targetBlockHeight
    }
    
    ///
    /// Receiving messages
    ///
    
    func handleVersionMessage(_ version: VersionMessage) {
        // TODO: Validate the node is running the same version code as us
        print("Received version from \(version.fromAddress.urlString) with blockHeight=\(version.blockHeight)")

        // If the version received has a longer chain than us, we need to get blocks, otherwise respond with our version
        if self.versionMessage.blockHeight < version.blockHeight  {
            print("... Remote node has more blocks!")
            // TODO: request blocks from version.FromAddress, starting from self.blockchain.lastBlock().hash
        } else if self.versionMessage.blockHeight > version.blockHeight{
            print("... Remote node has less blocks!")
            sendVersionMessage(to: version.fromAddress, versionMessage: self.versionMessage)
        }

        // Add the node to our known network if it us unknown to us
        if knownNodes.firstIndex(of: version.fromAddress) == nil {
            print("... Adding node \(version.fromAddress)")
            knownNodes.append(version.fromAddress)
        } else {
            print("... Ignoring node \(version.fromAddress)")
        }
    }
    
    func handleTxsMessage(_ txs: TxsResponse) { // TODO: We need a Message type object with fromAddress
        // We have received a list of transactions
    }
    
    func handleBlocksMessage(_ blocks: BlocksResponse) { // TODO: We need a Message type object with fromAddress
        // We have received a list of blocks
    }
    
//    func handleInventoryMessage(_ inventory: InventoryMessage) {
//        for item in inventory.items {
//            switch item.type {
//            case .blockMessage:
//                // We have received a block
//                break
//            case .transactionMessage:
//                // We have received a tx
//                break
//            }
//        }
//    }
//    
//    func handleDataMessage(_ data: DataMessage) {
//        switch data.type {
//        case .block:
//            break
//        case .tx:
//            break
//        }
//    }
    
    ///
    /// Sending messages
    ///
    
    func sendVersionMessage(to: NodeAddress, versionMessage: VersionMessage) {
        let url = to.url
            .appendingPathComponent("api")
            .appendingPathComponent("v1")
            .appendingPathComponent("version")

        print("Sending version to \(to.urlString)")
        self.sendMessage(url: url, messageJSON: try! JSONEncoder().encode(versionMessage))
    }
    
    func sendTxsMessage(to: NodeAddress, txsMessage: TxsResponse) {
        let url = to.url
            .appendingPathComponent("api")
            .appendingPathComponent("v1")
            .appendingPathComponent("transaction")
        
        print("Sending transactions to \(to.urlString)")
        self.sendMessage(url: url, messageJSON: try! JSONEncoder().encode(txsMessage))
    }
    
    func sendBlocksMessage(to: NodeAddress, blocksMessage: BlocksResponse) {
        let url = to.url
            .appendingPathComponent("api")
            .appendingPathComponent("v1")
            .appendingPathComponent("blocks")
        
        print("Sending blocks to \(to.urlString)")
        self.sendMessage(url: url, messageJSON: try! JSONEncoder().encode(blocksMessage))
    }
    
    private func sendMessage(url: URL, messageJSON: Data, completion: ((Data?) -> ())? = nil) {
        let session = URLSession.shared
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = messageJSON
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        //create dataTask using the session object to send data to the server
        let task = session.dataTask(with: request as URLRequest, completionHandler: { data, response, error in
            completion?(data)
        })
        task.resume()
    }
    
//    func sendInventoryMessage(_ inventory: InventoryMessage) {
//    }
//    
//    func sendBlocksMessage(_ blocks: BlocksMessage) {
//    }
//    
//    func sendDataMessage(_ data: DataMessage) {
//    }
}
