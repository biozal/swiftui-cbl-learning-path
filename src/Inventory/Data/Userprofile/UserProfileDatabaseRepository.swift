//
//  UserProfileDatabaseRepository.swift
//  Inventory
//
//  Created by Aaron LaBeau on 8/29/23.
//

import Foundation
import CouchbaseLiteSwift
import Combine

class UserProfileDatabaseRepository
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
    
    func count() async -> Int {
        let task = Task(priority: .background) { [weak self] in
            var count = 0
            do {
                if let dbManager = self?.databaseManager,
                   let countKey = self?.countKey,
                   let db = dbManager.inventoryDatabase {
                    let query = "SELECT COUNT (*) as \(countKey) FROM \(dbManager.defaultScopeName).\(dbManager.userProfileCollectionName)"
                    let results = try db.createQuery(query).execute().allResults()
                    count = results[0].int(forKey: countKey)
                }
            } catch {
                print ("Error trying to count user profiles: \(error)")
            }
            return count
        }
        return await task.value
    }
    
    func get(currentUser: String) async -> [String : Any] {
        let task = Task(priority: .background) { [weak self] in
            //if no record is found we will at least return the dictionary with
            //the email field filled out
            var results: [String: Any] = [:]
            
            //try and get user profile document
            do {
                if let emailKey = self?.emailKey {
                    results[emailKey] = currentUser
                    if let collection = self?.databaseManager.userProfileCollection,
                       let documentId = self?.getCurrentUserDocumentId(currentUser: currentUser),
                       let doc = try collection.document(id: documentId){
                        if let idKey = self?.idKey {
                            results[idKey] = documentId
                        }
                        if let givenNameKey = self?.givenNameKey,  doc.contains(key: givenNameKey){
                            results[givenNameKey] = doc.string(forKey: givenNameKey)
                        }
                        if let surnameKey = self?.surnameKey, doc.contains(key: surnameKey){
                            results[surnameKey] = doc.string(forKey: surnameKey)
                        }
                        if let jobTitleKey = self?.jobTitleKey, doc.contains(key: jobTitleKey){
                            results[jobTitleKey] = doc.string(forKey: jobTitleKey)
                        }
                        if let teamKey = self?.teamKey, doc.contains(key: teamKey){
                            results[teamKey] = doc.string(forKey: teamKey)
                        }
                        if let imageDataKey = self?.imageDataKey, doc.contains(key: imageDataKey),
                           let blob = doc.blob(forKey: imageDataKey) {
                            let data = blob.content! as Data
                            results[imageDataKey] = data
                        }
                    }
                }
            } catch {
                print ("Error trying to get the user profile for \(currentUser): \(error)")
            }
            return results
        }
        return await task.value
    }
    
    func save(data: [String : Any]) async -> Bool {
        let task = Task(priority: .background)  { [weak self] in
            var result = false
            //try to save a user profile document
            do {
                if let emailKey = self?.emailKey,
                   data.keys.contains(emailKey),
                   let email = data[emailKey] as? String,
                   !email.isEmpty,
                   let dbManager = self?.databaseManager,
                   let collection = self?.databaseManager.userProfileCollection {
                    
                    let documentId = self?.getCurrentUserDocumentId(currentUser: email)
                    let mutableDocument = MutableDocument.init(id: documentId )
                    mutableDocument.setString(email, forKey: emailKey)
                    
                    if let givenNameKey = self?.givenNameKey,
                       let givenName = data[givenNameKey] as? String {
                        mutableDocument.setString(givenName, forKey: givenNameKey)
                    }
                    if let surnameKey = self?.surnameKey,
                       let surname = data[surnameKey] as? String {
                        mutableDocument.setString(surname, forKey: surnameKey)
                    }
                    if let jobTitleKey = self?.jobTitleKey,
                       let jobTitle = data[jobTitleKey] as? String {
                        mutableDocument.setString(jobTitle, forKey: jobTitleKey)
                    }
                    if let teamKey = self?.teamKey,
                       let team = data[teamKey] as? String {
                        mutableDocument.setString(team, forKey: teamKey)
                    }
                    if let imageDataKey = self?.imageDataKey,
                       let imageData = data[imageDataKey] as? Data {
                        let blob = Blob.init(contentType: "image/jpeg", data: imageData)
                        mutableDocument.setBlob(blob, forKey: imageDataKey)
                    }
                    try collection.save(document: mutableDocument)
                    
                    //NOTE:  this is a performance hit and should only be done when using blobs and you think the image will change
                    //in case the image was changed, we must compact the database to remove the previous file attachment reference and remove previous physical file.
                    try dbManager.inventoryDatabase?.performMaintenance(type: .compact)
                    result = true
                }
            } catch {
                print ("Error trying to save the user profile: \(error)")
            }
            return result
        }
        return await task.value
    }
    
    func getCurrentUserDocumentId(currentUser: String) -> String {
        return userIdPrefix + currentUser
    }
    
}
