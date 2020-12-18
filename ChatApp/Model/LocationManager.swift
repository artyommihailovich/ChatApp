//
//  LocationManager.swift
//  ChatApp
//
//  Created by Artyom Mihailovich on 12/17/20.
//

import Foundation
import CoreLocation

class LocationManager: NSObject, CLLocationManagerDelegate {
    
    static let shared = LocationManager()
    
    private override init() {
        super.init()
        requestLocationAccess()
    }
    
    
    //MARK: - Variables
    
    var locationManager: CLLocationManager?
    var currentLocation: CLLocationCoordinate2D?
    
    
    //MARK: - Location part
    
    func requestLocationAccess() {
        if locationManager == nil {
            locationManager = CLLocationManager()
            locationManager!.delegate = self
            locationManager!.desiredAccuracy = kCLLocationAccuracyBest
            locationManager!.requestWhenInUseAuthorization()
            
        }
    }
    
    func startUpdating() {
        locationManager!.startUpdatingLocation()
    }
    
    func stopUpdating() {
        
        if locationManager != nil {
            locationManager!.stopUpdatingLocation()
        }
    }
    
    //MARK: - Location manager delegate
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        
        print("Failed to get location!")
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        currentLocation = locations.last!.coordinate
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        if manager.authorizationStatus == .notDetermined {
            self.locationManager!.requestWhenInUseAuthorization()
        }
    }
    
}
