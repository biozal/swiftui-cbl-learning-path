//
//  User.swift
//  Inventory
//
//  Created by Aaron LaBeau on 8/29/23.
//

import Foundation

struct User : Codable {
    let username: String
    let password: String
    let team: String
    
    init(
        username: String,
        password: String,
        team: String
    ){
        self.username = username
        self.password = password
        self.team = team
    }
}
