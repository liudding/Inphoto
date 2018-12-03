//
//  CLLocationCoordinate2D+Extension.swift
//  Inphoto
//
//  Created by liuding on 2018/12/3.
//  Copyright © 2018 eastree. All rights reserved.
//

import CoreLocation

extension CLLocationCoordinate2D {
    var latitudeRef: String {
        return self.latitude > 0 ? "N" : "S"
    }
    
    var longitudeRef: String {
        return self.longitude > 0 ? "E" : "W"
    }
}
