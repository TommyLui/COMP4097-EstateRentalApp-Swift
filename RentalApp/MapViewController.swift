//
//  MapViewController.swift
//  RentalApp
//
//  Created by tommylui on 14/11/2020.
//

import UIKit
import MapKit
import CoreData

class MapViewController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    var id: Double?
    var house: Houses?
    var locationInfo: [LocationInfo]?
    var networkController = NetworkController()
    var viewContext: NSManagedObjectContext?
    
    lazy var fetchedResultsController: NSFetchedResultsController<HouseManagedObject> = {
        
        let fetchRequest = NSFetchRequest<HouseManagedObject>(entityName:"House")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "id", ascending:true)]
        
        if let id = id {
            print("id search: ", id)
            fetchRequest.predicate = NSPredicate(format: "id = \(id)")
        }
        
        let controller = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                    managedObjectContext: viewContext!,
                                                    sectionNameKeyPath: nil, cacheName: nil)
        
        controller.delegate = self
        
        do {
            try controller.performFetch()
        } catch {
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
        
        return controller
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let dataController = AppDelegate.dataController!
        viewContext = dataController.persistentContainer.viewContext
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        let house = fetchedResultsController.object(at: [0, 0])
        let mapLatFromDb = house.mapLat
        let mapLonFromDb = house.mapLon
        
        if mapLatFromDb == 0 && mapLonFromDb == 0{
            
            networkController.fetchImage(for: "https://hintegro.com/wp-content/uploads/2017/08/ken_025016_PSD.jpg", completionHandler: { (networkTest) in
                DispatchQueue.main.async {
                    DispatchQueue.main.async {
                        let alert = UIAlertController(
                            title: "Load map data from network",
                            message: "",
                            preferredStyle: .alert)
                        
                        alert.addAction(
                            UIAlertAction(title: "OK", style: .default, handler: { (action) in
                                print("Move-in alert OK button pressed!")
                                DispatchQueue.main.async {
                                    let placeToSearchWithSpace = "Hong%20Kong, " + house.estate!
                                    let placeToSearch = placeToSearchWithSpace.replacingOccurrences(of: " ", with: "%20")
                                    self.networkController.fetchLocation(placeToSearch: placeToSearch, completionHandler: { (locationInfo) in
                                        DispatchQueue.main.async {
                                            print("fetchLocation success")
                                            self.locationInfo = locationInfo
                                            print(self.locationInfo![0].lat, self.locationInfo![0].lon)
                                            let campusLocation = CLLocation(latitude: Double(self.locationInfo![0].lat)!, longitude: Double(self.locationInfo![0].lon)!)
                                            self.mapView.setCenterLocation(campusLocation)
                                            self.mapView.addAnnotation(Estate(title: house.property_title,
                                                                              estateName: house.estate!, coordinate: CLLocationCoordinate2D(latitude: Double(self.locationInfo![0].lat)!, longitude: Double(self.locationInfo![0].lon)!)))
                                            let indexPath:IndexPath = [0, 0]
                                            let houses = self.fetchedResultsController.object(at: indexPath)
                                            houses.mapLat = Double(self.locationInfo![0].lat)!
                                            houses.mapLon = Double(self.locationInfo![0].lon)!
                                            do {
                                                try self.viewContext?.save()
                                                print("map data save in local db")
                                            } catch {
                                                print("Could not save managed object context. \(error)")
                                            }
                                        }
                                    }) { (error) in
                                        DispatchQueue.main.async {
                                            print("fetchLocation fail")
                                        }
                                    }}
                            })
                        )
                        self.present(alert, animated: true, completion: nil)
                    }
                }
            }) { (error) in
                DispatchQueue.main.async {
                    print("Network fail to load map")
                    
                    let alert = UIAlertController(
                        title: "Fail to load map!",
                        message: "Network fail & no local data!",
                        preferredStyle: .alert)
                    alert.addAction(
                        UIAlertAction(title: "OK", style: .default, handler: { (action) in
                            print("Logout alert OK button pressed!")
                        }
                        )
                    )
                    self.present(alert, animated: true, completion: nil)
                }
            }
            
            
        }else{
            DispatchQueue.main.async {
                let alert = UIAlertController(
                    title: "Load map data from local",
                    message: "",
                    preferredStyle: .alert)
                
                alert.addAction(
                    UIAlertAction(title: "OK", style: .default, handler: { (action) in
                        print("Move-in alert OK button pressed!")
                        DispatchQueue.main.async {
                            let campusLocation = CLLocation(latitude: mapLatFromDb, longitude: mapLonFromDb)
                            self.mapView.setCenterLocation(campusLocation)
                            self.mapView.addAnnotation(Estate(title: house.property_title,
                                                              estateName: house.estate!, coordinate: CLLocationCoordinate2D(latitude: mapLatFromDb, longitude: mapLonFromDb)))
                        }
                    })
                )
                self.present(alert, animated: true, completion: nil)
            }
        }
        
        
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}

private extension MKMapView {
    
    func setCenterLocation(_ location: CLLocation,
                           regionRadius: CLLocationDistance = 500) {
        
        let coordinateRegion = MKCoordinateRegion(
            center: location.coordinate,
            latitudinalMeters: regionRadius,
            longitudinalMeters: regionRadius)
        
        setRegion(coordinateRegion, animated: true)
    }
    
}

extension MapViewController: NSFetchedResultsControllerDelegate {
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                    didChange anObject: Any, at indexPath: IndexPath?,
                    for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
    }
}
