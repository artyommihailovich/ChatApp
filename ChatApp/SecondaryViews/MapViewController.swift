//
//  MapViewController.swift
//  ChatApp
//
//  Created by Artyom Mihailovich on 12/17/20.
//

import UIKit
import MapKit
import CoreLocation

class MapViewController: UIViewController {

    //MARK: - Variables
    
    var location: CLLocation?
    var mapView: MKMapView!
    
    
    //MARK: - View life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureMapView()
        configureTitle()
        configureBackButton()
    }
    
    
    //MARK: - Configurations
    
    private func configureMapView() {
        mapView = MKMapView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.height))
        mapView.showsUserLocation = true
        
        if location != nil {
            mapView.setCenter(location!.coordinate, animated: false)
            mapView.addAnnotation(MapAnotation(title: "\(User.currentUser!.username), location", coordinate: location!.coordinate))
        }
        
        view.addSubview(mapView)
    }
    
    private func configureBackButton() {
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "chevron.left", withConfiguration: UIImage.SymbolConfiguration(weight: .light))?.withTintColor(.systemOrange, renderingMode: .alwaysOriginal), style: .plain, target: self, action: #selector(backButtonPressed))
    }
    
    private func configureTitle() {
        self.title = "Map view"
    }
    
    
    //MARK: - Actions
    
    @objc
    func backButtonPressed() {
        self.navigationController?.popViewController(animated: false)
    }
}
