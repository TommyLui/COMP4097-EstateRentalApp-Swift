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
        let placeToSearchWithSpace = "Hong%20Kong, " + house.estate!
        let placeToSearch = placeToSearchWithSpace.replacingOccurrences(of: " ", with: "%20")
//        print("search:", placeToSearch)
        
        networkController.fetchLocation(placeToSearch: placeToSearch, completionHandler: { (locationInfo) in
            DispatchQueue.main.async {
                print("fetchLocation success")
                self.locationInfo = locationInfo
                print(self.locationInfo![0].lat, self.locationInfo![0].lon)
                let campusLocation = CLLocation(latitude: Double(self.locationInfo![0].lat)!, longitude: Double(self.locationInfo![0].lon)!)
                       self.mapView.setCenterLocation(campusLocation)
                       self.mapView.addAnnotation(Estate(title: house.property_title,
                                                         estateName: house.estate!, coordinate: CLLocationCoordinate2D(latitude: Double(self.locationInfo![0].lat)!, longitude: Double(self.locationInfo![0].lon)!)))
            }
        }) { (error) in
            DispatchQueue.main.async {
                print("fetchLocation fail")
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
