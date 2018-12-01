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
    
    var location: CLLocation? {
        didSet {
            guard let _ = location else {
                return
            }
            
            // 1 degree = 111 km
            let region = MKCoordinateRegion(center: location!.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.0010, longitudeDelta: 0.0010)) 
            mapView.setRegion(region, animated: false)
            annotation.coordinate = location!.coordinate
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
        
        addressLabel.text = nil
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
        
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.addressLabel.text = nil
    }

}
