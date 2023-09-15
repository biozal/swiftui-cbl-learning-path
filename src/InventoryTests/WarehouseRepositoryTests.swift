//
//  WarehouseRepositoryTests.swift
//  InventoryTests
//
//  Created by Aaron LaBeau on 9/5/23.
//

import XCTest
import Inventory

final class WarehouseRepositoryTests
: BaseDatabaseTests {
    
    func testWarehouseCount() async throws {
        // MARK: testWarehouseCount - arrange
        let dbManager = await self.arrangeDbManager()
       
        // MARK: testWarehouseCount act
        // open, create collections, close the database, and reopen to make sure existing collections stil are valid
        let repository = await WarehouseDatabaseRepository(databaseManager: dbManager)
        let count = try await repository.count()
                
        // MARK: testWarehouseCount - assert
        XCTAssertNotNil(count)
        XCTAssertEqual(18, count, "Warehouse Count should be x when newely created database")
        
        //clean up
        dbManager.closeDatabases()
    }
    
    func testWarehouseGetByCity() async throws {
        // MARK: testWarehouseGetByCity - arrange
        let dbManager = await self.arrangeDbManager()
        
        // MARK: testWarehouseGetQuery act
        let repository = await WarehouseDatabaseRepository(databaseManager: dbManager)
        let documents = try await repository.getByCityState(city: "sa", state: nil)
        
        // MARK: testWarehouseGetQuery - assert
        XCTAssertNotNil(documents)
        XCTAssertEqual(2, documents.count, "Warehouse Count should be x when newely copied database")
        
        //clean up
        dbManager.closeDatabases()
        
    }
    
    func testWarehouseGetByCityState() async throws {
        // MARK: testWarehouseGetByCity - arrange
        let dbManager = await self.arrangeDbManager()
        
        // MARK: testWarehouseGetQuery act
        let repository = await WarehouseDatabaseRepository(databaseManager: dbManager)
        let documents = try await repository.getByCityState(city: "sa", state: "c")
        
        // MARK: testWarehouseGetQuery - assert
        XCTAssertNotNil(documents)
        XCTAssertEqual(1, documents.count, "Warehouse Count should be x when newely copied database")
        
        //clean up
        dbManager.closeDatabases()
        
    }
    
    func testWarehouseGetByCityStateIsBlank() async throws {
        // MARK: testWarehouseGetByCity - arrange
        let dbManager = await self.arrangeDbManager()
        
        // MARK: testWarehouseGetQuery act
        let repository = await WarehouseDatabaseRepository(databaseManager: dbManager)
        let documents = try await repository.getByCityState(city: "", state: "")
        
        // MARK: testWarehouseGetQuery - assert
        XCTAssertNotNil(documents)
        XCTAssertEqual(18, documents.count, "Warehouse Count should be x when newely copied database")
        
        //clean up
        dbManager.closeDatabases()
        
    }
    
    
    func testWarehouseGetQuery() async throws {
        
        // MARK: testWarehouseGetQuery - arrange
        let dbManager = await self.arrangeDbManager()
        
        // MARK: testWarehouseGetQuery act
        // open, create collections, close the database, and reopen to make sure existing collections stil are valid
        let repository = await WarehouseDatabaseRepository(databaseManager: dbManager)
        let results = try await repository.get()
        let document = results.first(where: { $0.warehouseId == "e1839e0b-57a0-472c-b29d-8d57e256ef32" })
        
        // MARK: testWarehouseGetQuery - assert
        XCTAssertNotNil(results)
        XCTAssertEqual(18, results.count, "Warehouse Count should be x when newely created database")
        XCTAssertEqual("e1839e0b-57a0-472c-b29d-8d57e256ef32", document?.warehouseId, "WarehouseId should be set to this UUID")
        XCTAssertEqual("Santa Clara Warehouse", document?.name, "Name should be this value")
        
        //clean up
        dbManager.closeDatabases()
        
    }
    
    func testWarehouseIndexCreation() async throws {
        // MARK: testWarehouseIndexCreation - arrange
        let dbManager = await self.arrangeDbManager()
        
        // MARK: testWarehouseIndexCreation act
        // test to make sure that index(es) are created
        let indexes = try dbManager.locationsCollection?.indexes()
        let indexCount = indexes?.count
        let doesContainLocationIndexes = indexes?.contains(dbManager.cityStateIndexName)
        
        // MARK: testWarehouseCount - assert
        XCTAssertNotNil(indexes)
        XCTAssertEqual(1, indexCount, "Warehouse Index Count should be 1")
        XCTAssertTrue(doesContainLocationIndexes!, "Warehouse Index should have index name \(dbManager.cityStateIndexName)")
        
        //clean up
        dbManager.closeDatabases()
    }
    
}
