//
//  Metadata.swift
//  Inphoto
//
//  Created by liuding on 2018/11/26.
//  Copyright © 2018 eastree. All rights reserved.
//

import Foundation
import ImageIO
import CoreImage

class ImageFile {
    
    var data: Data
    var size: Int = 0
    var properties: [String: Any]
    
    init(imageData: Data) {
        self.data = imageData
        self.size = imageData.count
        let sourceRef = CGImageSourceCreateWithData(imageData as CFData, nil)!
        self.properties = CGImageSourceCopyPropertiesAtIndex(sourceRef, 0, nil) as? [String: Any] ?? [:]
    }
    
    var stringSize: String {
        let bcf = ByteCountFormatter()
        bcf.allowedUnits = [.useMB, .useKB]
        bcf.countStyle = .file
        return bcf.string(fromByteCount: Int64(self.size))
    }
    
    var pixelSize: String {
        let width = properties[kCGImagePropertyPixelWidth as String]
        let height = properties[kCGImagePropertyPixelHeight as String]
        return "\(width ?? "") × \(height ?? "")"
    }
    
    var lensInfo: String {
        let exifDict = self.properties[kCGImagePropertyExifDictionary as String] as? [String: Any]
        guard let exif = exifDict else {
            return ""
        }
        let fNumber = exif[kCGImagePropertyExifFNumber as String]
        let focalLength = exif[kCGImagePropertyExifFocalLength as String]
//        let ISOSpeed = exif[kCGImagePropertyExifISOSpeed as String]
        let ISOSpeedRatings = exif[kCGImagePropertyExifISOSpeedRatings as String]
//        let exposureTime = exif[kCGImagePropertyExifExposureTime as String] as? String
        
        var result = ""
        if fNumber != nil {
            result += "𝑓/\(fNumber!)    "
        }
        if focalLength != nil {
            result += "\(focalLength!) 毫米    "
        }
        if let isos = ISOSpeedRatings as? [Int] {
            let array = isos.map(String.init)
            let iso = array.joined(separator: " ")
            result += "ISO\(iso)    "
        }
        
//        if exposureTime != nil {
//            result += exposureTime!.prefix(<#T##maxLength: Int##Int#>)
//        }
        
        
        return result
    }
    
    var cameraModel: String {
        let tiffDict = self.properties[kCGImagePropertyTIFFDictionary as String] as? [String: Any]
        guard let tiff = tiffDict else {
            return ""
        }
        let m = tiff[kCGImagePropertyTIFFModel as String] as? String
        return m ?? ""
    }
    
    fileprivate func metadata() -> NSDictionary? {
        return self.imageSource().flatMap {
            CGImageSourceCopyPropertiesAtIndex($0, 0, nil) as NSDictionary?
        }
    }
    
    fileprivate func imageSource() ->  CGImageSource? {
        return CGImageSourceCreateWithData(data as CFData, nil)
    }
    
    
    func save(to destURL: URL, type: String = "", with properties: [String: Any] = [:]) {
        guard let sourceRef = self.imageSource() else {
            return
        }
        
        var destType: CFString
        if type == "" {
            destType = CGImageSourceGetType(sourceRef) ?? "public.jpeg" as CFString
        } else {
            destType = type as CFString
        }
        
        guard let destinationRef = CGImageDestinationCreateWithURL(destURL as CFURL, destType, 1, nil) else {
            // 不支持的类型
            return
        }
        
        ImageFile.saveImage(source: sourceRef, destination: destinationRef, with: properties)
    }
    
    class func saveImage(source: CGImageSource, destination: CGImageDestination, with properties: [String: Any]) {
        
        guard var metadata = CGImageSourceCopyPropertiesAtIndex(source, 0, nil) as? [String: Any] else {
            return
        }
        
        metadata = metadata ++ properties
        
        CGImageDestinationAddImageFromSource(destination, source, 0, metadata as CFDictionary)
        
        // Save destination
        guard CGImageDestinationFinalize(destination) else {
            return
        }
    }
    
    class func saveImage(sourceURL: URL, destinationURL: URL, type: String = "", with properties: [String: Any] = [:]) {
        guard let sourceRef = CGImageSourceCreateWithURL(sourceURL as CFURL, nil) else {
            return
        }
        
        var destType: CFString
        if type == "" {
            destType = CGImageSourceGetType(sourceRef) ?? "public.jpeg" as CFString
        } else {
            destType = type as CFString
        }
        
        
        guard var metadata = CGImageSourceCopyPropertiesAtIndex(sourceRef, 0, nil) as? [String: Any] else {
            return
        }

        metadata = metadata ++ properties
        
        guard let destinationRef = CGImageDestinationCreateWithURL(destinationURL as CFURL, destType, 1, nil) else {
            // 不支持的类型
            return
        }
 
        CGImageDestinationAddImageFromSource(destinationRef, sourceRef, 0, metadata as CFDictionary)
        
        // Save destination
        guard CGImageDestinationFinalize(destinationRef) else {
            return
        }
    }
    
}
