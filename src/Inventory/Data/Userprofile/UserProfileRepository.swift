//
//  UserProfileRepository.swift
//  Inventory
//
//  Created by Aaron LaBeau on 8/29/23.
//

import Foundation

protocol UserProfileRepository {
    
    func count() async -> Int
    func get(currentUser: String) async -> [String: Any]
    func save(data: [String: Any]) async -> Bool
}
