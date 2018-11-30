//
//  LocationManageController.swift
//  Inphoto
//
//  Created by liuding on 2018/11/28.
//  Copyright © 2018 eastree. All rights reserved.
//

import UIKit
import Pulley
import CoreLocation


protocol LocationManageControllerDelegate: NSObjectProtocol {
    func locationControllerVC(_ vc: LocationManageController,  didSelect location: CLLocation)
}


class LocationManageController: PulleyViewController {
    
    var location: CLLocation? {
        didSet {
            loadViewIfNeeded()
            
            let primaryVC = primaryContentViewController as! MapPrimaryViewController
            primaryVC.location = location
        }
    }
    
    weak var locationDelegate: LocationManageControllerDelegate?
    
    var coordinate: CLLocationCoordinate2D?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
    }
    
    @IBAction func onTapCancel(_ sender: Any) {
        dismiss(animated: true) {
            
        }
    }
    @IBAction func onTapDone(_ sender: Any) {
        if let coordinate = coordinate {
            locationDelegate?.locationControllerVC(self, didSelect: CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude))
        }
        
        dismiss(animated: true) {
            
        }
        
    }
    
    func didSelect(coordinate: CLLocationCoordinate2D) {
        self.coordinate = coordinate
    }
}
