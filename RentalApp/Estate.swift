//
//  Estate.swift
//  RentalApp
//
//  Created by tommylui on 15/11/2020.
//

import Foundation
import MapKit

class Estate: NSObject, MKAnnotation {
    
    let title: String?
    let estateName: String
    let coordinate: CLLocationCoordinate2D
    
    var subtitle: String? {
        return "\(title), \(estateName) "
    }
    
    init(
        title: String?,
        estateName: String,
        coordinate: CLLocationCoordinate2D
    ) {
        self.title = title
        self.estateName = estateName
        self.coordinate = coordinate
    }
    
}
