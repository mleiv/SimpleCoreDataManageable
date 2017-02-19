//
//  SimpleCoreDataManageable.swift
//
//  Copyright 2017 Emily Ivie

//  Licensed under The MIT License
//  For full copyright and license information, please see http://opensource.org/licenses/MIT
//  Redistributions of files must retain the above copyright notice.


import CoreData

public typealias AlterFetchRequestClosure<T: NSManagedObject> = ((NSFetchRequest<T>)->Void)
public typealias SetAdditionalColumnsClosure<T> = ((T)->Void)

/// Manages the storage and retrieval of CoreDataStorable/SerializableData objects.
public protocol SimpleCoreDataManageable {

//MARK: Required:

    /// A static core data container for easy/efficient access.
    /// FYI, this is only created when asked for.
    static var current: SimpleCoreDataManageable { get }
    /// Prevents any file saves - useful for testing.
    static var isConfineToMemoryStore: Bool { get }
    /// Prevents any automatic migrations - useful for heavy migrations.
    static var isManageMigrations: Bool { get }
    /// The store name of the current persistent store container.
    var storeName: String { get }
    /// This is managed for you - just declare it.
    var persistentContainer: NSPersistentContainer { get }
    /// Override the default context - useful when doing save/fetch in background.
    var specificContext: NSManagedObjectContext? { get }
    /// Implement this using the sample below, because protocols can't do this.
    init(storeName: String?, context: NSManagedObjectContext?)
    
//MARK: Already implemented:
    
    func runMigrations(storeUrl: URL)
    
// There's a bunch of other functions implemented below,
//    but right now I don't see a case for them being overridden, and I am lazy.
}

// MARK: Core data initialization functions
extension SimpleCoreDataManageable {
    
    public var context: NSManagedObjectContext { return specificContext ?? persistentContainer.viewContext }
    
    public init(storeName: String) {
        self.init(storeName: storeName, context: nil)
    }
    public init(context: NSManagedObjectContext?) {
        self.init(storeName: nil, context: context)
    }
//    // implement the following:
//    public init(storeName: String?, context: NSManagedObjectContext?) {
//        self.storeName = storeName ?? AppDelegate.coreDataStoreName
//        self.specificContext = context
//        if let storeName = storeName {
//            self.persistentContainer = NSPersistentContainer(name: storeName)
//            initContainer()
//        } else {
//            persistentContainer = CoreDataManager.current.persistentContainer
//        }
//    }
    
    /// Configure the persistent container.
    /// Also runs any manual migrations.
    public func initContainer() {
        let isConfineToMemoryStore = Self.isConfineToMemoryStore
        let isManageMigrations = Self.isManageMigrations
        
        // find our persistent store file
        guard let storeUrl = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first?.appendingPathComponent("\(storeName).sqlite") else {
            fatalError("Could not create path to \(storeName) sqlite")
        }
        
        // make any pending changes
        runMigrations(storeUrl: storeUrl)
        
        // Set some rules for this container
        let description = NSPersistentStoreDescription(url: storeUrl)
        if isManageMigrations {
            description.shouldMigrateStoreAutomatically = false
            description.shouldInferMappingModelAutomatically = false
        }
        if isConfineToMemoryStore {
            description.type = NSInMemoryStoreType
        }
        persistentContainer.persistentStoreDescriptions = [description]
        
        // load any existing stores
        persistentContainer.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
            self.initContext()
        })
    }
    
    /// Configure the primary context.
    public func initContext() {
        print("Using persistent store: \(persistentContainer.persistentStoreCoordinator.persistentStores.first?.url)")
        let context = self.persistentContainer.viewContext
        context.automaticallyMergesChangesFromParent = true // not triggered w/o autoreleasepool
        context.mergePolicy = NSMergePolicy.mergeByPropertyStoreTrump
//        try? context.setQueryGenerationFrom(.current)
    }

    /// Runs any manual migrations before initializing the persistent container.
    /// If you are still using light migrations, leave this empty.
    public func runMigrations(storeUrl: URL) {}
    
}

// MARK: Core data content functions
extension SimpleCoreDataManageable {
    
