//
//  HomeTableViewController.swift
//  RentalApp
//
//  Created by tommylui on 11/11/2020.
//

import UIKit
import CoreData

class HomeTableViewController: UITableViewController {
    
    var houses: [Houses] = []
    var viewContext: NSManagedObjectContext?
    var networkController = NetworkController()
    var rental: [Houses] = []
    var rentalIDArray: [Double] = []
    
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
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action:  #selector(reloadTable), for: UIControl.Event.valueChanged)
        
        self.refreshControl = refreshControl
        
        let dataController = AppDelegate.dataController!
        viewContext = dataController.persistentContainer.viewContext
        
        let userDefaults = UserDefaults.standard
        let logStatFromUserDefault = userDefaults.bool(forKey: "logStat")
        
        networkController.fetchImage(for: "https://hintegro.com/wp-content/uploads/2017/08/ken_025016_PSD.jpg", completionHandler: { (networkTest) in
            DispatchQueue.main.async {
                
                if logStatFromUserDefault == true{
                    self.networkController.fetchMyRental(completionHandler: { (rental) in
                        DispatchQueue.main.async {
                            print("fetchMyRental data:", rental)
                            let userDefaults = UserDefaults.standard
                            userDefaults.set("myRental", forKey: "fromPage")
                            self.rental = rental
                            self.rentalIDArray = []
                            self.rental.forEach { (rental) in
                                self.rentalIDArray.append(rental.id)
                            }
                            print("rental ID list : ", self.rentalIDArray)
                            
                            if !self.rentalIDArray.isEmpty{
                                let numberOfObjects:Int = self.fetchedResultsController.sections?[0].numberOfObjects ?? 0
                                print("houses in db:", numberOfObjects)
                                
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
                                        }
                                    }
                                }
                                do {
                                    try self.viewContext?.save()
                                    
                                } catch {
                                    print("Could not save managed object context. \(error)")
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
        }) { (error) in
            DispatchQueue.main.async {
                print("Network fail to init db")
                
                let alert = UIAlertController(
                    title: "Fail to load data from network!",
                    message: "Network fail!",
                    preferredStyle: .alert)
                alert.addAction(
                    UIAlertAction(title: "OK", style: .default, handler: { (action) in
                        print("init db alert OK button pressed!")
                    }
                    )
                )
                self.present(alert, animated: true, completion: nil)
            }
        }
        
        
    }
    
    @objc func reloadTable() {
        print("refresh action")
        
        networkController.fetchImage(for: "https://hintegro.com/wp-content/uploads/2017/08/ken_025016_PSD.jpg", completionHandler: { (networkTest) in
            DispatchQueue.main.async {
                
                let numberOfObjects:Int = self.fetchedResultsController.sections?[0].numberOfObjects ?? 0
                print("houses in db:", numberOfObjects)
                
                if numberOfObjects >= 1{
                    for i in 0...(numberOfObjects - 1) {
                        let indexPath:IndexPath = [0, i]
                        let houses = self.fetchedResultsController.object(at: indexPath)
                        self.viewContext?.delete(houses)
                    }
                    
                    do {
                        try self.viewContext?.save()
                        print("delete db data finish")
                    } catch {
                        print("Could not save managed object context. \(error)")
                    }
                }
                
                let dataController = AppDelegate.dataController!
                dataController.seedData()
                
                let userDefaults = UserDefaults.standard
                let logStatFromUserDefault = userDefaults.bool(forKey: "logStat")
                
                if logStatFromUserDefault == true{
                    self.networkController.fetchMyRental(completionHandler: { (rental) in
                        DispatchQueue.main.async {
                            print("fetchMyRental data:", rental)
                            let userDefaults = UserDefaults.standard
                            userDefaults.set("myRental", forKey: "fromPage")
                            
                            self.rental = rental
                            self.rentalIDArray = []
                            self.rental.forEach { (rental) in
                                self.rentalIDArray.append(rental.id)
                            }
                            print("rental ID list : ", self.rentalIDArray)
                            
                            if !self.rentalIDArray.isEmpty{
                                let numberOfObjects:Int = self.fetchedResultsController.sections?[0].numberOfObjects ?? 0
                                print("houses in db:", numberOfObjects)
                                
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
                                        }
                                    }
                                }
                                do {
                                    try self.viewContext?.save()
                                    
                                } catch {
                                    print("Could not save managed object context. \(error)")
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
        }) { (error) in
            DispatchQueue.main.async {
                print("Network fail to refresh")
                
                let alert = UIAlertController(
                    title: "Fail to refresh the page!",
                    message: "Network fail!",
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
        
        self.tableView.reloadData()
        refreshControl?.endRefreshing()
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        //        print("Houses data number in db: ", fetchedResultsController.sections?[section].numberOfObjects ?? 0)
        return fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HomeCell", for: indexPath)
        
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
                    
                }
            }
        }
        
        if let cellLabel = cell.viewWithTag(200) as? UILabel {
            cellLabel.text = fetchedResultsController.object(at: indexPath).property_title
        }
        
        if let cellLabel = cell.viewWithTag(300) as? UILabel {
            cellLabel.text = fetchedResultsController.object(at: indexPath).estate
        }
        
        if let cellLabel = cell.viewWithTag(400) as? UILabel {
            cellLabel.text = String(fetchedResultsController.object(at: indexPath).rent)
        }
        
        return cell
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
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        print("prepare runed")
        
        if let viewController = segue.destination as? DetailTableViewController{
            let selectedIndex = tableView.indexPathForSelectedRow!
            print(selectedIndex)
            
            viewController.id = fetchedResultsController.object(at: selectedIndex).id
            
            print("id passed: ", viewController.id)
        }
    }
    
    //    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
    //                    didChange anObject: Any, at indexPath: IndexPath?,
    //                    for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
    //
    //        tableView.reloadData()
    //        print("upodate table page")
    //    }
}

extension HomeTableViewController: NSFetchedResultsControllerDelegate {
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                    didChange anObject: Any, at indexPath: IndexPath?,
                    for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        tableView.reloadData()
        //        print("upodate table page")
    }
}
