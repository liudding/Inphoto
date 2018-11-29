//
//  PHPhotoLibrary+Extension.swift
//  Inphoto
//
//  Created by liuding on 2018/10/23.
//  Copyright © 2018 eastree. All rights reserved.
//

import Photos


extension PHPhotoLibrary {
    
    class func checkAuthorization(completion: @escaping (Bool) -> Void) {
        let status = PHPhotoLibrary.authorizationStatus()
        switch status {
        case .notDetermined:
            completion(false)
//            PHPhotoLibrary.requestAuthorization { status -> Void in
//
//                DispatchQueue.main.async {
//                    if status != .authorized {
//                        completion(false)
//                    }
//                }
//            }
            break
        case .denied:
            completion(false)
        default:
            completion(true)
            break
        }
    }
    
    class func checkPermission(block: @escaping (Bool) -> Void) {
        
        let status = PHPhotoLibrary.authorizationStatus()
        switch status {
        case .authorized:
            block(true)
        case .restricted, .denied:
            block(false)
        case .notDetermined:
            // Show permission popup and get new status
            PHPhotoLibrary.requestAuthorization { s in
                DispatchQueue.main.async {
                    block(s == .authorized)
                }
            }
        }
    }
    
    class func album(title: String) -> PHAssetCollection? {
        let fetchOptions = PHFetchOptions()
        fetchOptions.predicate = NSPredicate(format: "title = %@", title)
        let collection = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: fetchOptions)
        
        return collection.firstObject
    }
    
    class func createAlbum(_ title: String, completionHandler: ((Bool, Error?) -> Void)? = nil) {
        PHPhotoLibrary.shared().performChanges({
            let _ = PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: title)
        }, completionHandler: completionHandler)
    }
    
    class func deleteAsset(_ asset: PHAsset, completionHandler: ((Bool, Error?) -> Void)? = nil) {
        PHPhotoLibrary.shared().performChanges({
            PHAssetChangeRequest.deleteAssets([asset] as NSFastEnumeration)
        }, completionHandler: completionHandler)
    }
}

