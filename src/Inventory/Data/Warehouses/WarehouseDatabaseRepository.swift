//
//  WarehouseDatabaseRepository.swift
//  Inventory
//
//  Created by Aaron LaBeau on 9/5/23.
//

import Foundation
import CouchbaseLiteSwift
import Combine

@RepositoryActor class WarehouseDatabaseRepository
: WarehouseRepository {
    
    var databaseManager: DatabaseManager
    let countKey = "count"
    
    init(databaseManager: DatabaseManager){
        self.databaseManager = databaseManager
    }
    
    func count() async -> Int {
        var count = 0
        do {
            if let db = databaseManager.warehousesDatabase {
                let query = "SELECT COUNT (*) as \(countKey) FROM \(databaseManager.warehouseScopeName).\(databaseManager.warehouseCollectionName)"
                let results = try db.createQuery(query).execute().allResults()
                count = results[0].int(forKey: countKey)
            }
        } catch {
            print ("Error trying to count user profiles: \(error)")
        }
        return count
    }
    
    /*
     func count() async -> Int {
     await withCheckedContinuation {continuation in
     let worker = BackgroundWorker()
     worker.enqueue { [databaseManager, countKey] in
     var count = 0
     do {
     if let db = databaseManager.warehousesDatabase {
     let query = "SELECT COUNT (*) as \(countKey) FROM \(databaseManager.warehouseScopeName).\(databaseManager.warehouseCollectionName)"
     let results = try db.createQuery(query).execute().allResults()
     count = results[0].int(forKey: countKey)
     }
     } catch {
     print ("Error trying to count user profiles: \(error)")
     }
     continuation.resume(returning: count)
     }
     }
     }
     */
    
    /*
     func get() async -> [Warehouse] {
     }
     */
    
}
