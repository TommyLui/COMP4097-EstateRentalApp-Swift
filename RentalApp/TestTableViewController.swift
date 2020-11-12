//
//  TestTableViewController.swift
//  RentalApp
//
//  Created by tommylui on 12/11/2020.
//

import UIKit
import CoreData

class TestTableViewController: UITableViewController {
    var houses: [Houses] = []
    var viewContext: NSManagedObjectContext?
    
    lazy var fetchedResultsController: NSFetchedResultsController<HouseManagedObject> = {
        
        let fetchRequest = NSFetchRequest<HouseManagedObject>(entityName:"House")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "id", ascending:true)]
        
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
        
        let dataController = (UIApplication.shared.delegate as? AppDelegate)!.dataController!
        viewContext = dataController.persistentContainer.viewContext

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    override func tableView(_ tableView: UITableView,
                            trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let saveAction = self.contextualSaveAction(forRowAtIndexPath: indexPath)
        let swipeConfig = UISwipeActionsConfiguration(actions: [saveAction])
        
        return swipeConfig
    }
    
    func contextualSaveAction(forRowAtIndexPath indexPath: IndexPath) -> UIContextualAction {
            
        let action = UIContextualAction(style: .normal, title: "Save") {
            (contextAction: UIContextualAction, sourceView: UIView, completionHandler: (Bool) -> Void) in
            
            let house = self.fetchedResultsController.object(at: indexPath)
            house.id = 1324561
            
            do {
                // Save The object
                try self.viewContext?.save()
                
            } catch {
                print("Could not save managed object context. \(error)")
            }
            
            completionHandler(true)
        }
        
        return action
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HomeCell", for: indexPath)
        
//        print(viewContext)
        
//        print("Row number:", indexPath.row, ":")
//        let dbText = fetchedResultsController.object(at: indexPath).rent
//        print(dbText)
        
//        var url = fetchedResultsController.object(at: indexPath).image_URL
//        if url != nil{
//            if  !url.contains("https"){
//                url.insert("s", at: url.index(url.startIndex, offsetBy: 4))
//            }
//        }

//        if let imageView = cell.viewWithTag(100) as? UIImageView {
//            networkController.fetchImage(for: url, completionHandler: { (data) in
//                DispatchQueue.main.async {
//                    imageView.image = UIImage(data: data, scale:1)
//                }
//            }) { (error) in
//                DispatchQueue.main.async {
//                    imageView.image = UIImage(named: "hkbu_logo")
//                }
//            }
//        }

        if let cellLabel = cell.viewWithTag(200) as? UILabel {
            cellLabel.text = fetchedResultsController.object(at: indexPath).property_title
        }
        
        if let cellLabel = cell.viewWithTag(300) as? UILabel {
            cellLabel.text = fetchedResultsController.object(at: indexPath).estate
        }
        
        if let cellLabel = cell.viewWithTag(400) as? UILabel {
            cellLabel.text = String(fetchedResultsController.object(at: indexPath).rent)
        }
//
//        if let cellLabel = cell.viewWithTag(300) as? UILabel {
//            cellLabel.text = houses[indexPath.row].estate
//        }
//
//        if let cellLabel3 = cell.viewWithTag(400) as? UILabel {
//            cellLabel3.text = "Rent: " + String(houses[indexPath.row].rent)
//        }
        
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension TestTableViewController: NSFetchedResultsControllerDelegate {

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                    didChange anObject: Any, at indexPath: IndexPath?,
                    for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        tableView.reloadData()
        print("upodate table")
        print("viewContext: ", viewContext)
    }
}
