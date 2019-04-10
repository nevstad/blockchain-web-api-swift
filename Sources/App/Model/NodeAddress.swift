//
//  NodeAddress.swift
//  App
//
//  Created by Magnus Nevstad on 10/04/2019.
//

import Vapor

public struct NodeAddress: Content {
    let host: String
    let port: UInt32

    var urlString: String {
        get {
            return "http://\(host):\(port)"
        }
    }
    var url: URL {
        get {
            return URL(string: urlString)!
        }
    }
}

extension NodeAddress: Equatable {
    public static func == (lhs: NodeAddress, rhs: NodeAddress) -> Bool {
        return lhs.port == rhs.port //&& lhs.host == rhs.host
    }
}

extension NodeAddress {
    // For simplicity's sake we hard code the central node address
    static func centralAddress() -> NodeAddress {
        return NodeAddress(host: "localhost", port: 8080)
    }
    
    var isCentralNode: Bool {
        get {
            return self == NodeAddress.centralAddress()
        }
    }

}
