//
//  SimpleCoreDataStorable.swift
//
//  Copyright 2017 Emily Ivie

//  Licensed under The MIT License
//  For full copyright and license information, please see http://opensource.org/licenses/MIT
//  Redistributions of files must retain the above copyright notice.


import CoreData

// https://bugs.swift.org/browse/SR-2359

/// A protocol for describing that can be stored in core data using the CoreDataManager
public protocol SimpleCoreDataStorable: class {

// MARK: Required
    /// Define in the object itself. 
    /// Should be the name of the CoreData table.
    static var coreDataEntityName: String { get }
    
// MARK: Optional
    
    /// A reference to the current core data manager.
    static var defaultCoreDataManager: SimpleCoreDataManageable { get }
    
    /// Gets one matching item from core data.
    static func get<T: NSManagedObject>(
        coreDataManager: SimpleCoreDataManageable?,
        alterFetchRequest: @escaping AlterFetchRequestClosure<T>
    ) -> T?

    /// Gets all the matching items from core data.
    static func getAll<T: NSManagedObject>(
        coreDataManager: SimpleCoreDataManageable?,
        alterFetchRequest: @escaping AlterFetchRequestClosure<T>
    ) -> [T]
    
    /// Create a new item from core data.
    static func create<T: NSManagedObject>(
        coreDataManager: SimpleCoreDataManageable?,
        setInitialValues: @escaping SetAdditionalColumnsClosure<T>
    ) -> T?

    /// Saves the item to core data.
    func saveChanges<T: NSManagedObject>(
        coreDataManager: SimpleCoreDataManageable?,
        setChangedValues: @escaping SetAdditionalColumnsClosure<T>
    ) -> Bool
    
    /// Deletes the item from core data.
    func delete(
        coreDataManager: SimpleCoreDataManageable?
    ) -> Bool

    /// Deletes all the items from core data.
    static func deleteAll<T: NSManagedObject>(
        coreDataManager: SimpleCoreDataManageable?,
        alterFetchRequest: @escaping AlterFetchRequestClosure<T>
    ) -> Bool
    
    /// Deletes everything from core data entity.
    static func truncateTable()
}

extension SimpleCoreDataStorable {

    // Default implementation. Can be removed if we ever fix Class/Protocol conformance bug.
    public static var coreDataEntityName: String { return "Unknown" }
}

extension SimpleCoreDataStorable where Self: NSManagedObject {

    /// Convenience - get the static version for easy instance reference.
    public var defaultCoreDataManager: SimpleCoreDataManageable {
        return Self.defaultCoreDataManager
    }
    
    /// Protocol conformance.
    /// Gets one matching item from core data.
    public static func get<T: NSManagedObject>(
        coreDataManager: SimpleCoreDataManageable?,
        alterFetchRequest: @escaping AlterFetchRequestClosure<T>
    ) -> T? {
        return _get(coreDataManager: coreDataManager, alterFetchRequest: alterFetchRequest)
    }

    /// Convenience version of get:coreDataManager:alterFetchRequest (no parameters required).
    public static func get<T: NSManagedObject>(
        alterFetchRequest: @escaping AlterFetchRequestClosure<T>
    ) -> T? {
        return get(coreDataManager: nil, alterFetchRequest: alterFetchRequest)
    }
    
    /// Root version of get:coreDataManager:alterFetchRequest (you can still call this if you override that).
    ///
    /// DO NOT OVERRIDE.
    public static func _get<T: NSManagedObject>(
        coreDataManager: SimpleCoreDataManageable?,
        alterFetchRequest: @escaping AlterFetchRequestClosure<T>
    ) -> T? {
        let manager = coreDataManager ?? defaultCoreDataManager
        let one: T? = manager.getOne(alterFetchRequest: alterFetchRequest)
        return one
    }

    /// Protocol conformance.
    /// Gets all the matching items from core data.
    public static func getAll<T: NSManagedObject>(
        coreDataManager: SimpleCoreDataManageable?,
        alterFetchRequest: @escaping AlterFetchRequestClosure<T>
    ) -> [T] {
        return _getAll(coreDataManager: coreDataManager, alterFetchRequest: alterFetchRequest)
    }
    
    /// Convenience version of getAll:coreDataManager:alterFetchRequest (no parameters required).
    public static func getAll<T: NSManagedObject>(
        alterFetchRequest: @escaping AlterFetchRequestClosure<T> = { _ in }
    ) -> [T] {
        return getAll(coreDataManager: nil, alterFetchRequest: alterFetchRequest)
    }
    
