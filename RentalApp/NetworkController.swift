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
            
            print("fetch data: ", data)
            
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
