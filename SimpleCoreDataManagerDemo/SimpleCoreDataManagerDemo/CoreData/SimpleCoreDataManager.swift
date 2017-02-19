//
//  SimpleCoreDataManager.swift
//
//  Copyright 2017 Emily Ivie

//  Licensed under The MIT License
//  For full copyright and license information, please see http://opensource.org/licenses/MIT
//  Redistributions of files must retain the above copyright notice.

import CoreData

struct SimpleCoreDataManager: SimpleCoreDataManageable {
    public static let defaultStoreName = "SimpleCoreDataManagerDemo"
    public static var current: SimpleCoreDataManageable = SimpleCoreDataManager(storeName: defaultStoreName)
    
    public static var isConfineToMemoryStore: Bool = false // set to true for testing
    public static var isManageMigrations: Bool = true // we manage migrations
    
    public let storeName: String
    public let persistentContainer: NSPersistentContainer
    public let specificContext: NSManagedObjectContext?
    
    public init(storeName: String?, context: NSManagedObjectContext?) {
        self.storeName = storeName ?? SimpleCoreDataManager.defaultStoreName
        self.specificContext = context
        if let storeName = storeName {
            self.persistentContainer = NSPersistentContainer(name: storeName)
            initContainer()
        } else {
            persistentContainer = SimpleCoreDataManager.current.persistentContainer
        }
    }
}