    /// Save the primary context to file. Call this before exiting app.
    public func save() {
        let moc = persistentContainer.viewContext
        moc.performAndWait {
            do {
                // save if changes found
                if moc.hasChanges {
                    try moc.save()
                }
            } catch {
                // this sucks, but not fatal IMO
                print("Unresolved error \(error)")
            }
        }
    }
    
    /// Retrieve single row with criteria closure.
    public func getOne<T: NSManagedObject>(
        alterFetchRequest: @escaping AlterFetchRequestClosure<T> = { _ in }
    ) -> T?  {
        let moc = context
        var result: T?
        moc.performAndWait { // performAndWait does not require autoreleasepool
            guard let fetchRequest = T.fetchRequest() as? NSFetchRequest<T> else { return }
            alterFetchRequest(fetchRequest)
            fetchRequest.fetchLimit = 1
            do {
                if let item = try fetchRequest.execute().first {
                    result = item
                }
            } catch let fetchError as NSError {
//                print("Error: get failed for \(T.coreDataEntityName): \(fetchError)")
                print("Error: get failed for \(T.self): \(fetchError)")
            }
        }
        return result
    }
    
    /// Retrieve multiple rows with criteria closure.
    public func getAll<T: NSManagedObject>(
        alterFetchRequest: @escaping AlterFetchRequestClosure<T>
    ) -> [T] {
        let moc = context
        var result: [T] = []
        moc.performAndWait { // performAndWait does not require autoreleasepool
            guard let fetchRequest = T.fetchRequest() as? NSFetchRequest<T> else { return }
            alterFetchRequest(fetchRequest)
            do {
                result = try fetchRequest.execute()
            } catch let fetchError as NSError {
//                print("Error: getAll failed for \(T.coreDataEntityName): \(fetchError)")
                print("Error: getAll failed: \(fetchError)")
            }
        }
        return result
    }
    
    /// Retrieve a count of matching entities
    public func getCount<T: NSManagedObject>(
        alterFetchRequest: @escaping AlterFetchRequestClosure<T>,
        itemType: T.Type
    ) -> Int {
        let moc = context
        var result = 0
        moc.performAndWait { // performAndWait does not require autoreleasepool
            guard let fetchRequest = T.fetchRequest() as? NSFetchRequest<T> else { return }
            alterFetchRequest(fetchRequest)
            do {
                result = try moc.count(for: fetchRequest)
            } catch let countError as NSError {
//                print("Error: getCount failed for \(T.coreDataEntityName): \(countError)")
                print("Error: getCount failed for \(T.self): \(countError)")
            }
        }
        return result
    }
    
    /// Retrieve faulted data for optimization.
    public func getAllFetchedResults<T: NSManagedObject>(
        alterFetchRequest: AlterFetchRequestClosure<T>,
        itemType: T.Type,
        sectionKey: String? = nil,
        cacheName: String? = nil
    ) -> NSFetchedResultsController<T>? {
        let moc = context
        guard let fetchRequest = T.fetchRequest() as? NSFetchRequest<T> else { return nil }
        alterFetchRequest(fetchRequest)
        
        let controller = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: moc, sectionNameKeyPath: sectionKey, cacheName: cacheName)
        
        do {
            try controller.performFetch()
            return controller
        } catch let fetchError as NSError {
//            print("Error: getAllFetchedResults failed for \(T.coreDataEntityName): \(fetchError)")
            print("Error: getAllFetchedResults failed for \(T.self): \(fetchError)")
        }
        
