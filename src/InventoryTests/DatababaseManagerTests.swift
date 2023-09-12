//
//  DatababaseManagerTests.swift
//  InventoryTests
//
//  Created by Aaron LaBeau on 8/29/23.
//

import XCTest
import Inventory

final class DatababaseManagerTests
    : BaseDatabaseTests {

    func testInventoryDatabaseFullCreationDeletion() async throws {
        // MARK: testInventoryDatabaseFullCreationDeletion arrange
        let authenticationService = MockAuthenticationService()
        let _ = authenticationService.authenticateUser(username: "demo@example.com", password: "P@ssw0rd12")
        let currentUser = authenticationService.getCurrentUser()
        let dbManager = DatabaseManager()
        
        // MARK: testInventoryDatabaseFullCreationDeletion act
        await dbManager.initializeDatabases(user: currentUser!)
        let inventoryDatabase = dbManager.inventoryDatabase
        let userProfileCollection = dbManager.userProfileCollection
        let projectCollection = dbManager.projectCollection
        let auditItemCollection = dbManager.auditCollection
        let collectionCount = dbManager.collectionCount()
        let auditIndexes = try auditItemCollection?.indexes()
        let auditIndexCount = auditIndexes?.count
        let doesContainAuditIndex = auditIndexes?.contains(dbManager.auditIndexName)
        
        // MARK: testInventoryDatabaseFullCreationDeletion assert
        XCTAssertNotNil(dbManager, "Database Manager should not be nil")
        XCTAssertNotNil(inventoryDatabase, "Inventory Database should not be nil")
        XCTAssertNotNil(userProfileCollection, "User Profile Collection should not be nil")
        XCTAssertNotNil(projectCollection, "Project Collection should not be nil")
        XCTAssertNotNil(auditItemCollection, "Audit Items Collection should not be nil")
        XCTAssertEqual(3, collectionCount, "There should be 3 collections created")
        XCTAssertNotNil(doesContainAuditIndex, "It should contain an index named \(dbManager.auditIndexName)")
        XCTAssertTrue(doesContainAuditIndex!, "It should contain an index named \(dbManager.auditIndexName)")
        XCTAssertEqual(1, auditIndexCount, "There should be 1 index created")
        
        //clean up
        dbManager.closeDatabases()
    }
    
    func testInventoryDatabaseCollections() async throws {
        //arrange
        let authenticationService = MockAuthenticationService()
        let _ = authenticationService.authenticateUser(username: "demo@example.com", password: "P@ssw0rd12")
        let currentUser = authenticationService.getCurrentUser()
        let dbManager = DatabaseManager()
        
        //act - open, create collections, close the database, and reopen to make sure existing collections stil are valid
        await dbManager.initializeDatabases(user: currentUser!)
        dbManager.closeDatabases()
        await dbManager.initializeDatabases(user: currentUser!)
        
        let inventoryDatabase = dbManager.inventoryDatabase
        let collectionCount = dbManager.collectionCount()
        let userProfileCollection = dbManager.userProfileCollection
        let projectCollection = dbManager.projectCollection
        let auditItemCollection = dbManager.auditCollection
        
        //assert
        XCTAssertNotNil(dbManager, "Database Manager should not be nil")
        XCTAssertNotNil(inventoryDatabase, "Inventory Database should not be nil")
        XCTAssertEqual(3, collectionCount, "There should be 3 collections created")
        XCTAssertNotNil(userProfileCollection, "User Profile Collection should not be nil")
        XCTAssertNotNil(projectCollection, "Project Collection should not be nil")
        XCTAssertNotNil(auditItemCollection, "Audit Items Collection should not be nil")
        
        //clean up
        dbManager.closeDatabases()
    }
    
    
    /*
    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    */

}
