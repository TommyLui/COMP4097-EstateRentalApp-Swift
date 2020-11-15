//
//  DetailTableViewController.swift
//  RentalApp
//
//  Created by xdeveloper on 11/11/2020.
//

import UIKit
import CoreData

class DetailTableViewController: UITableViewController {
    
    var id: Double?
    var houseDetail: [Houses] = []
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
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        //        print("section", fetchedResultsController.sections?[section].numberOfObjects ?? 0)
        return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DetailCell", for: indexPath)
        
        let estate = String(fetchedResultsController.object(at: indexPath).estate!)
        let bedrooms = String(fetchedResultsController.object(at: indexPath).bedrooms)
        let rent = String(fetchedResultsController.object(at: indexPath).rent)
        let expected_tenants = String(fetchedResultsController.object(at: indexPath).expected_tenants)
        let gross_area = String(fetchedResultsController.object(at: indexPath).gross_area)
        
        let userDefaults = UserDefaults.standard
        let logStatFromUserDefault = userDefaults.bool(forKey: "logStat")
        
        var url:String? = fetchedResultsController.object(at: indexPath).image_URL
        if url != nil{
            if  !url!.contains("https"){
                url!.insert("s", at: url!.index(url!.startIndex, offsetBy: 4))
            }
        }
        
        if let imageView = cell.viewWithTag(100) as? UIImageView {
            networkController.fetchImage(for: url!, completionHandler: { (data) in
                DispatchQueue.main.async {
                    imageView.image = UIImage(data: data, scale:1)
                }
            }) { (error) in
                DispatchQueue.main.async {
                    imageView.image = UIImage(named: "hkbu_logo")
                }
            }
        }
        
        if let cellLabel = cell.viewWithTag(200) as? UILabel {
            cellLabel.text = fetchedResultsController.object(at: indexPath).property_title
        }
        
        if let cellLabel = cell.viewWithTag(300) as? UILabel {
            cellLabel.text = "Estate: " + estate + ", Bedroom: " + bedrooms
        }
        
        if let cellLabel = cell.viewWithTag(400) as? UILabel {
            cellLabel.text = "Rent: " + rent + ", Tenants: " + expected_tenants + ", Area: " + gross_area
        }
        
        if let cellLabel = cell.viewWithTag(500) as? UIButton {
            if fetchedResultsController.object(at: [0, 0]).isRental == false || logStatFromUserDefault == false{
                cellLabel.setTitle("Move-in", for: .normal)
            }else if fetchedResultsController.object(at: [0, 0]).isRental == true{
                cellLabel.setTitle("Move-out", for: .normal)
            }
        }
        
