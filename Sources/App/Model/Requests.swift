//
//  Requests.swift
//  App
//
//  Created by Magnus Nevstad on 08/04/2019.
//

import Vapor

struct TransactionRequest: Content {
    let address: String
    let value: UInt64
}
