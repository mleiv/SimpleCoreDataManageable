//
//  SandboxedPersonCRUDTests.swift
//  SimpleCoreDataManagerDemo
//
//  Created by Emily Ivie on 2/19/17.
//  Copyright © 2017 urdnot. All rights reserved.
//

import XCTest
@testable import SimpleCoreDataManagerDemo

class SandboxedPersonCRUDTests: XCTestCase {

    // You can run performance tests on these, because they don't use static SimpleCoreDataManager.current.
    // It's just more annoying, because you have to pass the manager all around.
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    private func getSandboxedManager() -> SimpleCoreDataManageable {
        return SimpleCoreDataManager(storeName: SimpleCoreDataManager.defaultStoreName, isConfineToMemoryStore: true)
    }
    
    func testCreateRead() {
        let manager = getSandboxedManager()
        let newPerson = createSinclair(from: manager)
        let newPersonId = newPerson?.id
        let sinclairPerson = Person.get(name: "Jeffrey Sinclair", from: manager)
        XCTAssert(sinclairPerson != nil, "Person was not created")
        XCTAssert(sinclairPerson?.id == newPersonId, "Created Person id not saved correctly")
        XCTAssert(sinclairPerson?.objectID == newPerson?.objectID, "Created Person objectID mismatch")
    }
    
    func testReadAll(from manager: SimpleCoreDataManageable? = nil) {
        let manager = manager ?? getSandboxedManager()
        XCTAssert(Person.getAll(from: manager){ _ in }.isEmpty, "Core Data not sandboxed correctly")
        
        let newPerson1 = Person.create(from: manager)
        _ = newPerson1?.saveChanges(from: manager) { (person: Person) in
            person.name = "Jeffrey Sinclair"
            person.profession = "Commander"
            person.organization = "Babylon 5"
            person.notes = "Not the one."
        }
        let newPerson2 = Person.create(from: manager)
        _ = newPerson2?.saveChanges(from: manager) { (person: Person) in
            person.name = "Suzan Ivanova"
            person.profession = "Lieutenant Commander"
            person.organization = "Babylon 5"
            person.notes = "Who are you?"
        }
        let newPerson3 = Person.create(from: manager)
        _ = newPerson3?.saveChanges(from: manager) { (person: Person) in
            person.name = "Londo Mollari"
            person.profession = "Ambassador"
            person.organization = "Babylon 5"
            person.notes = "What do you want?"
        }
        let persons = Person.getAll(from: manager){ _ in }.sorted(by: Person.sort)
        XCTAssert(persons.count == 3, "All Persons were not created")
        XCTAssert(persons.first?.name == "Jeffrey Sinclair", "Persons sorted incorrectly")
    }
    
    func testReadAllPerformance() {
        measure {
            self.testReadAll()
        }
    }
    
    func testUpdate() {
        let manager = getSandboxedManager()
        let newPerson = createSinclair(from: manager)
        let sinclairPerson = Person.get(name: "Jeffrey Sinclair", from: manager)
        _ = sinclairPerson?.saveChanges(from: manager) { (person: Person) in
            person.name = "John Sheridan"
            person.notes = "The one."
        }
        let sheridanPerson = Person.get(name: "John Sheridan", from: manager)
        XCTAssert(sheridanPerson != nil, "Updated Person not found in the store")
        XCTAssert(sheridanPerson?.name == "John Sheridan", "Updated Person has incorrect values")
        XCTAssert(newPerson?.name == "John Sheridan", "Local store object was not updated")
        XCTAssert(sinclairPerson?.objectID == sheridanPerson?.objectID, "Updated Person objectID mismatch")
        let missingSinclairPerson = Person.get(name: "Jeffrey Sinclair", from: manager)
        XCTAssert(missingSinclairPerson == nil, "Updated Person has older values in the store")
    }
    
    func testDelete() {
        let manager = getSandboxedManager()
        _ = createSinclair(from: manager)
        let sinclairPerson = Person.get(name: "Jeffrey Sinclair", from: manager)
        _ = sinclairPerson?.delete(from: manager)
//        XCTAssert(newPerson?.isDeleted == true, "Person was not deleted") // not updated
        let missingSinclairPerson = Person.get(name: "Jeffrey Sinclair", from: manager)
        XCTAssert(missingSinclairPerson == nil, "Deleted Person still found in store")
    }
    
    func testDeleteAll() {
        let manager = getSandboxedManager()
        testReadAll(from: manager)
        _ = Person.deleteAll(from: manager){ _ in }
        XCTAssert(Person.getAll(from: manager){ _ in }.isEmpty, "Person deleteAll failed")
    }
    
    private func createSinclair(from manager: SimpleCoreDataManageable? = nil) -> Person? {
        let newPerson = Person.create(from: manager)
        _ = newPerson?.saveChanges(from: manager) { (person: Person) in
            person.name = "Jeffrey Sinclair"
            person.profession = "Commander"
            person.organization = "Babylon 5"
            person.notes = "Not the one."
        }
        return newPerson
    }
    
}
