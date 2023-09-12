//
//  WarehouseDatabaseRepository.swift
//  Inventory
//
//  Created by Aaron LaBeau on 9/5/23.
//

import Foundation
import CouchbaseLiteSwift
import Combine

class WarehouseDatabaseRepository 
    : WarehouseRepository {
    
    var databaseManager: DatabaseManager
    
    let countKey = "count"
    
    init(databaseManager: DatabaseManager){
        self.databaseManager = databaseManager
    }
    
    func count() async -> Int {
        let task = Task(priority: .background) { [weak self] in
            var count = 0
            do {
                if let dbManager = self?.databaseManager,
                   let countKey = self?.countKey,
                   let db = dbManager.warehousesDatabase {
                    let query = "SELECT COUNT (*) as \(countKey) FROM \(dbManager.warehouseScopeName).\(dbManager.warehouseCollectionName)"
                    let results = try db.createQuery(query).execute().allResults()
                    count = results[0].int(forKey: countKey)
                }
            } catch {
                print ("Error trying to count user profiles: \(error)")
            }
            return count
        }
        return await task.value
    }
    
}
