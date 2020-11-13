//
//  LoginViewController.swift
//  RentalApp
//
//  Created by tommylui on 13/11/2020.
//

import UIKit

class LoginViewController: UIViewController {
    var logStatus : Bool?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if logStatus == true{
            
        }
        // Do any additional setup after loading the view.
    }
    
    @IBAction func loginBtn(_ sender: UIButton) {
        if let accountText = self.view.viewWithTag(100) as? UITextField {
                print(accountText.text!)
            }
        if let passwordText = self.view.viewWithTag(200) as? UITextField {
                print(passwordText.text!)
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
