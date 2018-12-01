//
//  CLPlacemark+Extension.swift
//  Inphoto
//
//  Created by liuding on 2018/11/30.
//  Copyright © 2018 eastree. All rights reserved.
//


import CoreLocation
import Contacts

extension CLPlacemark {
    var formattedAddress: String? {
        guard let postalAddress = postalAddress else { return nil }
        return CNPostalAddressFormatter.string(from: postalAddress, style: .mailingAddress).replacingOccurrences(of: "\n", with: " ")
    }
}
