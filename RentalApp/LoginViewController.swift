//
//  LoginViewController.swift
//  RentalApp
//
//  Created by tommylui on 13/11/2020.
//

import UIKit
import CoreData

class LoginViewController: UIViewController {
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
        
        let userDefaults = UserDefaults.standard
        let logStatFromUserDefault = userDefaults.bool(forKey: "logStat")
        let userNameFromUserDefault = userDefaults.string(forKey: "userName")
        if logStatFromUserDefault == true{
            if let userName = self.view.viewWithTag(100) as? UITextField {
                userName.text = userNameFromUserDefault
            }
            if let password = self.view.viewWithTag(200) as? UITextField {
                password.text = "****"
            }
            if let logButton = self.view.viewWithTag(300) as? UIButton {
                logButton.setTitle("Logout", for: .normal)
            }
        }
        
        
        // Do any additional setup after loading the view.
    }
    
    @IBAction func loginBtn(_ sender: UIButton) {
        let userDefaults = UserDefaults.standard
        let logStatFromUserDefault = userDefaults.bool(forKey: "logStat")
//        let logStatFromUserDefault = true //for testing logout
        
        if logStatFromUserDefault == false{
        if let accountText = self.view.viewWithTag(100) as? UITextField {
                print(accountText.text!)
            if let passwordText = self.view.viewWithTag(200) as? UITextField {
                print(passwordText.text!)
                networkController.fetchLogin(completionHandler: { (data) in
                    DispatchQueue.main.async {
                        print("login success")
//                        print(data.username)
//                        print(data.avatar)
                        let userDefaults = UserDefaults.standard
                        userDefaults.set(data.username, forKey: "userName")
                        userDefaults.set(data.avatar, forKey: "userPhoto")
                        userDefaults.set(true, forKey: "logStat")

                            self.networkController.fetchMyRental(completionHandler: { (rental) in
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
                        
                        self.performSegueToReturnBack()
                    }
                }) { (error) in
                    DispatchQueue.main.async {
                        print("login fail")
                    }
                }
            }
        }
        }else{
            networkController.fetchLogout(completionHandler: { (responseCode) in
                DispatchQueue.main.async {
                    self.performSegueToReturnBack()
                    print("logout success")
                    let userDefaults = UserDefaults.standard
                    userDefaults.set(false, forKey: "logStat")
                }
            }) { (error) in
                DispatchQueue.main.async {
                    print("logout fail")
                }
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

extension UIViewController {
    func performSegueToReturnBack()  {
        if let nav = self.navigationController {
            nav.popViewController(animated: true)
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }
}

extension LoginViewController: NSFetchedResultsControllerDelegate {

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                    didChange anObject: Any, at indexPath: IndexPath?,
                    for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {

    }
}
