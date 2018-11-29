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
    
    // 更新 annotation 会 crash
    // 相册开启了优化存储。当从 iCloud 下载照片时，会 crash
    // thread backtrace
    // * thread #1, queue = 'com.apple.main-thread', stop reason = EXC_BAD_ACCESS (code=257, address=0x11ee2008a)
    // frame #0: 0x00000001a09a3314 VectorKit`-[VKAnchorWrapper _updateCachedPointWithContext:] + 84
    // frame #1: 0x00000001a0fd7868 MapKit`-[MKAnnotationContainerView _updateAnnotationViews:] + 412
    // frame #2: 0x00000001a0fd1400 MapKit`-[MKAnnotationContainerView updateAnnotationViewsForReason:] + 108
    
    var location: CLLocation? {
        didSet {
            guard let _ = location else {
                return
            }
            
            // 1 degree = 111 km
            let region = MKCoordinateRegion(center: location!.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.0045, longitudeDelta: 0.0045)) // width: 500m
            mapView.setRegion(region, animated: false)
//            mapView.setCenter(location!.coordinate, animated: false)
            annotation.coordinate = location!.coordinate
            
            
            // 有请求限制
//            CLGeocoder().reverseGeocodeLocation(location!) { [weak self] (placemarks, error) in
//                guard let placemarks = placemarks else {
//                    return
//                }
//
//                if let placemark = placemarks.first {
//                    var infos = [placemark.country, placemark.locality, placemark.thoroughfare]
//                    if let areasOfInterest = placemark.areasOfInterest {
//                        infos.append(areasOfInterest[0])
//                    }
//
//                    self?.addressLabel.text = infos.reduce("") { (locationText: String, info) in
//                        guard let infoText = info else {
//                            return locationText
//                        }
//                        return "\(locationText)" + (locationText != "" ? "、" : "") + "\(infoText)"
//                    }
//                }
//
//                for place in placemarks {
//                    print(place.name)
//                    print(place)
//                    print(place.administrativeArea, place.areasOfInterest, place.country, place.locality, place.subAdministrativeArea, place.subLocality, place.thoroughfare, place.subThoroughfare)
//                    print("=======")
//                }
//            }
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
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
        
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
//        if let ann = annotation {
//            mapView.removeAnnotation(ann)
//        }
    }

}
