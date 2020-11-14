//
//  NetworkController.swift
//  RentalApp
//
//  Created by tommylui on 11/11/2020.
//

import Foundation

class NetworkController {
    func fetchHouses(completionHandler: @escaping ([Houses]) -> (),
                        errorHandler: @escaping (Error?) -> ()) {
        
        let url = URL(string: "https://morning-plains-00409.herokuapp.com/property/json")!
        
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let error = error {
                // Server error encountered
                errorHandler(error)
                return
            }
            
            print("fetch house data: ", data)
            
            guard let response = response as? HTTPURLResponse,
                response.statusCode < 300 else {
                    // Client error encountered
                    errorHandler(nil)
                    print("error response")
                    return
            }
            
            guard let data = data, let houses =
                try? JSONDecoder().decode([Houses].self, from: data) else {
                    errorHandler(nil)
                    print("error JsonDecode")
                    return
            }
            
            // Call our completion handler with our news
            completionHandler(houses)
        }
        
        task.resume()
    }
    
    func fetchImage(for imageUrl: String, completionHandler: @escaping (Data) -> (),
                    errorHandler: @escaping (Error?) -> ()) {
        
        let url = URL(string: imageUrl)!
        
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let error = error {
                // Server error encountered
                errorHandler(error)
                return
            }
            
            guard let response = response as? HTTPURLResponse,
                response.statusCode < 300 else {
                    // Client error encountered
                    errorHandler(nil)
                    return
            }
            
            guard let data = data else {
                errorHandler(nil)
                return
            }
            
            // Call our completion handler with our news
            completionHandler(data)
        }
        task.resume()
    }
    
    //userID: String, userPW:String,
    func fetchLogin(completionHandler: @escaping (UserInfo) -> (),
                    errorHandler: @escaping (Error?) -> ()) {

           let parameters = ["username": "Brittany", "password": "Hutt"]

           let url = URL(string: "https://morning-plains-00409.herokuapp.com/user/login")!

           let session = URLSession.shared

           var request = URLRequest(url: url)
           request.httpMethod = "POST"

           do {
               request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
           } catch let error {
               print(error.localizedDescription)
           }

           request.addValue("application/json", forHTTPHeaderField: "Content-Type")
           request.addValue("application/json", forHTTPHeaderField: "Accept")

           let task = session.dataTask(with: request as URLRequest, completionHandler: { data, response, error in
               guard error == nil else {
                   return
               }
            
            guard let data = data,let userInfo = try? JSONDecoder().decode(UserInfo.self, from: data) else {
                    errorHandler(nil)
                    print("error JsonDecode")
                    return
            }
            
            
            
            completionHandler(userInfo)
           })
           task.resume()
    }
    
    func fetchLogout(completionHandler: @escaping (Int) -> (),
                    errorHandler: @escaping (Error?) -> ()) {
            var responseCode:Int = 0

           let url = URL(string: "https://morning-plains-00409.herokuapp.com/user/logout")!

           let session = URLSession.shared

           var request = URLRequest(url: url)
           request.httpMethod = "POST"

           request.addValue("application/json", forHTTPHeaderField: "Content-Type")
           request.addValue("application/json", forHTTPHeaderField: "Accept")

           let task = session.dataTask(with: request as URLRequest, completionHandler: { data, response, error in
               guard error == nil else {
                   return
               }
            
            if let response = response as? HTTPURLResponse{
//                    print("logout response code: ", response.statusCode)
                responseCode = response.statusCode
            }
            
            guard let response2 = response as? HTTPURLResponse,
                response2.statusCode < 300 else {
                    // Client error encountered
                    errorHandler(nil)
                    return
            }
            
            completionHandler(responseCode)
           })
           task.resume()
    }
    
    func fetchMyRental(completionHandler: @escaping ([Houses]) -> (),
                    errorHandler: @escaping (Error?) -> ()) {

//           let parameters = ["username": "Brittany", "password": "Hutt"]

           let url = URL(string: "https://morning-plains-00409.herokuapp.com/user/myRentals")!
        
           let session = URLSession.shared

           var request = URLRequest(url: url)
//           request.httpMethod = "POST"

//           do {
//               request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
//           } catch let error {
//               print(error.localizedDescription)
//           }

           request.addValue("application/json", forHTTPHeaderField: "Content-Type")
           request.addValue("application/json", forHTTPHeaderField: "Accept")

           let task = session.dataTask(with: request as URLRequest, completionHandler: { data, response, error in
               guard error == nil else {
                   return
               }
            
            guard let data = data,let houses = try? JSONDecoder().decode([Houses].self, from: data) else {
                    errorHandler(nil)
                    print("error JsonDecode")
                    return
            }
            completionHandler(houses)
           })
           task.resume()
    }
    
    func fetchAddRental(id: Int, completionHandler: @escaping (Int) -> (),
                    errorHandler: @escaping (Error?) -> ()) {
            
            var responseCode = 0
        
           let parameters = ["fk": id]
        
            let rentalUrl = "https://morning-plains-00409.herokuapp.com/user/rent/" + String(id)
        
            print(rentalUrl)
        
           let url = URL(string: rentalUrl)!
        
           let session = URLSession.shared

           var request = URLRequest(url: url)
           request.httpMethod = "POST"

           do {
               request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
           } catch let error {
               print(error.localizedDescription)
           }

           request.addValue("application/json", forHTTPHeaderField: "Content-Type")
           request.addValue("application/json", forHTTPHeaderField: "Accept")

           let task = session.dataTask(with: request as URLRequest, completionHandler: { data, response, error in
               guard error == nil else {
                   return
               }
            
//            guard let data = data,let houses = try? JSONDecoder().decode([Houses].self, from: data) else {
//                    errorHandler(nil)
//                    print("error JsonDecode")
//                    return
//            }
            if let response = response as? HTTPURLResponse{
//                    print("logout response code: ", response.statusCode)
                responseCode = response.statusCode
            }
            
            completionHandler(responseCode)
           })
           task.resume()
    }
}

struct Houses: Codable {
    let createdAt: Double
    let updatedAt: Double
    let id: Double
    let property_title: String
    let image_URL: String
    let estate: String
    let bedrooms: Double
    let gross_area: Double
    let expected_tenants: Double
    let rent: Double
    let h_Property: String
    let occupied: String?
}

struct UserInfo: Codable {
    let createdAt: Double
    let updatedAt: Double
    let id: Double
    let username: String
    let role: String
    let avatar: String
}
