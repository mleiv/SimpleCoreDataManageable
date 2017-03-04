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
    public static var current: SimpleCoreDataManager = SimpleCoreDataManager(storeName: defaultStoreName)

    public static var isManageMigrations: Bool = false // automatic migrations
    
    public let storeName: String
    public let persistentContainer: NSPersistentContainer
    public let specificContext: NSManagedObjectContext?
    public var isConfinedToMemoryStore: Bool = false
    
    public init() {
        self.init(storeName: SimpleCoreDataManager.defaultStoreName)
    }
    
    public init(storeName: String?, context: NSManagedObjectContext?, isConfineToMemoryStore: Bool) {
        self.isConfinedToMemoryStore = isConfineToMemoryStore
        self.storeName = storeName ?? SimpleCoreDataManager.defaultStoreName
        self.specificContext = context
        if let storeName = storeName {
            self.persistentContainer = NSPersistentContainer(name: storeName)
            initContainer(isConfineToMemoryStore: isConfineToMemoryStore)
        } else {
            persistentContainer = SimpleCoreDataManager.current.persistentContainer
        }
    }
}
