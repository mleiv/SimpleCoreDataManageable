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
    static var defaultManager: SimpleCoreDataManageable { get }
    
    /// Gets one matching item from core data.
    static func get<T: NSManagedObject>(
        from manager: SimpleCoreDataManageable?,
        alterFetchRequest: @escaping AlterFetchRequest<T>
    ) -> T?
    
    /// Get a count of matching items from core data
    static func getCount<T: NSManagedObject>(
        from manager: SimpleCoreDataManageable?,
        alterFetchRequest: @escaping AlterFetchRequest<T>
    ) -> Int

    /// Gets all the matching items from core data.
    static func getAll<T: NSManagedObject>(
        from manager: SimpleCoreDataManageable?,
        alterFetchRequest: @escaping AlterFetchRequest<T>
    ) -> [T]
    
    /// Create a new item from core data.
    static func create<T: NSManagedObject>(
        from manager: SimpleCoreDataManageable?,
        setInitialValues: @escaping SetAdditionalColumns<T>
    ) -> T?

    /// Saves the item to core data.
    func saveChanges<T: NSManagedObject>(
        from manager: SimpleCoreDataManageable?,
        setChangedValues: @escaping SetAdditionalColumns<T>
    ) -> Bool
    
    /// Deletes the item from core data.
    func delete(
        from manager: SimpleCoreDataManageable?
    ) -> Bool

    /// Deletes all the items from core data.
    static func deleteAll<T: NSManagedObject>(
        from manager: SimpleCoreDataManageable?,
        alterFetchRequest: @escaping AlterFetchRequest<T>
    ) -> Bool
}

extension SimpleCoreDataStorable where Self: NSManagedObject {
    public typealias AlterFetchRequest<T: NSManagedObject> = ((NSFetchRequest<T>)->Void)
    public typealias SetAdditionalColumns<T: NSManagedObject> = ((T)->Void)

    /// Convenience - get the static version for easy instance reference.
    public var defaultManager: SimpleCoreDataManageable {
        return Self.defaultManager
    }
    
    /// Protocol conformance.
    /// Gets one matching item from core data.
    public static func get<T: NSManagedObject>(
        from manager: SimpleCoreDataManageable?,
        alterFetchRequest: @escaping AlterFetchRequest<T>
    ) -> T? {
        return _get(from: manager, alterFetchRequest: alterFetchRequest)
    }

    /// Convenience version of get:manager:alterFetchRequest (no parameters required).
    public static func get<T: NSManagedObject>(
        alterFetchRequest: @escaping AlterFetchRequest<T>
    ) -> T? {
        return get(from: nil, alterFetchRequest: alterFetchRequest)
    }
    
    /// Root version of get:manager:alterFetchRequest (you can still call this if you override that).
    ///
    /// DO NOT OVERRIDE.
    public static func _get<T: NSManagedObject>(
        from manager: SimpleCoreDataManageable?,
        alterFetchRequest: @escaping AlterFetchRequest<T>
    ) -> T? {
        let manager = manager ?? defaultManager
        let one: T? = manager.getOne(alterFetchRequest: alterFetchRequest)
        return one
    }

    /// Protocol conformance.
    /// Get a count of matching items from core data
    public static func getCount<T: NSManagedObject>(
        from manager: SimpleCoreDataManageable?,
        alterFetchRequest: @escaping AlterFetchRequest<T>
    ) -> Int {
        let manager = manager ?? defaultManager
        return manager.getCount(alterFetchRequest: alterFetchRequest)
    }
    
    /// Convenience version of getCount:manager:alterFetchRequest (manager not required).
    public static func getCount<T: NSManagedObject>(
        alterFetchRequest: @escaping AlterFetchRequest<T>
    ) -> Int {
        return getCount(from: nil, alterFetchRequest: alterFetchRequest)
    }
    
    /// Convenience version of getCount:manager:alterFetchRequest (no parameters required).
    public static func getCount() -> Int {
        let defaultClosure: AlterFetchRequest<Self> = { _ in }
        return getCount(from: nil, alterFetchRequest: defaultClosure)
    }

