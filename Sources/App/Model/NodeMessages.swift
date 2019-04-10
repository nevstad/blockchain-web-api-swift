//
//  NodeMessages.swift
//  App
//
//  Created by Magnus Nevstad on 10/04/2019.
//

import Vapor

public struct VersionMessage: Content {
    public let version: Int
    public let blockHeight: Int
    public let fromAddress: NodeAddress
}


public struct InventoryMessage: Content {
    public let items: [InventoryItem]
    public let fromAddress: NodeAddress
}

public struct InventoryItem: Content {
    public enum ItemType: Int, Codable {
        case blockMessage
        case transactionMessage
    }
    
    public let type: ItemType
    public let hash: Data
    public let fromAddress: NodeAddress
}


public struct BlocksMessage: Content {
    public let blockHashes: [Data]
    public let fromAddress: NodeAddress
}


public struct DataMessage: Content {
    public enum DataType: Int, Codable {
        case block
        case tx
    }
    public let type: DataType
    public let hash: Data
    public let fromAddress: NodeAddress
}
