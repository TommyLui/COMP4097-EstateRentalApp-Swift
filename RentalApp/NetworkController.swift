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
    //func fetchLogin(for loginUrl: String, completionHandler: @escaping (Data) -> (), errorHandler: @escaping (Error?) -> ()) {
    
    func fetchLogin(completionHandler: @escaping (Data) -> (),
                    errorHandler: @escaping (Error?) -> ()) {

           let parameters = ["username": "Brittany", "password": "Hutt"]

           //create the url with URL
           let url = URL(string: "https://morning-plains-00409.herokuapp.com/user/login")! //change the url

           //create the session object
           let session = URLSession.shared

           //now create the URLRequest object using the url object
           var request = URLRequest(url: url)
           request.httpMethod = "POST" //set http method as POST

           do {
               request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted) // pass dictionary to nsdata object and set it as request body
           } catch let error {
               print(error.localizedDescription)
           }

           request.addValue("application/json", forHTTPHeaderField: "Content-Type")
           request.addValue("application/json", forHTTPHeaderField: "Accept")

           //create dataTask using the session object to send data to the server
           let task = session.dataTask(with: request as URLRequest, completionHandler: { data, response, error in

               guard error == nil else {
                   return
               }

               guard let data = data else {
                   return
               }

               do {
                   //create json object from data
                   if let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any] {
                       print("json: ", json)
                       // handle json...
                    if let response = response as? HTTPURLResponse{
                        print(response.statusCode)
                    }
                    }
               } catch let error {
                   print(error.localizedDescription)
               }
           })
           task.resume()
        
    }
    
    /*
    func fetchLogin(completionHandler: @escaping ([Houses]) -> (),
                        errorHandler: @escaping (Error?) -> ()) {
        
        let url = URL(string: "https://morning-plains-00409.herokuapp.com/user/login")!
        
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let error = error {
                // Server error encountered
                errorHandler(error)
                return
            }
            
            print("fetch data: ", data)
            
            guard let response = response as? HTTPURLResponse,
                response.statusCode < 300 else {
                    // Client error encountered
                    errorHandler(nil)
                    print("error response")
                    return
            }
            
            print("response code: ", response.statusCode)
            
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
*/
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
