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

protocol LocationControllerDelegate: NSObjectProtocol {
    func locationControllerVC(_ vc: LocationController,  didSelect location: CLLocation)
}


class LocationController: UIViewController {
    
    var location: CLLocation?
    
    var coordinate: CLLocationCoordinate2D?
    
    @IBOutlet weak var mapView: MKMapView!
    fileprivate var annotation = MKPointAnnotation()
    
    weak var delegate: LocationControllerDelegate?
    
    private var pullupViewController: MapPullupViewController {
        let currentPullUpController = children.filter({ $0 is MapPullupViewController }).first as? MapPullupViewController
        let pullUpController = currentPullUpController ?? R.storyboard.main.mapPullupVC()
        return pullUpController!
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let _ = location {
            zoom(to: location!.coordinate)
        }
        
        addPullUpController()
        mapView.addAnnotation(annotation)
    }
    
    @IBAction func onTapCancel(_ sender: Any) {
        dismiss(animated: true) {
            
        }
    }
    
    @IBAction func onTapDone(_ sender: Any) {
        
        if let coordinate = coordinate {
            delegate?.locationControllerVC(self, didSelect: CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude))
        }
        
        dismiss(animated: true) {
            
        }
    }
    
    private func addPullUpController() {
        let pullVC = self.pullupViewController
        _ = pullVC.view
        addPullUpController(pullVC,
                            initialStickyPointOffset: pullVC.initialPointOffset,
                            animated: true)
    }
    
    func zoom(to coordinate: CLLocationCoordinate2D) {
        let span = MKCoordinateSpan(latitudeDelta: 0.0045, longitudeDelta: 0.0045)
        let region = MKCoordinateRegion(center: coordinate, span: span)
        
        mapView.setRegion(region, animated: true)
        
        annotation.coordinate = coordinate
        self.coordinate = coordinate
    }
}

extension LocationController: MKMapViewDelegate {
    
}
