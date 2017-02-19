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
    
    public static var defaultCoreDataManager: SimpleCoreDataManageable { return SimpleCoreDataManager.current }
    
    public static func create() -> Person? {
        return Person.create(setInitialValues: { (person: Person) in
            person.id = "\(UUID())"
            person.name = "Unknown"
        })
    }
    
    public static func get(id: String) -> Person? {
        return Person.get { (fetchRequest: NSFetchRequest<Person>) in
            fetchRequest.predicate = NSPredicate(format: "(%K == %@)", #keyPath(Person.id), id)
        }
    }
}
