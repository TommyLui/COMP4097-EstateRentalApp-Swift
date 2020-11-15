//
//  DataController.swift
//  RentalApp
//
//  Created by xdeveloper on 11/11/2020.
//

import Foundation
import CoreData

class DataController {
    
    var persistentContainer: NSPersistentContainer
    var shouldSeedDatabase: Bool = false
    let networkController = NetworkController()
    var houses: [Houses] = []
    
    init(completion: @escaping () -> ()) {
            
        // Check if the database exists
        do {
            let databaseUrl =
                try FileManager.default.url(for: .applicationSupportDirectory,
                                            in: .userDomainMask, appropriateFor: nil,
                                            create: false).appendingPathComponent("RentalAppModel.sqlite")
            
            shouldSeedDatabase = !FileManager.default.fileExists(atPath: databaseUrl.path)
        } catch {
            shouldSeedDatabase = true
        }
        
        persistentContainer = NSPersistentContainer(name: "RentalAppModel")
        persistentContainer.viewContext.automaticallyMergesChangesFromParent = true
        persistentContainer.loadPersistentStores { (description, error) in
            if let error = error {
                fatalError("Core Data stack could not be loaded. \(error)")
            }
            
            // Called once initialization of Core Data stack is complete
            DispatchQueue.main.async {
                if (self.shouldSeedDatabase) {
                    self.seedData()
                }
                completion()
            }
        }
    }
    
    public func seedData() {
        print("seedData called")
            networkController.fetchHouses(completionHandler:
                            { (houses) in DispatchQueue.main.async {
                                    self.houses = houses
//                                    print(houses)
                                    self.persistentContainer.performBackgroundTask { (managedObjectContext) in
                                    // Loop through the events in the JSON and add to the database
                                    self.houses.forEach { (house) in
                                        let houseManagedObject = HouseManagedObject(context: managedObjectContext)
                                        houseManagedObject.createdAt = house.createdAt
                                        houseManagedObject.updatedAt = house.updatedAt
                                        houseManagedObject.id = house.id
                                        houseManagedObject.property_title = house.property_title
                                        houseManagedObject.image_URL = house.image_URL
                                        houseManagedObject.estate = house.estate
                                        houseManagedObject.bedrooms = house.bedrooms
                                        houseManagedObject.gross_area = house.gross_area
                                        houseManagedObject.expected_tenants = house.expected_tenants
                                        houseManagedObject.rent = house.rent
                                        houseManagedObject.h_Property = house.h_Property
                                        houseManagedObject.occupied = house.occupied
                                        houseManagedObject.isRental = house.isRental ?? false
                                        houseManagedObject.mapLat = house.mapLat ?? 0
                                        houseManagedObject.mapLon = house.mapLon ?? 0
//                                        print("data save")
                                    }
                                    do {
                                        print("managedObjectContext save")
                                        try managedObjectContext.save()
                                    } catch {
                                        print("Could not save managed object context. \(error)")
                                    }
                                }
                                }
                        }) { (error) in DispatchQueue.main.async {
                                self.houses = []
                            }
                        }
    }
}
