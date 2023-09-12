//
//  AuthenticationService.swift
//  Inventory
//
//  Created by Aaron LaBeau on 8/29/23.
//

import Foundation
import Combine

class MockAuthenticationService 
: AuthenticationService, ObservableObject {
    
    private var currentUser: User? = nil
    private var _mockUsers: [String: User] = [:]
    
    let objectWillChange = PassthroughSubject<Void, Never>()
    
    init() {
        // Create mock users for testing the application
        // In a real app, this would be provided by some kind of OAuth2 Service, etc.
        _mockUsers["demo@example.com"] = User(username: "demo@example.com", password: "P@ssw0rd12", team: "team1")
        _mockUsers["demo1@example.com"] = User(username:"demo1@example.com", password: "P@ssw0rd12", team: "team1")
        _mockUsers["demo2@example.com"] = User(username:"demo2@example.com", password: "P@ssw0rd12", team: "team2")
        _mockUsers["demo3@example.com"] = User(username:"demo3@example.com", password: "P@ssw0rd12", team: "team2")
        _mockUsers["demo4@example.com"] = User(username:"demo4@example.com", password: "P@ssw0rd12", team: "team3")
        _mockUsers["demo5@example.com"] = User(username:"demo5@example.com", password: "P@ssw0rd12", team: "team3")
        _mockUsers["demo6@example.com"] = User(username:"demo6@example.com", password: "P@ssw0rd12", team: "team4")
        _mockUsers["demo7@example.com"] = User(username:"demo7@example.com", password: "P@ssw0rd12", team: "team4")
        _mockUsers["demo8@example.com"] = User(username:"demo8@example.com", password: "P@ssw0rd12", team: "team5")
        _mockUsers["demo9@example.com"] = User(username:"demo9@example.com", password: "P@ssw0rd12", team: "team5")
        _mockUsers["demo10@example.com"] = User(username:"demo10@example.com", password: "P@ssw0rd12", team: "team6")
        _mockUsers["demo11@example.com"] = User(username:"demo11@example.com", password: "P@ssw0rd12", team: "team6")
        _mockUsers["demo12@example.com"] = User(username:"demo12@example.com", password: "P@ssw0rd12", team: "team7")
        _mockUsers["demo13@example.com"] = User(username:"demo13@example.com", password: "P@ssw0rd12", team: "team8")
        _mockUsers["demo14@example.com"] = User(username:"demo14@example.com", password: "P@ssw0rd12", team: "team9")
        _mockUsers["demo15@example.com"] = User(username:"demo15@example.com", password: "P@ssw0rd12", team: "team10")
        _mockUsers["demo16@example.com"] = User(username:"demo16@example.com", password: "P@ssw0rd12", team: "team10")
        _mockUsers["demo17@example.com"] = User(username:"demo17@example.com", password: "P@ssw0rd12", team: "team10")
        _mockUsers["demo18@example.com"] = User(username:"demo18@example.com", password: "P@ssw0rd12", team: "team10")
        _mockUsers["demo19@example.com"] = User(username:"demo19@example.com", password: "P@ssw0rd12", team: "team10")
        _mockUsers["demo20@example.com"] = User(username:"demo20@example.com", password: "P@ssw0rd12", team: "team10")

    }
    
    var isAuthenticated = false {
        didSet {
            objectWillChange.send()
        }
    }

    func getCurrentUser() -> User? {
        return currentUser
    }
    
    func authenticateUser(username: String, password: String) -> Bool {
        if let user = _mockUsers[username], user.password == password {
            isAuthenticated = true
            currentUser = user
            return true
        } else {
            isAuthenticated = false
            currentUser = nil
            return false
        }
    }
    
    func logout() {
       currentUser = nil
    }
}

