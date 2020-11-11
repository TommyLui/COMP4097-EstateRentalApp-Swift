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
    var shouldSeedDatabase: Bool = true
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
        
        persistentContainer.loadPersistentStores { (description, error) in
            if let error = error {
                fatalError("Core Data stack could not be loaded. \(error)")
            }
            
            // Called once initialization of Core Data stack is complete
            DispatchQueue.main.async {
//                if (self.shouldSeedDatabase) {
                    self.seedData()
//                }
                completion()
            }
        }
    }
    
    private func seedData() {

        do {
            guard let rawCatalogData = try? Data(contentsOf:
                Bundle.main.bundleURL.appendingPathComponent("events.json")) else {
                return
            }

            let events = try JSONDecoder().decode([Event].self, from: rawCatalogData)

            persistentContainer.performBackgroundTask { (managedObjectContext) in

                // Loop through the events in the JSON and add to the database
                events.forEach { (event) in
                    let eventManagedObject = EventManagedObject(context: managedObjectContext)
                    eventManagedObject.id = event.id
                    eventManagedObject.title = event.title
                    eventManagedObject.dept_id = event.dept_id
                    eventManagedObject.saved = event.saved
                }

                do {
                    try managedObjectContext.save()
                } catch {
                    print("Could not save managed object context. \(error)")
                }
            }
        } catch {
            print("events.json was not found or is not decodable.")
        }
    }
    
//    private func seedData() {
//            networkController.fetchHouses(completionHandler:
//                { (houses) in DispatchQueue.main.async {
//                        self.houses = houses
//                    }
//            }) { (error) in DispatchQueue.main.async {
//                    self.houses = []
//                }
//            }
//
//        print("check point1")
//
//            persistentContainer.performBackgroundTask { (managedObjectContext) in
//                print("check point2")
//
//                // Loop through the houses in the JSON and add to the database
//                houses.forEach { (house) in
//                    print("check point3")
//                    let houseMangedObject = HouseMangedObject(context: managedObjectContext)
//                    houseMangedObject.createdAt = house.createdAt
//                    houseMangedObject.updatedAt = house.updatedAt
//                    houseMangedObject.id = house.id
//                    houseMangedObject.property_title = house.property_title
//                    houseMangedObject.image_URL = house.image_URL
//                    houseMangedObject.estate = house.estate
//                    houseMangedObject.bedrooms = house.bedrooms
//                    houseMangedObject.gross_area = house.gross_area
//                    houseMangedObject.expected_tenants = house.expected_tenants
//                    houseMangedObject.rent = house.rent
//                    houseMangedObject.h_Property = house.h_Property
//                    houseMangedObject.occupied = house.occupied
//                    print("check point4")
//                }
//
//                do {
//                    try managedObjectContext.save()
//                } catch {
//                    print("Could not save managed object context. \(error)")
//                }
//            }
//    }
}
