//
//  PHPhotoLibrary+Extension.swift
//  Inphoto
//
//  Created by liuding on 2018/10/23.
//  Copyright © 2018 eastree. All rights reserved.
//

import Photos

extension PHAssetCollection {
    var imagesCount: Int {
        return PHAsset.fetchAssets(in: self, options: nil).count
    }
    
    func newestImage() -> PHAsset? {
        let images: PHFetchResult = PHAsset.fetchAssets(in: self, options: nil)
        if images.count > 0 {
            return images.lastObject
        }
        return nil
    }
}
