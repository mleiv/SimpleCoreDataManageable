# SimpleCoreDataManageable

**A simple protocol for iOS 10 Swift 3 Core Data interactions.**

I have been using protocols to manage my Swift struct SerializableData/Core Data wrappers for quite some time, but with the new iOS 10/Swift 3 options, I wanted to see what it was like using straight NSManagedObjects again.

There are still some missing pieces (like: I can't declare a generic type conforming to both NSManagedObject *and* SimpleCoreDataStorable), but I do really like the new direction. The easier access and automatic merge between primary and background contexts is so much simpler and safer (once you get all the prerequisites ironed out), and the new Swift model is much easier to work with - although it could be much more Swifty still.

In the end, I prefer my struct wrappers because I hate reference objects and the way they are mutated underneath you. Having a static copy that I save and update when and where I want to is worth any extra labor, and I think until Apple gets onboard with functional Core Data, this will just be an interesting side experiment and not my primary Core Data library.

## Recommendations

If you are looking for a Swift core data stack to use in your app, rather than an example of iOS 10 functionality, https://github.com/tadija/AERecord looks nice IMO.

## Examples

Declaring a CoreDataManager for your store:


```swift

struct SimpleCoreDataManager: SimpleCoreDataManageable {
    public static let defaultStoreName = "SimpleCoreDataManagerDemo"
    public static var current: SimpleCoreDataManageable = SimpleCoreDataManager(storeName: defaultStoreName)
    
    public static var isConfineToMemoryStore: Bool = false // set to true for testing
    public static var isManageMigrations: Bool = false // automatic migrations
    
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
```

Declaring a CoreData Entity:

```swift

extension Person: SimpleCoreDataStorable {
    // id: String (Indexed)
    // name: String (Indexed)
    // profession: String?
    // organization: String?
    // notes: String?

    public static var coreDataEntityName: String { return "Person" } // mostly for debug
    
    public static var defaultCoreDataManager: SimpleCoreDataManageable { return SimpleCoreDataManager.current }
    
    public static func create() -> Person? {
        return Person.create(setInitialValues: { (person: Person) in
            // set all mandatory values:
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
```

That's it - everything else, like saveChanges() and getAll(), are all built into the protocols.