//
//  BaseDatabaseTests.swift
//  InventoryTests
//
//  Created by Aaron LaBeau on 8/30/23.
//

import XCTest

class BaseDatabaseTests: XCTestCase {
    
    func arrangeDbManager() async -> DatabaseManager {
        
        // MARK: testWarehouseCount - arrange
        let username = "demo@example.com"
        let password = "P@ssw0rd12"
        let authenticationService = MockAuthenticationService()
        let _ = authenticationService.authenticateUser(username: username, password: password)
        let currentUser = authenticationService.getCurrentUser()
        let dbManager = DatabaseManager()
        await dbManager.initializeDatabases(user: currentUser!)
        
        return dbManager
    }
    
    override func tearDownWithError() throws {
        //arrange
        let authenticationService = MockAuthenticationService()
        let _ = authenticationService.authenticateUser(username: "demo@example.com", password: "P@ssw0rd12")
        let currentUser = authenticationService.getCurrentUser()
        let dbManager = DatabaseManager()
        
        wait {
            await dbManager.initializeDatabases(user: currentUser!)
            dbManager.deleteDatabases()
        }
    }
    
    func wait(asyncBlock: @escaping (() async throws -> Void)) {
        let semaphore = DispatchSemaphore(value: 0)
        Task.init {
            try await asyncBlock()
            semaphore.signal()
        }
        semaphore.wait()
    }
}
