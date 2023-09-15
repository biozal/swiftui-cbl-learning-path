//
//  WarehouseRepository.swift
//  Inventory
//
//  Created by Aaron LaBeau on 9/5/23.
//

import Foundation

import Foundation

protocol WarehouseRepository {
    
    func count() async throws -> Int
    func get() async throws -> [Warehouse]
    func getByCityState(city: String, state: String?) async throws -> [Warehouse]
}
