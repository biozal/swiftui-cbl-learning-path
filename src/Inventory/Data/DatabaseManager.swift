//
//  DatabaseManager.swift
//  Inventory
//
//  Created by Aaron LaBeau on 8/29/23.
//

import Foundation
import CouchbaseLiteSwift

class DatabaseManager 
    : ObservableObject {
    
    //inventory audits
    var inventoryDatabase: Database?
    var auditCollection: Collection?
    var projectCollection: Collection?
    var userProfileCollection: Collection?
    var stockItemCollection: Collection?
    var scope: Scope?
    
    //warehouse locations
    var warehousesDatabase: Database?
    var locationsCollection: Collection?
    
    //local database for storage
    var applicationDocumentDirectory = URL.documentsDirectory.path()
    
    //prebuilt database that is embedded in the app
    fileprivate var _applicationSupportDirectory = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).last
    
    //database, colleciton, and scope names
    let defaultInventoryDatabaseName = "inventory"
    let warehouseDatabaseName = "warehouse"
    let pbWarehousesDatabaseName = "pbwarehouses"
    var currentInventoryDatabaseName = "inventory"
    
    let defaultScopeName = "auditor"
    let projectCollectionName = "projects"
    let auditItemsCollectionName = "auditItems"
    let userProfileCollectionName = "userProfiles"
    let stockItemsCollectionName = "stockItems"
    let locationsCollectionName = "locations"
    
    //for warehouse prebuilt db
    let warehouseScopeName = "warehouses"
    let warehouseCollectionName = "locations"
    
    //indexes for query
    let teamIndexName = "idxTeam"
    let teamAttribute = "team"
    let auditIndexName = "idxAudit"
    let projectIdAttributeName = "projectId"
    
    //indexes for query for warehouse locations
    let cityIndexName = "idxCity"
    let cityAttribute = "city"
    let cityStateIndexName = "idxCityState"
    let stateAttribute = "state"
    let locationTypeAttribute = "locationType"
    
    init() {
        //this will log EVERYTHING - it's a lot of information to go through
        //only turn on if debugging
        #if DEBUG
            Database.log.console.domains = .all
            Database.log.console.level = .verbose
        #endif
    }
    
    deinit {
        closeDatabases()
    }
    
    func closeDatabases () {
        do {
            try self.inventoryDatabase?.close()
            try self.warehousesDatabase?.close()
        } catch {
        #if DEBUG
            print ("error closing databases: \(error)")
        #endif
        }
    }
}

// MARK: manage databases
extension DatabaseManager {
    
    func deleteDatabases() {
        do {
            try inventoryDatabase?.delete()
            try warehousesDatabase?.delete()
        } catch {
        #if DEBUG
            print("error: deleting databases")
        #endif
        }
    }
    
    func initializeDatabases(user: User) async {
        let task = Task(priority: .background) { [weak self] in
            do {
                if let applicationDocumentDirectory = self?.applicationDocumentDirectory,
                   let defaultInventoryDatabaseName = self?.defaultInventoryDatabaseName {
                    
                    var config = DatabaseConfiguration()
                    config.directory = applicationDocumentDirectory
                    
                    // create or open a database to share between team members to store
                    // projects, assets, and user profiles
                    // calculate database name based on current logged in users team name
                    let teamName = user.team.replacingOccurrences(of: " ", with: "")
                    let currentInventoryDatabaseName = teamName + "_" + defaultInventoryDatabaseName
                    
                    self?.inventoryDatabase = try Database(name: currentInventoryDatabaseName, config: config)
                    
                    self?.currentInventoryDatabaseName = currentInventoryDatabaseName
                    
                    //if collections don't exist create them
                    self?.setupCollections()
                    
                    //setup the warehouse database from the prebuild
                    await self?.setupWarehouseDatabase(config: config)
                    
                    //create indexes
                    await self?.createAuditIndexes()
                    await self?.createWarehouseDatabaseIndexes()
                }
                
            } catch {
                #if DEBUG
                print ("Error opening database \(error)")
                #endif
            }
        }
        await task.value
    }
    
