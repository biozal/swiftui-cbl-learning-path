//
//  AuthenticationServiceTests.swift
//  InventoryTests
//
//  Created by Aaron LaBeau on 8/29/23.
//

import XCTest
import Inventory

final class AuthenticationServiceTests: XCTestCase {

    func testSuccesfulAuthentication() throws {
        //arrange
        let authenticationService = MockAuthenticationService()
        let testUsername1 = "demo@example.com"
        let testPassword1 = "P@ssw0rd12"
        let testTeam1 = "team1"
        
        //act
        let isAuthenticated = authenticationService.authenticateUser(username: testUsername1, password: testPassword1)
        let currentUser = authenticationService.getCurrentUser()
        
        //assert
        XCTAssertTrue(isAuthenticated, "user should be authenticated - thus true")
        XCTAssertNotNil(currentUser, "currentUser should not be nil")
        XCTAssertEqual(testUsername1, currentUser?.username, "username must match")
        XCTAssertEqual(testPassword1, currentUser?.password, "username must match")
        XCTAssertEqual(testTeam1, currentUser?.team, "Team membership must match")
        
    }
    
    func testFailureAuthentication() throws {
        //arrange
        let authenticationService = MockAuthenticationService()
        let testUsername1 = "demo@example.com"
        let testPassword1 = "Password"
        
        //act
        let isAuthenticated = authenticationService.authenticateUser(username: testUsername1, password: testPassword1)
        let currentUser = authenticationService.getCurrentUser()
        
        //assert
        XCTAssertFalse(isAuthenticated, "user should NOT be authenticated")
        XCTAssertNil(currentUser, "currentUser should be nil")
    }
}
