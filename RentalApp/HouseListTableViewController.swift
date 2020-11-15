//
//  HouseListTableViewController.swift
//  RentalApp
//
//  Created by tommylui on 12/11/2020.
//

import UIKit
import CoreData

class HouseListTableViewController: UITableViewController {
    
    var roomSelect: Int?
    var estateSelect: String?
    var houseDetail: [Houses] = []
    var networkController = NetworkController()
    var viewContext: NSManagedObjectContext?
    var rentalIDArray: [Int] = []
    
    lazy var fetchedResultsController: NSFetchedResultsController<HouseManagedObject> = {
        
        let fetchRequest = NSFetchRequest<HouseManagedObject>(entityName:"House")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "id", ascending:true)]
        
        let userDefaults = UserDefaults.standard
        let fromPage = userDefaults.string(forKey: "fromPage")
        print("fromPage: ", fromPage)
        
        if fromPage == "roomPage"{
        if let roomSelect = roomSelect {
            if roomSelect as! Int == 0 {
                fetchRequest.predicate = NSPredicate(format: "bedrooms <= 2")
            }
            if roomSelect as! Int == 1 {
                fetchRequest.predicate = NSPredicate(format: "bedrooms >= 3")
            }
            print("rooom search: ", roomSelect)
        }
        }
        
        if fromPage == "estatePage"{
        if let estateSelect = estateSelect {
            fetchRequest.predicate = NSPredicate(format: "estate = %@", estateSelect)
        }
        }
        
        if fromPage == "myRental"{
            fetchRequest.predicate = NSPredicate(format: "isRental = true")
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
    
    override func viewDidAppear(_ animated: Bool) {
        let dataNum = fetchedResultsController.sections?[0].numberOfObjects ?? 0
        print("dataNum: ", dataNum)
        let userDefaults = UserDefaults.standard
        let logStatFromUserDefault = userDefaults.bool(forKey: "logStat")
        let fromPage = userDefaults.string(forKey: "fromPage")
        
        if dataNum == 0 && logStatFromUserDefault != true{
        let alert = UIAlertController(
                        title: "Not yet login and no local data!",
                        message: "",
                        preferredStyle: .alert)

                    alert.addAction(
                        UIAlertAction(title: "OK", style: .default, handler: { (action) in
                            print("myRental alert OK button pressed!")
                            DispatchQueue.main.async {
                                self.performSegueToReturnBack()
                            }
                        })
                    )
            self.present(alert, animated: true, completion: nil)
        }else if dataNum == 0 && logStatFromUserDefault == true{
            let alert = UIAlertController(
                            title: "Logined but no record found!",
                            message: "",
                            preferredStyle: .alert)

                        alert.addAction(
                            UIAlertAction(title: "OK", style: .default, handler: { (action) in
                                print("myRental alert OK button pressed!")
                                DispatchQueue.main.async {
                                    self.performSegueToReturnBack()
                                }
                            })
                        )
                self.present(alert, animated: true, completion: nil)
        }else if dataNum != 0 && logStatFromUserDefault != true && fromPage == "myRental"{
            let alert = UIAlertController(
                            title: "Not yet login!",
                            message: "Data loaded form local!",
                            preferredStyle: .alert)

                        alert.addAction(
                            UIAlertAction(title: "OK", style: .default, handler: { (action) in
                                print("myRental alert OK button pressed!")
                            })
                        )
                self.present(alert, animated: true, completion: nil)
        }
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
//        print("Houses list number in db: ", fetchedResultsController.sections?[section].numberOfObjects ?? 0)
        return fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HouseListCell", for: indexPath)
        
        // cell.textLabel?.text = "Section number: \(indexPath.section), Row number: \(indexPath.row)"
        
        cell.textLabel?.text = fetchedResultsController.object(at: indexPath).property_title
        
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
}

extension HouseListTableViewController: NSFetchedResultsControllerDelegate {

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                    didChange anObject: Any, at indexPath: IndexPath?,
                    for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        tableView.reloadData()
        print("upodate houses list page")
    }
}