    func setupWarehouseDatabase(config: DatabaseConfiguration) async {
        let task = Task(priority: .background) { [weak self] in
            do {
                if let appDocumentationDirectory = self?.applicationDocumentDirectory,
                   let warehouseDatabaseName = self?.warehouseDatabaseName,
                   let pbWarehousesDatabaseName = self?.pbWarehousesDatabaseName {
                    
                    // if database doesn't exist, load prebuilt database from App Bundle and copy over to path
                    if Database.exists(withName: warehouseDatabaseName, inDirectory: appDocumentationDirectory) == false {
                        if let prebuiltPath = Bundle.main.path(forResource: pbWarehousesDatabaseName, ofType: "cblite2") {
                            try Database.copy(fromPath: prebuiltPath, toDatabase: "\(warehouseDatabaseName)", withConfig: config)
                        }
                        
                        // Get handle to DB  specified path
                        self?.warehousesDatabase = try Database(name: warehouseDatabaseName, config: config)
                        
                        // Create indexes to facilitate queries
                        await self?.createWarehouseDatabaseIndexes()
                    }
                    else
                    {
                        // Gets handle to existing DB at specified path
                        self?.warehousesDatabase = try Database(name: warehouseDatabaseName, config: config)
                    }
                    
                    //try to set the collection for use
                    if let db = self?.warehousesDatabase,
                       let collection = self?.warehouseCollectionName,
                       let scope = self?.warehouseScopeName {
                        self?.locationsCollection = try db.collection(name: collection, scope: scope)
                    }
                }
            } catch {
                #if DEBUG
                print ("error trying to open prebuilt database \(error)")
                #endif
            }
        }
        await task.value
    }
    
    func createAuditIndexes () async {
        let task = Task(priority: .background) { [weak self] in
            do {
                if let collection = self?.auditCollection,
                let projectIdAttributeName = self?.projectIdAttributeName,
                let teamAttribute = self?.teamAttribute,
                let auditIndexName = self?.auditIndexName {
                    let indexConfig = ValueIndexConfiguration([projectIdAttributeName, teamAttribute])
                    try collection.createIndex(withName: auditIndexName, config: indexConfig)
                }
            } catch {
                #if DEBUG
                print ("Error creating audit indexes: \(error)")
                #endif
            }
        }
        await task.value
    }
    
    func createWarehouseDatabaseIndexes() async {
        let task = Task(priority: .background)  { [weak self] in
            do {
                if let collection = self?.locationsCollection,
                   let cityAttribute = self?.cityAttribute,
                   let stateAttribute = self?.stateAttribute,
                   let locationTypeAttribute = self?.locationTypeAttribute,
                   let cityStateIndexName = self?.cityStateIndexName {
                    let indexConfig = ValueIndexConfiguration([cityAttribute, stateAttribute, locationTypeAttribute])
                    try collection.createIndex(withName: cityStateIndexName, config: indexConfig)
                }
            } catch {
                #if DEBUG
                print ("Error creating warehouse database index \(error)")
                #endif
            }
        }
        await task.value
    }
    
    func setupCollections() {
        do {
            let collections = try inventoryDatabase?.collections(scope: defaultScopeName)
            if (collections == nil || collections?.count == 0) {
                projectCollection = try inventoryDatabase?.createCollection(name: projectCollectionName, scope: defaultScopeName)
                auditCollection = try inventoryDatabase?.createCollection(name: auditItemsCollectionName, scope: defaultScopeName)
                userProfileCollection = try inventoryDatabase?.createCollection(name: userProfileCollectionName, scope: defaultScopeName)
            } else {
                projectCollection = try inventoryDatabase?.collection(name: projectCollectionName, scope: defaultScopeName)
                auditCollection = try inventoryDatabase?.collection(name: auditItemsCollectionName, scope: defaultScopeName)
                userProfileCollection = try inventoryDatabase?.collection(name: userProfileCollectionName, scope: defaultScopeName)
            }
            
        } catch {
            #if DEBUG
            print ("Error opening or creating collections: \(error)")
            #endif
        }
    }
    
    func collectionCount() -> Int {
        do {
            let collections = try inventoryDatabase?.collections(scope: defaultScopeName)
            if let collectionCount = collections?.count {
                return collectionCount
            }
        } catch {
            #if DEBUG
            print ("Error counting collections: \(error)")
            #endif
        }
        return 0
    }
}
