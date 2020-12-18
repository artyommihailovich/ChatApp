//
//  MapAnotation.swift
//  ChatApp
//
//  Created by Artyom Mihailovich on 12/18/20.
//

import Foundation
import MapKit


class MapAnotation: NSObject, MKAnnotation {
    
    let title: String?
    let coordinate: CLLocationCoordinate2D
    
    init(title: String?, coordinate: CLLocationCoordinate2D) {
        self.title = title
        self.coordinate = coordinate
    }
}