    /// Protocol conformance.
    /// Gets all the matching items from core data.
    public static func getAll<T: NSManagedObject>(
        from manager: SimpleCoreDataManageable?,
        alterFetchRequest: @escaping AlterFetchRequest<T>
    ) -> [T] {
        return _getAll(from: manager, alterFetchRequest: alterFetchRequest)
    }
    
    /// Convenience version of getAll:manager:alterFetchRequest (no parameters required).
    public static func getAll<T: NSManagedObject>(
        alterFetchRequest: @escaping AlterFetchRequest<T> = { _ in }
    ) -> [T] {
        return getAll(from: nil, alterFetchRequest: alterFetchRequest)
    }
    
    /// Root version of get:manager:alterFetchRequest (you can still call this if you override that).
    ///
    /// DO NOT OVERRIDE.
    public static func _getAll<T: NSManagedObject>(
        from manager: SimpleCoreDataManageable? = nil,
        alterFetchRequest: @escaping AlterFetchRequest<T>
    ) -> [T] {
        let manager = manager ?? defaultManager
        let all: [T] = manager.getAll(alterFetchRequest: alterFetchRequest)
        return all
    }
    
    /// Protocol conformance.
    /// Create a new item from core data.
    public static func create<T: NSManagedObject>(
        from manager: SimpleCoreDataManageable?,
        setInitialValues: @escaping SetAdditionalColumns<T>
    ) -> T? {
        return _create(from: manager, setInitialValues: setInitialValues)
    }
    
    /// Convenience version of create:manager:setInitialValues (manager not required).
    public static func create<T: NSManagedObject>(
        setInitialValues: @escaping SetAdditionalColumns<T>
    ) -> T? {
        return create(from: nil, setInitialValues: setInitialValues)
    }
    
    /// Root version of create:manager (you can still call this if you override that).
    ///
    /// DO NOT OVERRIDE.
    public static func _create<T: NSManagedObject>(
        from manager: SimpleCoreDataManageable? = nil,
        setInitialValues: @escaping SetAdditionalColumns<T>
    ) -> T? {
        let manager = manager ?? defaultManager
        let one: T? = manager.createOne(setInitialValues: setInitialValues)
        return one
    }
    
    /// Protocol conformance.
    /// Saves the item to core data.
    public func saveChanges<T: NSManagedObject>(
        from manager: SimpleCoreDataManageable?,
        setChangedValues: @escaping SetAdditionalColumns<T>
    ) -> Bool {
        guard let item = self as? T else { return false }
        let manager = manager ?? defaultManager
        let isSaved = manager.saveChanges(item: item, setChangedValues: setChangedValues)
        return isSaved
    }
    
    /// Convenience version of save:manager (no manager required).
    public func saveChanges<T: NSManagedObject>(
        setChangedValues: @escaping SetAdditionalColumns<T>
    ) -> Bool {
        return saveChanges(from: nil, setChangedValues: setChangedValues)
    }
    
    /// Protocol conformance.
    /// Deletes the item from core data.
    public func delete(
        from manager: SimpleCoreDataManageable?
    ) -> Bool {
        let manager = manager ?? defaultManager
        let isDeleted = manager.deleteOne(item: self)
        return isDeleted
    }
    
    /// Convenience version of delete:manager (no parameters required).
    public func delete() -> Bool {
        return delete(from: nil)
    }

    /// Protocol conformance.
    /// Deletes all the items from core data.
    public static func deleteAll<T: NSManagedObject>(
        from manager: SimpleCoreDataManageable?,
        alterFetchRequest: @escaping AlterFetchRequest<T>
    ) -> Bool {
        let manager = manager ?? defaultManager
        return manager.deleteAll(alterFetchRequest: alterFetchRequest)
    }
    
    /// Convenience version of deleteAll:manager:alterFetchRequest (manager not required).
    public static func deleteAll<T: NSManagedObject>(
        alterFetchRequest: @escaping AlterFetchRequest<T>
    ) -> Bool {
        return deleteAll(from: nil, alterFetchRequest: alterFetchRequest)
    }
    
    /// Convenience version of deleteAll:manager:alterFetchRequest (no parameters required).
    public static func deleteAll() -> Bool {
        let defaultClosure: AlterFetchRequest<Self> = { _ in }
        return deleteAll(from: nil, alterFetchRequest: defaultClosure)
    }
}
