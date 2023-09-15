//
//  UserProfileDatabaseRepository.swift
//  Inventory
//
//  Created by Aaron LaBeau on 8/29/23.
//

import Foundation
import CouchbaseLiteSwift

@RepositoryActor class UserProfileDatabaseRepository
: UserProfileRepository {
    var databaseManager: DatabaseManager
    
    let userIdPrefix = "user::"
    
    //keys of dictionary for user profiles
    let idKey = "id"
    let emailKey = "email"
    let givenNameKey = "givenName"
    let surnameKey = "surname"
    let jobTitleKey = "jobTitle"
    let teamKey = "team"
    let imageDataKey = "imageData"
    let countKey = "count"
    
    init(databaseManager: DatabaseManager){
        self.databaseManager = databaseManager
    }
    
    func count() async throws -> Int {
        var count = 0
        do {
            if let db = databaseManager.inventoryDatabase {
                let query = "SELECT COUNT (*) as \(countKey) FROM \(databaseManager.defaultScopeName).\(databaseManager.userProfileCollectionName)"
                let results = try db.createQuery(query).execute().allResults()
                count = results[0].int(forKey: countKey)
            }
        } catch {
            print ("Error trying to count user profiles: \(error)")
            throw error
        }
        return count
    }
    
    func get(currentUser: String) async throws -> [String : Any] {
        //TODO : Fix this replace with actor code
        //if no record is found we will at least return the dictionary with
        //the email field filled out
        var results: [String: Any] = [:]
        
        //try and get user profile document
        do {
            results[emailKey] = currentUser
            let documentId = getCurrentUserDocumentId(currentUser: currentUser)
            if let collection = databaseManager.userProfileCollection,
               let doc = try collection.document(id: documentId){
                results[idKey] = documentId
                if doc.contains(key: givenNameKey){
                    results[givenNameKey] = doc.string(forKey: givenNameKey)
                }
                if doc.contains(key: surnameKey){
                    results[surnameKey] = doc.string(forKey: surnameKey)
                }
                if doc.contains(key: jobTitleKey){
                    results[jobTitleKey] = doc.string(forKey: jobTitleKey)
                }
                if doc.contains(key: teamKey){
                    results[teamKey] = doc.string(forKey: teamKey)
                }
                if doc.contains(key: imageDataKey),
                   let blob = doc.blob(forKey: imageDataKey) {
                    let data = blob.content! as Data
                    results[imageDataKey] = data
                }
            }
        } catch {
            print ("Error trying to get the user profile for \(currentUser): \(error)")
            throw error
        }
        return results
    }
    
    func save(data: [String : Any]) async throws -> Bool {
        var result = false
        //try to save a user profile document
        do {
            if data.keys.contains(emailKey),
               let email = data[emailKey] as? String,
               !email.isEmpty,
               let collection = databaseManager.userProfileCollection {
                
                let documentId = getCurrentUserDocumentId(currentUser: email)
                let mutableDocument = MutableDocument.init(id: documentId )
                mutableDocument.setString(email, forKey: emailKey)
                
                if let givenName = data[givenNameKey] as? String {
                    mutableDocument.setString(givenName, forKey: givenNameKey)
                }
                if let surname = data[surnameKey] as? String {
                    mutableDocument.setString(surname, forKey: surnameKey)
                }
                if let jobTitle = data[jobTitleKey] as? String {
                    mutableDocument.setString(jobTitle, forKey: jobTitleKey)
                }
                if let team = data[teamKey] as? String {
                    mutableDocument.setString(team, forKey: teamKey)
                }
                if let imageData = data[imageDataKey] as? Data {
                    let blob = Blob.init(contentType: "image/jpeg", data: imageData)
                    mutableDocument.setBlob(blob, forKey: imageDataKey)
                }
                try collection.save(document: mutableDocument)
                
                //NOTE:  this is a performance hit and should only be done when using blobs and you think the image will change
                //in case the image was changed, we must compact the database to remove the previous file attachment reference and remove previous physical file.
                try databaseManager.inventoryDatabase?.performMaintenance(type: .compact)
                result = true
            }
        } catch {
            print ("Error trying to save the user profile: \(error)")
            throw error
        }
        return result
    }
    
    func getCurrentUserDocumentId(currentUser: String) -> String {
        return userIdPrefix + currentUser
    }
    
}
