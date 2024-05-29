//
//  Persistence.swift
//  Bondify
//
//  Created by Kuba Milcarz on 5/29/24.
//

import CoreData
import CloudKit

class PersistenceController: ObservableObject {
    static let shared = PersistenceController()
        
    let container: NSPersistentCloudKitContainer

    var oldStoreURL: URL {
        let appSupport = FileManager.default.urls(
            for: .applicationSupportDirectory,
            in: .userDomainMask
        ).first!
        return appSupport.appendingPathComponent("bondify.sqlite")
    }

    // We define new App Group containerURL.
    var sharedStoreURL: URL {
        let id = "group.com.kubamilcarz.Bondify" // Use App Group's id here.
        let containerURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: id)!
        return containerURL.appendingPathComponent("bondify.sqlite")
    }

    init(inMemory: Bool = false) {
        container = NSPersistentCloudKitContainer(name: "bondify")

        let description = container.persistentStoreDescriptions.first!
        let originalCloudKitOptions = description.cloudKitContainerOptions

        // Use the App Group store if migration is not needed (if default store without App Group doesn't exist).
        if !FileManager.default.fileExists(atPath: oldStoreURL.path) {
            description.url = sharedStoreURL
        } else {
            // Disable CloudKit integration if migration is needed.
            description.cloudKitContainerOptions = nil
        }

        description.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)

        if inMemory {
            description.url = URL(fileURLWithPath: "/dev/null")
        }

        // Load persistent stores.
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })

        // Perform the migration.
        migrateStore(for: container, originalCloudKitOptions: originalCloudKitOptions)

        container.viewContext.automaticallyMergesChangesFromParent = true
    }

    // Function migrateStore. Migrates data store to App Group if needed.
    func migrateStore(for container: NSPersistentCloudKitContainer, originalCloudKitOptions: NSPersistentCloudKitContainerOptions?) {
        let coordinator = container.persistentStoreCoordinator
        let storeDescription = container.persistentStoreDescriptions.first!

        // Exit current scope if persistentStore(for:) returns nil (migration is not needed).
        guard coordinator.persistentStore(for: oldStoreURL) != nil else {
            print("Migration not needed")
            return
        }

        // Replace one persistent store with another.
        do {
            try coordinator.replacePersistentStore(
                at: sharedStoreURL,
                withPersistentStoreFrom: oldStoreURL,
                type: .sqlite
            )
        } catch {
            fatalError("Something went wrong while migrating the store: \(error)")
        }

        // Delete old store.
        do {
            try coordinator.destroyPersistentStore(at: oldStoreURL, type: .sqlite, options: nil)
        } catch {
            fatalError("Something went wrong while deleting the old store: \(error)")
        }

        NSFileCoordinator(filePresenter: nil).coordinate(writingItemAt: oldStoreURL.deletingLastPathComponent(), options: .forDeleting, error: nil, byAccessor: { url in
            try? FileManager.default.removeItem(at: oldStoreURL)
            try? FileManager.default.removeItem(at: oldStoreURL.deletingLastPathComponent().appendingPathComponent("\(container.name).sqlite-shm"))
            try? FileManager.default.removeItem(at: oldStoreURL.deletingLastPathComponent().appendingPathComponent("\(container.name).sqlite-wal"))
            try? FileManager.default.removeItem(at: oldStoreURL.deletingLastPathComponent().appendingPathComponent("ckAssetFiles"))
        })

        // Unload the store and load it again with new storeDescription to re-enable CloudKit.
        if let persistentStore = container.persistentStoreCoordinator.persistentStores.first {
            do {
                try container.persistentStoreCoordinator.remove(persistentStore)
                print("Persistent store unloaded")
            } catch {
                print("Failed to unload persistent store: \(error)")
            }
        }

        // Set the URL of the storeDescription to the sharedStoreURL.
        storeDescription.url = sharedStoreURL
        // Modify the storeDescription to re-enable CloudKit integration.
        storeDescription.cloudKitContainerOptions = originalCloudKitOptions

        // Load the persistent store with the updated storeDescription.
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })

        print("Migration completed")
    }


    func remoteStoreChanged(_ notification: Notification) {
        objectWillChange.send()
    }
    
    
    func save() {
        if container.viewContext.hasChanges {
            try? container.viewContext.save()
        }
    }
    
    
    private func delete(_ fetchRequest: NSFetchRequest<NSFetchRequestResult>) {
        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        batchDeleteRequest.resultType = .resultTypeObjectIDs

        // IMPORTANT: When performing a batch delete we need to make sure we read the result back
        // then merge all the changes from that result back into our live view context
        // so that the two stay in sync.
        if let delete = try? container.viewContext.execute(batchDeleteRequest) as? NSBatchDeleteResult {
            let changes = [NSDeletedObjectIDsKey: delete.result as? [NSManagedObjectID] ?? []]
            NSManagedObjectContext.mergeChanges(fromRemoteContextSave: changes, into: [container.viewContext])
        }
    }
}
