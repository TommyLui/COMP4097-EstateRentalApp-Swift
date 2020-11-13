//
//  LoginViewController.swift
//  RentalApp
//
//  Created by tommylui on 13/11/2020.
//

import UIKit

class LoginViewController: UIViewController {
    var networkController = NetworkController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
                        self.performSegueToReturnBack()
                        print("login success")
//                        print(data.username)
//                        print(data.avatar)
                        let userDefaults = UserDefaults.standard
                        userDefaults.set(data.username, forKey: "userName")
                        userDefaults.set(data.avatar, forKey: "userPhoto")
                        userDefaults.set(true, forKey: "logStat")
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
