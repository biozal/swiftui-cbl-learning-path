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
        let username = "demo@example.com"
        let password = "P@ssw0rd12"
        let authenticationService = MockAuthenticationService()
        let _ = authenticationService.authenticateUser(username: username, password: password)
        let currentUser = authenticationService.getCurrentUser()
        let dbManager = DatabaseManager()
        await dbManager.initializeDatabases(user: currentUser!)
       
        // MARK: testWarehouseCount act
        // open, create collections, close the database, and reopen to make sure existing collections stil are valid
        let repository = WarehouseDatabaseRepository(databaseManager: dbManager)
        let count = await repository.count()
                
        // MARK: testWarehouseCount - assert
        XCTAssertNotNil(count)
        XCTAssertEqual(18, count, "Warehouse Count should be x when newely created database")
        
        //clean up
        dbManager.closeDatabases()
    }
    
    func testWarehouseIndexCreation() async throws {
        // MARK: testWarehouseIndexCreation - arrange
        let username = "demo@example.com"
        let password = "P@ssw0rd12"
        let authenticationService = MockAuthenticationService()
        let _ = authenticationService.authenticateUser(username: username, password: password)
        let currentUser = authenticationService.getCurrentUser()
        let dbManager = DatabaseManager()
        await dbManager.initializeDatabases(user: currentUser!)
        
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