        return cell
    }
    
    @IBAction func moveRental(_ sender: UIButton) {
        print("moveRental click")
        let userDefaults = UserDefaults.standard
        let logStatFromUserDefault = userDefaults.bool(forKey: "logStat")
        
        if logStatFromUserDefault == true{
            
            let alert = UIAlertController(
                title: "Are you sure?!",
                message: "",
                preferredStyle: .alert)
            
            alert.addAction(
                UIAlertAction(title: "Yes", style: .default, handler: { (action) in
                    print("Move-in alert OK button pressed!")
                    DispatchQueue.main.async {
                        if let moveButton = self.view.viewWithTag(500) as? UIButton {
                            if let moveButtonText = moveButton.titleLabel?.text{
                                print("button text: ", moveButtonText)
                                if moveButtonText == "Move-in" {
                                    self.networkController.fetchAddRental(id: Int(self.id!), completionHandler: { (responseCode) in
                                        DispatchQueue.main.async {
                                            print("fetchAddRental responseCode:", responseCode)
                                            if responseCode == 200{
                                                let indexPath:IndexPath = [0, 0]
                                                let houses = self.fetchedResultsController.object(at: indexPath)
                                                houses.isRental = true
                                                do {
                                                    try self.viewContext?.save()
                                                    print("move in action save in local db")
                                                } catch {
                                                    print("Could not save managed object context. \(error)")
                                                }
                                                let alert = UIAlertController(
                                                    title: "Move-in success!",
                                                    message: "",
                                                    preferredStyle: .alert)
                                                
                                                alert.addAction(
                                                    UIAlertAction(title: "OK", style: .default, handler: { (action) in
                                                        print("Move-in alert OK button pressed!")
                                                        DispatchQueue.main.async {
                                                            self.performSegueToReturnBack()
                                                        }
                                                    })
                                                )
                                                self.present(alert, animated: true, completion: nil)
                                            }else{
                                                let alert = UIAlertController(
                                                    title: "Already full!",
                                                    message: "",
                                                    preferredStyle: .alert)
                                                
                                                alert.addAction(
                                                    UIAlertAction(title: "OK", style: .default, handler: { (action) in
                                                        print("Move-in alert OK button pressed!")
                                                        DispatchQueue.main.async {
                                                            self.performSegueToReturnBack()
                                                        }
                                                    })
                                                )
                                                self.present(alert, animated: true, completion: nil)
                                            }
                                        }
                                    }) { (error) in
                                        DispatchQueue.main.async {
                                            print("error fetchMyRental")
                                            self.performSegueToReturnBack()
                                        }
                                    }
                                }else if moveButtonText == "Move-out"{
                                    self.networkController.fetchDropRental(id: Int(self.id!), completionHandler: { (responseCode) in
                                        DispatchQueue.main.async {
                                            print("fetchDropRental responseCode:", responseCode)
                                            
                                            let indexPath:IndexPath = [0, 0]
                                            let houses = self.fetchedResultsController.object(at: indexPath)
                                            houses.isRental = false
                                            do {
                                                try self.viewContext?.save()
                                                print("move out action save in local db")
                                            } catch {
                                                print("Could not save managed object context. \(error)")
                                            }
                                            
                                            self.performSegueToReturnBack()
                                        }
                                    }) { (error) in
                                        DispatchQueue.main.async {
                                            print("error fetchMyRental")
                                            self.performSegueToReturnBack()
                                        }
                                    }
                                }
                            }
                        }
                        
                    }
                })
            )
            
            alert.addAction(
                UIAlertAction(title: "NO", style: .default, handler: { (action) in
                    print("Move-in alert OK button pressed!")
                }
                )
            )
            
            self.present(alert, animated: true, completion: nil)
            
        }else{
            print("no yet login alert")
            DispatchQueue.main.async {
                let alert = UIAlertController(
                    title: "Please login first!",
                    message: "",
                    preferredStyle: .alert)
                
                alert.addAction(
                    UIAlertAction(title: "OK", style: .default, handler: { (action) in
                        print("Move-in alert OK button pressed!")
                        DispatchQueue.main.async {
                            self.performSegueToReturnBack()
                        }
                    })
                )
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    
    /*
     // Override to support conditional editing of the table view.
     override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the specified item to be editable.
     return true
     }
     */
    
    /*
     // Override to support editing the table view.
     override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
     if editingStyle == .delete {
     // Delete the row from the data source
     tableView.deleteRows(at: [indexPath], with: .fade)
     } else if editingStyle == .insert {
     // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
     }
     }
     */
    
    /*
     // Override to support rearranging the table view.
     override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
     
     }
     */
    
    /*
     // Override to support conditional rearranging of the table view.
     override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the item to be re-orderable.
     return true
     }
     */
    
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print("prepare runed")
        
        if let viewController = segue.destination as? MapViewController{
            
            viewController.id = fetchedResultsController.object(at: [0, 0]).id
            
            print("id passed: ", viewController.id)
        }
    }
    
    
}

extension DetailTableViewController: NSFetchedResultsControllerDelegate {
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                    didChange anObject: Any, at indexPath: IndexPath?,
                    for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        //        tableView.reloadData()
        //        print("upodate detail page")
    }
}
