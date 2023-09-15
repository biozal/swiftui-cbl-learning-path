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
    
    func getByCityState(city: String, state: String?) async throws -> [Warehouse]  {
        var warehouses = [Warehouse]()
        do {
            if let db = databaseManager.warehousesDatabase{
                var query = "SELECT warehouseId, name, address1, address2, city, state, postalCode, salesTax, latitude, longitude, locationType, shippingTo, yearToDateBalance FROM \(databaseManager.warehouseScopeName).\(databaseManager.warehouseCollectionName)"
                
                if (!city.isEmpty){
                    query += " WHERE LOWER(city) LIKE '%\(city.lowercased())%'"
                    if let queryState = state {
                        query +=  "AND LOWER(state) LIKE '%\(queryState.lowercased())%'"
                    }
                }
                
                let dbQuery = try db.createQuery(query)
                #if DEBUG
                let explain = try dbQuery.explain()
                print ("**EXPLAIN** \(explain)")
                #endif
                warehouses = try await getWarehouseQueryResults(query: dbQuery)
            }
        } catch {
            print ("Error trying to get user profiles: \(error)")
            throw error
        }
        return warehouses
    }
    
    func get() async throws -> [Warehouse]  {
        var warehouses = [Warehouse]()
        do {
            if let db = databaseManager.warehousesDatabase{
                
                let query = "SELECT warehouseId, name, address1, address2, city, state, postalCode, salesTax, latitude, longitude, locationType, shippingTo, yearToDateBalance FROM \(databaseManager.warehouseScopeName).\(databaseManager.warehouseCollectionName)"
                let dbQuery = try db.createQuery(query)
                #if DEBUG
                let explain = try dbQuery.explain()
                print ("**EXPLAIN** \(explain)")
                #endif
                warehouses = try await getWarehouseQueryResults(query: dbQuery)
            }
        } catch {
            print ("Error trying to get user profiles: \(error)")
            throw error
        }
        return warehouses
    }
    
    func getWarehouseQueryResults(query: Query) async throws -> [Warehouse] {
        var warehouses = [Warehouse]()
        do {
            for result in try query.execute() {
                if let data = result.toJSON().data(using: .utf8) {
                    let warehouse = try JSONDecoder().decode(Warehouse.self, from: data)
                    warehouses.append(warehouse)
                }
            }
        } catch {
            print ("Error trying to get user profiles: \(error)")
            throw error
        }
        return warehouses
    }
    
    func count() async throws -> Int {
        var count = 0
        do {
            if let db = databaseManager.warehousesDatabase {
                let query = "SELECT COUNT (*) as \(countKey) FROM \(databaseManager.warehouseScopeName).\(databaseManager.warehouseCollectionName)"
                let results = try db.createQuery(query).execute().allResults()
                count = results[0].int(forKey: countKey)
            }
        } catch {
            print ("Error trying to get user profiles: \(error)")
            throw error
        }
        return count
    }
    

}
