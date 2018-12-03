//
//  Geo.swift
//  Inphoto
//
//  Created by liuding on 2018/12/1.
//  Copyright © 2018 eastree. All rights reserved.
//

import Foundation
import CoreLocation

class Geo {
    
    let asyncCache: AsyncCache<CLLocation, String>
    static let instance = Geo()
    
    class func `default`() -> Geo {
        return instance
    }
    
    init() {
        asyncCache = try! AsyncCache<CLLocation, String>(queue: DispatchQueue(label: APP.identifier + "LocationQueue"))
    }
    
    func reverseGeocodeLocation(_ location: CLLocation, completionHandler: @escaping (String?, Error?) -> Void) {
        
        asyncCache.get(for: location) { (address, error) in
            if let addr = address {
                DispatchQueue.main.async {
                    completionHandler(addr, error)
                }
            } else {
                // 有请求限制
                
                CLGeocoder().reverseGeocodeLocation(location, preferredLocale: Locale.current) {[weak self] (placemarks, error) in
                    guard let placemarks = placemarks, let placemark = placemarks.first else {
                        return
                    }
                    
                    let addr = placemark.formattedAddress
                    if let addr = addr {
                        self?.asyncCache.set(addr, for: location, completionHandler: { (success, error) in
                        })
                    }
                    completionHandler(addr, error)
                }
            }
        }
    }
}

extension CLLocation: Keyable {
    public func toString() -> String {
        return "\(String(describing: self.coordinate))"
    }
}

