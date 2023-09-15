//
//  UserProfileRepository.swift
//  Inventory
//
//  Created by Aaron LaBeau on 8/29/23.
//

import Foundation

protocol UserProfileRepository {
    
    func count() async throws -> Int
    func get(currentUser: String)  async throws -> [String: Any]
    func save(data: [String: Any])  async throws -> Bool
}
