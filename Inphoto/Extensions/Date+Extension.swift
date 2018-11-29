//
//  Date+Extension.swift
//  Inphoto
//
//  Created by liuding on 2018/11/25.
//  Copyright © 2018 eastree. All rights reserved.
//

import Foundation

extension Date {
    static func datetime(date: Date, time: Date) -> Date {
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let dateStr = formatter.string(from: date)
        let timeStr = formatter.string(from: time)
        
        let ymd = dateStr.prefix(10)
        let hms = timeStr.suffix(8)
        
        let newDateStr = "\(ymd) \(hms)"
        
        return formatter.date(from: newDateStr) ?? Date()
    }
}


