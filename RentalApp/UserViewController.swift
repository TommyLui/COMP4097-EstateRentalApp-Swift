//
//  UserViewController.swift
//  RentalApp
//
//  Created by tommylui on 12/11/2020.
//

import UIKit
import CoreData

class UserViewController: UIViewController {
    var networkController = NetworkController()
    var rental: [Houses] = []
    var rentalIDArray: [Double] = []
    var houses: [Houses] = []
    var viewContext: NSManagedObjectContext?
    
    lazy var fetchedResultsController: NSFetchedResultsController<HouseManagedObject> = {
        
        let fetchRequest = NSFetchRequest<HouseManagedObject>(entityName:"House")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "id", ascending:true)]
        
        
        let controller = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                    managedObjectContext: AppDelegate.dataController!.persistentContainer.viewContext,
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
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let userDefaults = UserDefaults.standard
        let logStatFromUserDefault = userDefaults.bool(forKey: "logStat")
        let userPhotoFromUserDefault = userDefaults.string(forKey: "userPhoto")
        let userNameFromUserDefault = userDefaults.string(forKey: "userName")
        print("logStatFromUserDefault: ", logStatFromUserDefault)
        if logStatFromUserDefault == true{
            if let userPhoto = self.view.viewWithTag(100) as? UIImageView {
                networkController.fetchImage(for: userPhotoFromUserDefault!, completionHandler: { (data) in
                    DispatchQueue.main.async {
                        userPhoto.image = UIImage(data: data, scale:1)
                    }
                }) { (error) in
                    DispatchQueue.main.async {
                        userPhoto.image = UIImage(named: "hkbu_logo")
                    }
                }
            }
            if let userName = self.view.viewWithTag(200) as? UILabel {
                userName.text = userNameFromUserDefault
            }
            if let logButton = self.view.viewWithTag(300) as? UIButton {
                logButton.setTitle("Logout", for: .normal)
            }
        }else{
            if let userPhoto = self.view.viewWithTag(100) as? UIImageView {
                userPhoto.image = UIImage(systemName: "person.fill")
            }
            if let userName = self.view.viewWithTag(200) as? UILabel {
                userName.text = "User Name"
            }
            if let logButton = self.view.viewWithTag(300) as? UIButton {
                logButton.setTitle("Login", for: .normal)
            }
        }
    }
    @IBAction func myRentalBtn(_ sender: UIButton) {
        print("myRentalBtn click")
        let userDefaults = UserDefaults.standard
        userDefaults.set("myRental", forKey: "fromPage")
        
        let logStatFromUserDefault = userDefaults.bool(forKey: "logStat")
        if logStatFromUserDefault == true {
            networkController.fetchMyRental(completionHandler: { (rental) in
                DispatchQueue.main.async {
                    print("fetchMyRental data:", rental)
                    
                    self.rental = rental
                    self.rentalIDArray = []
                    self.rental.forEach { (rental) in
                        self.rentalIDArray.append(rental.id)
                    }
                    print("rental ID list : ", self.rentalIDArray)
                    
                    if !self.rentalIDArray.isEmpty{
                        let numberOfObjects:Int = self.fetchedResultsController.sections?[0].numberOfObjects ?? 0
                        print("houses in db:", numberOfObjects)
                        
                        if numberOfObjects >= 1{
                            for i in 0...(numberOfObjects - 1) {
                                let indexPath:IndexPath = [0, i]
                                let houses = self.fetchedResultsController.object(at: indexPath)
                                houses.isRental = false
                            }
                            
                            for i in 0...(numberOfObjects - 1) {
                                let indexPath:IndexPath = [0, i]
                                let houses = self.fetchedResultsController.object(at: indexPath)
                                for j in 0...(self.rentalIDArray.count - 1){
                                    if houses.id == self.rentalIDArray[j]{
                                        houses.isRental = true
                                        print(houses.id, "isRental = true")
                                    }
                                }
                            }
                            do {
                                try self.viewContext?.save()
                                print("local rental data correct")
                            } catch {
                                print("Could not save managed object context. \(error)")
                            }
                        }
                    }
                }
            }) { (error) in
                DispatchQueue.main.async {
                    print("error fetchMyRental")
                }
            }
        }
        
        
    }
    
    
    @IBAction func logBtn(_ sender: UIButton) {
        print("logBtn click")
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
    //    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    //        // Get the new view controller using segue.destination.
    //        // Pass the selected object to the new view controller.
    //        print("prepare runed")
    //        if let viewController = segue.destination as? LoginViewController{
    //            viewController.logStatus = false
    //            print("logStatus passed: ", viewController.logStatus)
    //        }
    //    }
}

extension UserViewController: NSFetchedResultsControllerDelegate {
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                    didChange anObject: Any, at indexPath: IndexPath?,
                    for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
    }
}
