//
//  PersonCRUDTests.swift
//  SimpleCoreDataManagerDemo
//
//  Created by Emily Ivie on 2/19/17.
//  Copyright © 2017 urdnot. All rights reserved.
//

import XCTest
@testable import SimpleCoreDataManagerDemo

class PersonCRUDTests: XCTestCase {

    // can't do performance tests in this version
    
    override func setUp() {
        super.setUp()
        SimpleCoreDataManager.current = getSandboxedManager()
    }
    
    override func tearDown() {
        _ = Person.deleteAll()
        super.tearDown()
    }
    
    private func getSandboxedManager() -> SimpleCoreDataManager {
        return SimpleCoreDataManager(storeName: SimpleCoreDataManager.defaultStoreName, isConfineToMemoryStore: true)
    }
    
    func testCreateRead() {
        let newPerson = createSinclair()
        let newPersonId = newPerson?.id
        let sinclairPerson = Person.get(name: "Jeffrey Sinclair")
        XCTAssert(sinclairPerson != nil, "Person was not created")
        XCTAssert(sinclairPerson?.id == newPersonId, "Created Person id not saved correctly")
        XCTAssert(sinclairPerson?.objectID == newPerson?.objectID, "Created Person objectID mismatch")
    }
    
    func testReadAll() {
        let newPerson1 = Person.create()
        _ = newPerson1?.saveChanges() { (person: Person) in
            person.name = "Jeffrey Sinclair"
            person.profession = "Commander"
            person.organization = "Babylon 5"
            person.notes = "Not the one."
        }
        let newPerson2 = Person.create()
        _ = newPerson2?.saveChanges() { (person: Person) in
            person.name = "Suzan Ivanova"
            person.profession = "Lieutenant Commander"
            person.organization = "Babylon 5"
            person.notes = "Who are you?"
        }
        let newPerson3 = Person.create()
        _ = newPerson3?.saveChanges() { (person: Person) in
            person.name = "Londo Mollari"
            person.profession = "Ambassador"
            person.organization = "Babylon 5"
            person.notes = "What do you want?"
        }
        let persons = Person.getAll().sorted(by: Person.sort)
        XCTAssert(persons.count == 3, "All Persons were not created")
        XCTAssert(persons.first?.name == "Jeffrey Sinclair", "Persons sorted incorrectly")
    }
    
//    func testReadAllPerformance() {
//        measure {
//            self.testReadAll()
//        }
//    }
    
    func testUpdate() {
        let newPerson = createSinclair()
        let sinclairPerson = Person.get(name: "Jeffrey Sinclair")
        _ = sinclairPerson?.saveChanges() { (person: Person) in
            person.name = "John Sheridan"
            person.notes = "The one."
        }
        let sheridanPerson = Person.get(name: "John Sheridan")
        XCTAssert(sheridanPerson != nil, "Updated Person not found in the store")
        XCTAssert(sheridanPerson?.name == "John Sheridan", "Updated Person has incorrect values")
        XCTAssert(newPerson?.name == "John Sheridan", "Local store object was not updated")
        XCTAssert(sinclairPerson?.objectID == sheridanPerson?.objectID, "Updated Person objectID mismatch")
        let missingSinclairPerson = Person.get(name: "Jeffrey Sinclair")
        XCTAssert(missingSinclairPerson == nil, "Updated Person has older values in the store")
    }
    
    func testDelete() {
        _ = createSinclair()
        let sinclairPerson = Person.get(name: "Jeffrey Sinclair")
        _ = sinclairPerson?.delete()
//        XCTAssert(newPerson?.isDeleted == true, "Person was not deleted") // not updated
        let missingSinclairPerson = Person.get(name: "Jeffrey Sinclair")
        XCTAssert(missingSinclairPerson == nil, "Deleted Person still found in store")
    }
    
    func testDeleteAll() {
        testReadAll()
        _ = Person.deleteAll()
        XCTAssert(Person.getAll().isEmpty, "Person deleteAll failed")
    }
    
    private func createSinclair() -> Person? {
        let newPerson = Person.create()
        _ = newPerson?.saveChanges() { (person: Person) in
            person.name = "Jeffrey Sinclair"
            person.profession = "Commander"
            person.organization = "Babylon 5"
            person.notes = "Not the one."
        }
        return newPerson
    }
    
}
