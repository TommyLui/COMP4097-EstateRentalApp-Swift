//
//  UserViewController.swift
//  RentalApp
//
//  Created by tommylui on 12/11/2020.
//

import UIKit

class UserViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        print("prepare runed")
        
        if let viewController = segue.destination as? LoginViewController{
            
            viewController.logStatus = false
            print("logStatus passed: ", viewController.logStatus)
        }
    }}
