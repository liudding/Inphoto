//
//  MapPrimaryViewController.swift
//  Inphoto
//
//  Created by liuding on 2018/11/27.
//  Copyright © 2018 eastree. All rights reserved.
//

import UIKit
import MapKit
import Pulley


class MapPrimaryViewController: UIViewController {
    
    var location: CLLocation?
    
    fileprivate var coordinate: CLLocationCoordinate2D?
    fileprivate var annotation = MKPointAnnotation()
    
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
     
        if let _ = location {
            zoom(to: location!.coordinate)
        }
        
        mapView.addAnnotation(annotation)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Customize Pulley in viewWillAppear, as the view controller's viewDidLoad will run *before* Pulley's and some changes may be overwritten.
        // Uncomment if you want to change the visual effect style to dark. Note: The rest of the sample app's UI isn't made for dark theme. This just shows you how to do it.
        // drawer.drawerBackgroundVisualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
        
        // We want the 'side panel' layout in landscape iPhone / iPad, so we set this to 'automatic'. The default is 'bottomDrawer' for compatibility with older Pulley versions.
        self.pulleyViewController?.displayMode = .automatic
    }
    
    func zoom(to coordinate: CLLocationCoordinate2D) {
        let span = MKCoordinateSpan(latitudeDelta: 0.0045, longitudeDelta: 0.0045)
        let region = MKCoordinateRegion(center: coordinate, span: span)
        
        mapView.setRegion(region, animated: true)
        
        annotation.coordinate = coordinate
        self.coordinate = coordinate
        
        let locationVC = pulleyViewController as! LocationManageController
        locationVC.didSelect(coordinate: coordinate)
    }
}


extension MapPrimaryViewController: PulleyPrimaryContentControllerDelegate {
    
    func makeUIAdjustmentsForFullscreen(progress: CGFloat, bottomSafeArea: CGFloat)
    {
        guard let drawer = self.pulleyViewController, drawer.currentDisplayMode == .drawer else {
//            controlsContainer.alpha = 1.0
            return
        }
        
//        controlsContainer.alpha = 1.0 - progress
    }
    
    func drawerChangedDistanceFromBottom(drawer: PulleyViewController, distance: CGFloat, bottomSafeArea: CGFloat)
    {
        guard drawer.currentDisplayMode == .drawer else {
            
//            temperatureLabelBottomConstraint.constant = temperatureLabelBottomDistance
            return
        }
        
        if distance <= 268.0 + bottomSafeArea
        {
//            temperatureLabelBottomConstraint.constant = distance + temperatureLabelBottomDistance
        }
        else
        {
//            temperatureLabelBottomConstraint.constant = 268.0 + temperatureLabelBottomDistance
        }
    }
}

extension MapPrimaryViewController: MKMapViewDelegate {
    
}

