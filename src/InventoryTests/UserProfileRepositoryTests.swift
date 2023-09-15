//
//  UserProfileRepositoryTests.swift
//  InventoryTests
//
//  Created by Aaron LaBeau on 8/30/23.
//

import XCTest
import Inventory

final class UserProfileRepositoryTests
    : BaseDatabaseTests {
    
    func testUserProfileCountZero() async throws {
        // MARK: testUserProfileCountZero - arrange
        let username = "demo@example.com"
        let password = "P@ssw0rd12"
        let authenticationService = MockAuthenticationService()
        let _ = authenticationService.authenticateUser(username: username, password: password)
        let currentUser = authenticationService.getCurrentUser()
        let dbManager = DatabaseManager()
        await dbManager.initializeDatabases(user: currentUser!)
       
        // MARK: testUserProfileCountZero act
        // open, create collections, close the database, and reopen to make sure existing collections stil are valid
        let repository = await UserProfileDatabaseRepository(databaseManager: dbManager)
        let count =  try await repository.count()
                
        // MARK: testUserProfileCountZero - assert
        XCTAssertNotNil(count)
        XCTAssertEqual(0, count, "User Profile Count should be zero when newely created database")
        
        //clean up
        dbManager.closeDatabases()
    }
    
    func testUserProfileCountByTeams() async throws {
        // MARK: testUserProfileCountByTeams - arrange
        let username1 = "demo@example.com"
        let username2 = "demo1@example.com"
        let username3 = "demo5@example.com"
        let password = "P@ssw0rd12"
        let authenticationService = MockAuthenticationService()
        let _ = authenticationService.authenticateUser(username: username1, password: password)
        let currentUser1 = authenticationService.getCurrentUser()
        let dbManager = DatabaseManager()
        await dbManager.initializeDatabases(user: currentUser1!)
       
        // MARK: testUserProfileCountByTeams act
        // create two users for team1 and one user for a different team and make sure team1 count is 2 and the other team is 1
        let repository = await UserProfileDatabaseRepository(databaseManager: dbManager)
        
        var dataUser1: [String: Any] = [:]
        dataUser1[repository.emailKey] = username1
        dataUser1[repository.teamKey] = currentUser1?.team
        
        var dataUser2: [String: Any] = [:]
        dataUser2[repository.emailKey] = username2
        dataUser2[repository.teamKey] = currentUser1?.team
        
        let _ = try await repository.save(data: dataUser1)
        let _ = try await repository.save(data: dataUser2)
        let countTeam1 = try await repository.count()
        
        //close database and open new user
        dbManager.closeDatabases()
        authenticationService.logout()
        let _ = authenticationService.authenticateUser(username: username3, password: password)
        let currentUser3 = authenticationService.getCurrentUser()
        await dbManager.initializeDatabases(user: currentUser3!)
        
        //setup other team data
        var dataUser3: [String: Any] = [:]
        dataUser3[repository.emailKey] = username3
        dataUser3[repository.teamKey] = currentUser3?.team
        
        let _ = try await repository.save(data: dataUser3)
        let countTeam2 = try await repository.count()
        
        //clean up other team databases
        dbManager.deleteDatabases()
                
        // MARK: testUserProfileCountByTeams - assert
        XCTAssertNotNil(countTeam1)
        XCTAssertNotNil(countTeam2)
        XCTAssertEqual(2, countTeam1, "User Profile Count should be 2 for team1")
        XCTAssertEqual(1, countTeam2, "User Profile Count should be 1 for \(currentUser3!.team)")
    }
    
    func testNotSaveUserProfileWithoutDBManagerSetup() async throws {
        
        // MARK: testNotSaveUserProfileWithoutDBManagerSetup arrange
        let dbManager = DatabaseManager()
        let repository = await UserProfileDatabaseRepository(databaseManager: dbManager)
        
        // MARK: testNotSaveUserProfileWithoutDBManagerSetup act
        // create a new user and then close and open up the database to see if we get the same values back
        var data: [String: Any] = [:]
        data[repository.emailKey] =  ""
        
        let didSave = try await repository.save(data: data)
        
        // MARK: testNotSaveUserProfileWithoutDBManagerSetup assert
        XCTAssertFalse(didSave, "didSave should be FALSE because dbManager isn't setup")
       
        //clean up
        dbManager.closeDatabases()
    }
    
    func testNotSaveUserProfileWithoutEmail() async throws {
        
        // MARK: testNotSaveUserProfileWithoutEmail arrange
        let email = "demo@example.com"
        let password = "P@ssw0rd12"
        
        let authenticationService = MockAuthenticationService()
        let _ = authenticationService.authenticateUser(username: email, password: password)
        let currentUser = authenticationService.getCurrentUser()
        let dbManager = DatabaseManager()
        await dbManager.initializeDatabases(user: currentUser!)
        let repository = await UserProfileDatabaseRepository(databaseManager: dbManager)
        
        // MARK: testNotSaveUserProfileWithoutEmail act
        // create a new user and then close and open up the database to see if we get the same values back
        var results: [String: Any] = [:]
        results[repository.emailKey] =  ""
        
        let didSave = try await repository.save(data: results)
        
        // MARK: testNotSaveUserProfileWithoutEmail assert
        XCTAssertFalse(didSave, "didSave should be FALSE because no email is provided when trying to save user profile to the database")
       
        //clean up
        dbManager.closeDatabases()
    }
    
    func testCreateReadUserProfileDemoUserTeam1() async throws {
        
        // MARK: testCreateUserProfileDemoUserTeam1 arrange
        let email = "demo@example.com"
        let password = "P@ssw0rd12"
        let firstName = "Jane"
        let lastName = "Doe"
        let jobtitle = "Developer"
        
        let authenticationService = MockAuthenticationService()
        let _ = authenticationService.authenticateUser(username: email, password: password)
        let currentUser = authenticationService.getCurrentUser()
        let dbManager = DatabaseManager()
        await dbManager.initializeDatabases(user: currentUser!)
        let repository = await UserProfileDatabaseRepository(databaseManager: dbManager)
        
        #if os(macOS)
            let profileImage = NSImage(systemSymbolName: "multiply.circle.fill", accessibilityDescription: "")
            let cgImage = (profileImage?.cgImage(forProposedRect: nil, context: nil, hints: nil)!)!
            let bitmapRep = NSBitmapImageRep(cgImage: cgImage)
            let profileImageData = bitmapRep.representation(using: NSBitmapImageRep.FileType.jpeg, properties: [:])!
        #else
            let profileImage = UIImage(systemName: "multiply.circle.fill")
            let profileImageData = profileImage?.jpegData(compressionQuality: 90)
        #endif
        
        // MARK: testCreateUserProfileDemoUserTeam1 act
        // create a new user and then close and open up the database to see if we get the same values back
        var results: [String: Any] = [:]
        results[repository.emailKey] = email
        results[repository.givenNameKey] =  firstName
        results[repository.surnameKey] =  lastName
        results[repository.jobTitleKey] =  jobtitle
        results[repository.teamKey] = currentUser?.team
        results[repository.imageDataKey] = profileImageData
        
        let didSave = try await repository.save(data: results)
        
        //close and open the database to make sure the document isn't cached
        dbManager.closeDatabases()
        await dbManager.initializeDatabases(user: currentUser!)
        await dbManager.initializeDatabases(user: currentUser!)
        await dbManager.initializeDatabases(user: currentUser!)
        
        //get the user profile document previously saved
        let userData = try await repository.get(currentUser: email)
        
        let userFirstName = userData[repository.givenNameKey] as! String
        let userLastName = userData[repository.surnameKey] as! String
        let userJobTitle = userData[repository.jobTitleKey] as! String
        let userEmail = userData[repository.emailKey] as! String
        let userTeam = userData[repository.teamKey] as! String
        let blobData = userData[repository.imageDataKey] as! Data
        
        // MARK: testCreateUserProfileDemoUserTeam1 assert
        XCTAssertTrue(didSave, "didSave should be TRUE saving the new user profile to the database")
        XCTAssertNotNil(userData, "userData should not be nil")
        XCTAssertEqual(email, userEmail, "Email should be \(email) but was \(userEmail)")
        XCTAssertEqual(firstName, userFirstName, "Fist Name should be \(firstName) but was \(userFirstName)")
        XCTAssertEqual(lastName, userLastName, "Last Name should be \(lastName) but was \(userLastName)")
        XCTAssertEqual(jobtitle, userJobTitle, "Job Title should be \(jobtitle) but was \(userJobTitle)")
        XCTAssertEqual(currentUser!.team, userTeam, "Team should be \(currentUser!.team) but was \(userTeam)")
        XCTAssertNotNil(blobData, "Blob Data should't be null")
        XCTAssertEqual(profileImageData, blobData, "Blob Data should be equal")
       
        //clean up
        dbManager.closeDatabases()
    }
    
}