        return nil
    }
    
    /// Creates a new row of CoreData and returns a SimpleCoreDataStorable object.
    public func createOne<T: NSManagedObject>(
        setInitialValues: @escaping SetAdditionalColumnsClosure<T> = { _ in }
    ) -> T? {
        let moc = context
        var result: T?
        let waitForEndTask = DispatchWorkItem() {} // semaphore flag
        persistentContainer.performBackgroundTask { moc in
            defer { waitForEndTask.perform() }
            moc.automaticallyMergesChangesFromParent = true
            moc.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
            
            autoreleasepool {
                let coreItem = T(context: moc)
                setInitialValues(coreItem)
                print(coreItem)
                result = coreItem
            }
            
            do {
                try moc.save()
            } catch let createError as NSError {
//                print("Error: create failed for \(T.coreDataEntityName): \(createError)")
                print("Error: create failed for \(T.self): \(createError)")
                result = nil
            }
        }
        waitForEndTask.wait()
        if let result = result {
            return moc.object(with: result.objectID) as? T
        }
        return nil
    }

    /// Save a single row of an entity.
    public func saveChanges<T: NSManagedObject>(
        item: T,
        setChangedValues: @escaping SetAdditionalColumnsClosure<T>
    ) -> Bool {
        var result: Bool = false
        let waitForEndTask = DispatchWorkItem() {} // semaphore flag
        persistentContainer.performBackgroundTask { moc in
            defer { waitForEndTask.perform() }
            moc.automaticallyMergesChangesFromParent = true
            moc.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
            
            autoreleasepool {
                if let coreItem = moc.object(with: item.objectID) as? T {
                    // CAUTION: anything you do here *must* use the same context, 
                    // so if you are setting up relationships, create a new SimpleCoreDataManager 
                    // and use that to do any fetching/saving:
                    //
                    //     let localManager = SimpleCoreDataManager(context: coreItem.managedObjectContext)
                    //     coreItem.otherEntity = OtherEntity.get(coreDataManager: localManager) {
                    //         fetchRequest.predicate = NSPredicate(format: "(%K == %@)", #keyPath(OtherEntity.id), lookupId)
                    //     }
                    setChangedValues(coreItem)
                }
            }
            
            do {
                try moc.save()
                result = true
            } catch let saveError as NSError {
//                print("Error: save failed for \(T.coreDataEntityName): \(saveError)")
                print("Error: save failed for \(T.self): \(saveError)")
            }
        }
        waitForEndTask.wait()
        return result
    }
    
    /// Delete single row of a entity.
    public func deleteOne<T: NSManagedObject>(
        item: T
    ) -> Bool {
        var result: Bool = false
        let waitForEndTask = DispatchWorkItem() {} // semaphore flag
        persistentContainer.performBackgroundTask { moc in
            defer { waitForEndTask.perform() }
            moc.automaticallyMergesChangesFromParent = true
            moc.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
            autoreleasepool {
                let coreItem = moc.object(with: item.objectID)
                moc.delete(coreItem)
            }
            
            do {
                try moc.save()
                result = true
            } catch let deleteError as NSError{
//                print("Error: delete failed for \(T.coreDataEntityName): \(deleteError)")
                print("Error: delete failed for \(T.self): \(deleteError)")
            }
        }
        waitForEndTask.wait()
        return result
    }
    
    /// Remove all rows of an entity matching restrictions.
    public func deleteAll<T: NSManagedObject>(
        itemType: T.Type,
        alterFetchRequest: @escaping AlterFetchRequestClosure<T>
    ) -> Bool {
        var result: Bool = false
        let waitForEndTask = DispatchWorkItem() {} // semaphore flag
        persistentContainer.performBackgroundTask { moc in
            defer { waitForEndTask.perform() }
            moc.automaticallyMergesChangesFromParent = true
            moc.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
            
            guard let fetchRequest = T.fetchRequest() as? NSFetchRequest<T> else { return }
            alterFetchRequest(fetchRequest)
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest as! NSFetchRequest<NSFetchRequestResult>)
            
            do {
                try _ = moc.execute(deleteRequest) as? NSBatchDeleteResult
                try moc.save()
                result = true
            } catch let deleteError as NSError {
//                print("Error: deleteAll failed for \(T.coreDataEntityName): \(deleteError)")
                print("Error: deleteAll failed for \(T.self): \(deleteError)")
            }
        }
        waitForEndTask.wait()
        return result
    }
    
    /// Remove all rows of an entity.
    public func truncateTable<T: NSManagedObject>(
        itemType: T.Type
    ) -> Bool {
        return deleteAll(itemType: T.self, alterFetchRequest: { _ in })
    }
}
