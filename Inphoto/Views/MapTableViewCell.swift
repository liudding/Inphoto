//
//  MapTableViewCell.swift
//  Inphoto
//
//  Created by liuding on 2018/11/22.
//  Copyright © 2018 eastree. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit


class MapTableViewCell: UITableViewCell {
    
    var location: CLLocation?
    
    var coordinate: CLLocationCoordinate2D? {
        didSet {
            guard let _ = coordinate else {
                return
            }
            // 1 degree = 111 km
            let region = MKCoordinateRegion(center: coordinate!, span: MKCoordinateSpan(latitudeDelta: 0.0010, longitudeDelta: 0.0010))
            mapView.setRegion(region, animated: false)
            annotation.coordinate = coordinate!
        }
    }

    private var annotation: MKPointAnnotation = MKPointAnnotation()
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var addressLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        mapView.layer.cornerRadius = 10
        mapView.clipsToBounds = true
        
        mapView.addAnnotation(annotation)
        
        addressLabel.text = "无位置信息"
    }

    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.addressLabel.text = "无位置信息"
    }

}
