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
import JZLocationConverterSwift


class MapPrimaryViewController: UIViewController {
    
    var location: CLLocation? {
        didSet {
            if let _ = location {
                zoom(to: location!.coordinate)
            }
        }
    }
    
    fileprivate var coordinate: CLLocationCoordinate2D?
    fileprivate var annotation = MKPointAnnotation()
    
    @IBOutlet weak var mapView: MKMapView!
    private var longPressCatched: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.addAnnotation(annotation)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.pulleyViewController?.displayMode = .automatic
    }

    
    func zoom(to wgsCoordinate: CLLocationCoordinate2D, changeSpan: Bool = true) {
        JZLocationConverter.default.wgs84ToGcj02(wgsCoordinate) { [weak self] (coordinate) in
            if changeSpan {
                let span = MKCoordinateSpan(latitudeDelta: 0.0045, longitudeDelta: 0.0045)
                let region = MKCoordinateRegion(center: coordinate, span: span)
                self?.mapView.setRegion(region, animated: true)
            } else {
                self?.mapView.setCenter(coordinate, animated: true)
            }
            self?.annotation.coordinate = coordinate
        }
    }
    
    func didSelect(coordinate: CLLocationCoordinate2D, changeSpan: Bool = true) {
        JZLocationConverter.default.gcj02ToWgs84(coordinate) { [weak self](wgsCoor) in
            self?.coordinate = wgsCoor
            let locationVC = self?.pulleyViewController as! LocationManageController
            locationVC.didSelect(coordinate: wgsCoor)
            
            self?.zoom(to: wgsCoor, changeSpan: changeSpan)
        }
    }
    
    @IBAction func onTapInfo(_ sender: Any) {
        
    }
    
    @IBAction func onTapRevert(_ sender: Any) {
    }
    
    @IBAction func onLongPress(_ sender: UILongPressGestureRecognizer) {
        if sender.state == .began {
            return
        }
        
        if sender.state == .ended {
            longPressCatched = false
            return
        }
        
        if longPressCatched {
            return
        }
        
        longPressCatched = true
        
        let point = sender.location(in: mapView)
        let coordinate = mapView.convert(point, toCoordinateFrom: mapView)
        
        didSelect(coordinate: coordinate, changeSpan: false)
    }
   
    @IBAction func onTapMap(_ sender: UITapGestureRecognizer) {
        
    }
}

extension MapPrimaryViewController {
    fileprivate func switchMapType(_ type: UInt) {
        mapView.mapType = MKMapType(rawValue: type) ?? .standard
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
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, didChange newState: MKAnnotationView.DragState, fromOldState oldState: MKAnnotationView.DragState) {
        if newState == .ending {
            didSelect(coordinate: view.annotation!.coordinate)
        }
    }
}


extension MapPrimaryViewController: UIGestureRecognizerDelegate {
    
}
