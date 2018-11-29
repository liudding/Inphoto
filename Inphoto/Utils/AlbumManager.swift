//
//  AlbumManager.swift
//  Inphoto
//
//  Created by liuding on 2018/11/23.
//  Copyright © 2018 eastree. All rights reserved.
//

import Foundation
import Photos

class AlbumManager: NSObject {
    
    static let instance = AlbumManager()
    
    class func `default`() -> AlbumManager {
        return instance
    }
    
    private var cachedAlbums: [Album]?
    
//    
//    init() {
//        PHPhotoLibrary.shared().register(self)
//    }
//    
//    deinit {
//        PHPhotoLibrary.shared().unregisterChangeObserver(self)
//    }
    
    
    public func fetchAlbums(force: Bool = false) -> [Album] {
        if !force, let cachedAlbums = cachedAlbums {
            return cachedAlbums
        }
        
        var albums:[Album] = []
        
        let options = PHFetchOptions()
        
        let albumsResult = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: options)
        let smartAlbumsResult = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .any, options: options)

        for result in [smartAlbumsResult, albumsResult] {
            result.enumerateObjects { (collection, start, stop) in
                
                // 过滤掉视频相册
                if collection.assetCollectionSubtype == .smartAlbumVideos || collection.assetCollectionSubtype == .smartAlbumSlomoVideos {
                    return
                }
                
                var album = Album()
                album.title = collection.localizedTitle!
                let assetOptions = PHFetchOptions()
                assetOptions.predicate = NSPredicate(format: "mediaType = %d", PHAssetMediaType.image.rawValue) // 仅查询图片
                let fetchResult = PHAsset.fetchAssets(in: collection, options: assetOptions)
                
                if fetchResult.count == 0 { // 过滤掉空相册
                    return
                }
                
                let keyAssets = PHAsset.fetchKeyAssets(in: collection, options: nil)
                if let firstAsset = keyAssets?.firstObject {
                    let options = PHImageRequestOptions()
                    options.isSynchronous = true
                    options.deliveryMode = .fastFormat
                    PHImageManager.default().requestImage(for: firstAsset, targetSize: CGSize(width: 40, height: 40), contentMode: .aspectFill, options: options, resultHandler: { (image, _) in
                        album.thumbnail = image
                    })
                }
                
                album.collection = collection
                album.itemsCount = fetchResult.count
                
                albums.append(album)
            }
        }
        
        cachedAlbums = albums
        
        return albums
    }
}
//
//extension AlbumManager: PHPhotoLibraryChangeObserver {
//    func photoLibraryDidChange(_ changeInstance: PHChange) {
//
//    }
//}