    /// Root version of get:coreDataManager:alterFetchRequest (you can still call this if you override that).
    ///
    /// DO NOT OVERRIDE.
    public static func _getAll<T: NSManagedObject>(
        coreDataManager: SimpleCoreDataManageable? = nil,
        alterFetchRequest: @escaping AlterFetchRequestClosure<T>
    ) -> [T] {
        let manager = coreDataManager ?? defaultCoreDataManager
        let all: [T] = manager.getAll(alterFetchRequest: alterFetchRequest)
        return all
    }
    
    /// Protocol conformance.
    /// Create a new item from core data.
    public static func create<T: NSManagedObject>(
        coreDataManager: SimpleCoreDataManageable?,
        setInitialValues: @escaping SetAdditionalColumnsClosure<T>
    ) -> T? {
        return _create(coreDataManager: coreDataManager, setInitialValues: setInitialValues)
    }
    
    /// Convenience version of create:coreDataManager:setInitialValues (coreDataManager not required).
    public static func create<T: NSManagedObject>(
        setInitialValues: @escaping SetAdditionalColumnsClosure<T>
    ) -> T? {
        return create(coreDataManager: nil, setInitialValues: setInitialValues)
    }
    
    /// Root version of create:coreDataManager (you can still call this if you override that).
    ///
    /// DO NOT OVERRIDE.
    public static func _create<T: NSManagedObject>(
        coreDataManager: SimpleCoreDataManageable? = nil,
        setInitialValues: @escaping SetAdditionalColumnsClosure<T>
    ) -> T? {
        let manager = coreDataManager ?? defaultCoreDataManager
        let one: T? = manager.createOne(coreDataEntityName: Self.coreDataEntityName, setInitialValues: setInitialValues)
        return one
    }
    
    /// Protocol conformance.
    /// Saves the item to core data.
    public func saveChanges<T: NSManagedObject>(
        coreDataManager: SimpleCoreDataManageable?,
        setChangedValues: @escaping SetAdditionalColumnsClosure<T>
    ) -> Bool {
        guard let item = self as? T else { return false }
        let manager = coreDataManager ?? defaultCoreDataManager
        let isSaved = manager.saveChanges(item: item, setChangedValues: setChangedValues)
        return isSaved
    }
    
    /// Convenience version of save:coreDataManager (no coreDataManager required).
    public func saveChanges<T: NSManagedObject>(
        setChangedValues: @escaping SetAdditionalColumnsClosure<T>
    ) -> Bool {
        return saveChanges(coreDataManager: nil, setChangedValues: setChangedValues)
    }
    
    /// Protocol conformance.
    /// Deletes the item from core data.
    public func delete(
        coreDataManager: SimpleCoreDataManageable?
    ) -> Bool {
        let manager = coreDataManager ?? defaultCoreDataManager
        let isDeleted = manager.deleteOne(item: self)
        return isDeleted
    }
    
    /// Convenience version of delete:coreDataManager (no parameters required).
    public func delete() -> Bool {
        return delete(coreDataManager: nil)
    }

    /// Protocol conformance.
    /// Deletes all the items from core data.
    public static func deleteAll<T: NSManagedObject>(
        coreDataManager: SimpleCoreDataManageable?,
        alterFetchRequest: @escaping AlterFetchRequestClosure<T>
    ) -> Bool {
        let manager = coreDataManager ?? defaultCoreDataManager
        return manager.deleteAll(itemType: T.self, alterFetchRequest: alterFetchRequest)
    }
    
    /// Convenience version of deleteAll:coreDataManager:alterFetchRequest (coreDataManager not required).
    public static func deleteAll<T: NSManagedObject>(
        alterFetchRequest: @escaping AlterFetchRequestClosure<T>
    ) -> Bool {
        return deleteAll(coreDataManager: nil, alterFetchRequest: alterFetchRequest)
    }
    
    /// Convenience version of deleteAll:coreDataManager:alterFetchRequest (no parameters required).
    public static func deleteAll() -> Bool {
        let defaultClosure: AlterFetchRequestClosure<Self> = { _ in }
        return deleteAll(coreDataManager: nil, alterFetchRequest: defaultClosure)
    }
    
    /// Protocol conformance.
    /// Deletes everything from core data entity.
    public static func truncateTable() {
        _ = defaultCoreDataManager.truncateTable(itemType: Self.self)
    }
}
