//
//  ProjectDatabaseRepository.swift
//  Inventory
//
//  Created by Aaron LaBeau on 9/14/23.
//

import Foundation

//TODO use this for writing projects to the database because the replicator could also be writing at the same time as us on a different connection, but we need to be on the same thread

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
