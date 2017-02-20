//
//  Person.swift
//
//  Copyright 2017 Emily Ivie

//  Licensed under The MIT License
//  For full copyright and license information, please see http://opensource.org/licenses/MIT
//  Redistributions of files must retain the above copyright notice.

import CoreData

/// I am not sure what the rules are that determine when you need to explicitly export the Core Data code for a Swift entity (like you do for objc), but so far all I haven't had to do it at all.
extension Person: SimpleCoreDataStorable {

    public static var coreDataEntityName: String { return "Person" }
    
    public static var defaultManager: SimpleCoreDataManageable { return SimpleCoreDataManager.current }
    
    public static func create(
        from manager: SimpleCoreDataManageable? = nil
    ) -> Person? {
        return Person.create(from: manager) { (person: Person) in
            person.id = "\(UUID())"
            person.name = "Unknown"
        }
    }
    
    public static func get(
        id: String,
        from manager: SimpleCoreDataManageable? = nil
    ) -> Person? {
        return Person.get(from: manager) { (fetchRequest: NSFetchRequest<Person>) in
            fetchRequest.predicate = NSPredicate(format: "(%K == %@)", #keyPath(Person.id), id)
        }
    }
    public static func get(
        name: String,
        from manager: SimpleCoreDataManageable? = nil
    ) -> Person? {
        return Person.get(from: manager) { (fetchRequest: NSFetchRequest<Person>) in
            fetchRequest.predicate = NSPredicate(format: "(%K == %@)", #keyPath(Person.name), name)
        }
    }
}

// MARK: Sorting
extension Person {
    static func sort(_ a: Person, b: Person) -> Bool {
        return (a.name ?? "").localizedCaseInsensitiveCompare(b.name ?? "") == .orderedAscending // handle accented characters
    }
}
