//
//  AuthenticationService.swift
//  Inventory
//
//  Created by Aaron LaBeau on 8/29/23.
//

import Foundation

protocol AuthenticationService {
    func getCurrentUser() -> User?
    func authenticateUser(username: String, password: String) -> Bool
    func logout ()
}
