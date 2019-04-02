//
//  Transaction.swift
//  App
//
//  Created by Magnus Nevstad on 01/04/2019.
//

import Vapor

struct Transaction: Content {
    let sender: String
    let recipient: String
    let value: Double
    let data: Data?
}
