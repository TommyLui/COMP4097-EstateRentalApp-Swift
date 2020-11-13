//
//  LoginViewController.swift
//  RentalApp
//
//  Created by tommylui on 13/11/2020.
//

import UIKit

class LoginViewController: UIViewController {
    var logStatus : Bool?
    var networkController = NetworkController()
    //var userInfo : UserInfo?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if logStatus == true{
            
        }
        // Do any additional setup after loading the view.
    }
    
    @IBAction func loginBtn(_ sender: UIButton) {
        if let accountText = self.view.viewWithTag(100) as? UITextField {
                print(accountText.text!)
            if let passwordText = self.view.viewWithTag(200) as? UITextField {
                print(passwordText.text!)
                
                networkController.fetchLogin(completionHandler: { (data) in
                    DispatchQueue.main.async {
                        self.performSegueToReturnBack()
                        print(data.username)
                        print(data.avatar)
                        
                        //存入使用者ID
                         userDefaults.set(IDTextFeild.text, forKey: "userID")
                        //存入使用者密碼
                                userDefaults.set(passwordTextField.text, forKey: "userPassword")
                        
                        //取值
                        userDefaults.value(forKey: "userID")
                        userDefaults.value(forKey: "userPassword")                    }
                }) { (error) in
                    DispatchQueue.main.async {
                        print("login fail")
                    }
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
