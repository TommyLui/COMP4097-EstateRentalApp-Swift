//
//  UserViewController.swift
//  RentalApp
//
//  Created by tommylui on 12/11/2020.
//

import UIKit

class UserViewController: UIViewController {
    var networkController = NetworkController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        let userDefaults = UserDefaults.standard
//        let logStatFromUserDefault = userDefaults.bool(forKey: "logStat")
//        let userPhotoFromUserDefault = userDefaults.string(forKey: "userPhoto")
//        let userNameFromUserDefault = userDefaults.string(forKey: "userName")
//        print("logStatFromUserDefault: ", logStatFromUserDefault)
//        if logStatFromUserDefault == true{
//            if let userPhoto = self.view.viewWithTag(100) as? UIImageView {
//                networkController.fetchImage(for: userPhotoFromUserDefault!, completionHandler: { (data) in
//                    DispatchQueue.main.async {
//                        userPhoto.image = UIImage(data: data, scale:1)
//                    }
//                }) { (error) in
//                    DispatchQueue.main.async {
//                        userPhoto.image = UIImage(named: "hkbu_logo")
//                    }
//                }
//            }
//            if let userName = self.view.viewWithTag(200) as? UILabel {
//                userName.text = userNameFromUserDefault
//            }
//            if let logButton = self.view.viewWithTag(300) as? UIButton {
//                logButton.setTitle("Logout", for: .normal)
//            }
//        }else{
//            if let logButton = self.view.viewWithTag(300) as? UIButton {
//                logButton.setTitle("Login", for: .normal)
//            }
//        }
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
