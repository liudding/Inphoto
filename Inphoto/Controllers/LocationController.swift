//
//  LocationController.swift
//  Inphoto
//
//  Created by liuding on 2018/11/27.
//  Copyright © 2018 eastree. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit
//import Pulley

protocol LocationControllerDelegate: NSObjectProtocol {
    func dateFormVC(didSelectDate selectedDate: Date?)
}


class LocationController: UIViewController {
    
    var location: CLLocation? {
        didSet {
            guard let _ = location else {
                return
            }
            
            let region = MKCoordinateRegion(center: location!.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005))
            mapView.setRegion(region, animated: false)
            mapView.setCenter(location!.coordinate, animated: false)
            
            let annotation: MKPointAnnotation = MKPointAnnotation()
            annotation.coordinate = location!.coordinate
        }
    }
    
    @IBOutlet weak var mapView: MKMapView!
    weak var delegate: LocationControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    @IBAction func onTapCancel(_ sender: Any) {
        dismiss(animated: true) {
            
        }
    }
    
    @IBAction func onTapDone(_ sender: Any) {
        dismiss(animated: true) {
            
        }
    }
}

extension LocationController: MKMapViewDelegate {
    
}
