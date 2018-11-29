//
//  PhotoGridViewController.swift
//  Inphoto
//
//  Created by liuding on 2018/10/23.
//  Copyright © 2018 eastree. All rights reserved.
//

import UIKit
import Photos
import PhotosUI


class PhotoGridViewController: UICollectionViewController {
    @IBOutlet weak var titleView: UIButton!
    
    var fetchResult: PHFetchResult<PHAsset>!
    var assetCollection: PHAssetCollection!
    
    var album: Album?
    
    fileprivate let imageManager = PHCachingImageManager()
    
    fileprivate var lineSpace: CGFloat = 2.0
    fileprivate var itemSpace: CGFloat = 2.0
    fileprivate var numberOfItemsInRow: Int {
        get {
            if UIDevice.current.userInterfaceIdiom == .pad {
                switch UIDevice.current.orientation {
                case .portrait,
                     .portraitUpsideDown:
                    return 7
                case .landscapeLeft,
                     .landscapeRight:
                    return 8
                default:
                    return 7
                }
            }
            
            if UIDevice.current.userInterfaceIdiom == .phone {
                switch UIDevice.current.orientation {
                case .portrait,
                     .portraitUpsideDown:
                    return 4
                case .landscapeLeft,
                     .landscapeRight:
                    return 7
                default:
                    return 4
                }
            }
            
            
            return 4
        }
    }
    
    fileprivate var thumbnailSize: CGSize!
    fileprivate var cellSize: CGSize!

    override func viewDidLoad() {
        super.viewDidLoad()

        if fetchResult == nil {
            let allPhotosOptions = PHFetchOptions()
            allPhotosOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
            allPhotosOptions.predicate = NSPredicate(format: "mediaType = %d", PHAssetMediaType.image.rawValue)
            fetchResult = PHAsset.fetchAssets(with: allPhotosOptions)
        } else {
            resetCachedAssets()
        }
        
        PHPhotoLibrary.shared().register(self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        cellSize = calculateCellSize()
        thumbnailSize = CGSize(width: cellSize.width * UIScreen.main.scale, height: cellSize.height * UIScreen.main.scale)
        
        checkPermission { (hasPerm) in
            
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    deinit {
        PHPhotoLibrary.shared().unregisterChangeObserver(self)
    }
    
    func checkPermission(block: @escaping (Bool) -> Void) {
        
        let status = PHPhotoLibrary.authorizationStatus()
        switch status {
        case .authorized:
            block(true)
        case .restricted, .denied:
            let alert = UIAlertController(title: "相册未授权", message: "", preferredStyle: .alert)
            alert.addAction(
                UIAlertAction(title: "取消",
                              style: UIAlertAction.Style.cancel,
                              handler: { _ in
                                block(false)
                }))
            alert.addAction(
                UIAlertAction(title: "去授权",
                              style: .default,
                              handler: { _ in
                                if #available(iOS 10.0, *) {
                                    UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
                                }
                }))
            
            present(alert, animated: true, completion: nil)
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization { s in
                DispatchQueue.main.async {
                    block(s == .authorized)
                }
            }
        }
    }
    
    func loadAlbum(_ album: Album) {
        
        let options = PHFetchOptions()
        options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        options.predicate = NSPredicate(format: "mediaType = %d", PHAssetMediaType.image.rawValue) // 仅查询图片
        self.fetchResult = PHAsset.fetchAssets(in: album.collection!, options: options)
        
        self.assetCollection = album.collection
        self.setTitle(album.title)
        self.collectionView?.reloadData()
        scrollToTop()
        resetCachedAssets()
    }
    
    func calculateCellSize() -> CGSize {
        let margins = itemSpace * CGFloat(numberOfItemsInRow - 1)
        let width = (collectionView!.bounds.width - margins) / CGFloat(numberOfItemsInRow)
        return CGSize(width: width, height: width)
    }
    
    func scrollToTop() {
        collectionView?.scrollToItem(at: IndexPath(item: 0, section: 0), at: .top, animated: false)
    }
    
    
    // MARK: Asset Caching
    fileprivate func resetCachedAssets() {
        imageManager.stopCachingImagesForAllAssets()
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == R.segue.photoGridViewController.grid_Album.identifier {
            if let navi = segue.destination as? UINavigationController, let albumVC = navi.viewControllers.first as? AlbumViewController {
                albumVC.didSelectAlbum = { [weak self] album in
                    self?.loadAlbum(album)
                }
            }
        }
        
        if let dest = segue.destination as? DetailViewController {
            
            guard let cell = sender as? UICollectionViewCell else {
                return
            }
            
            let indexPath = collectionView!.indexPath(for: cell)!
            
            dest.asset = fetchResult.object(at: indexPath.item)
        }
    }
    

    // MARK: UICollectionViewDataSource

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fetchResult.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: R.reuseIdentifier.photoCell.identifier, for: indexPath) as! PhotoCollectionViewCell
        
        
        let asset = fetchResult.object(at: indexPath.item)
    
        if asset.mediaSubtypes.contains(.photoLive) {
            cell.isLivePhoto = true
        }

        cell.assetIdentifier = asset.localIdentifier
        imageManager.requestImage(for: asset, targetSize: thumbnailSize, contentMode: .aspectFill, options: nil, resultHandler: { image, _ in
            if cell.assetIdentifier == asset.localIdentifier {
                cell.photoImageView.image = image
            }
        })
        
    
        return cell
    }


}


extension PhotoGridViewController: PHPhotoLibraryChangeObserver {
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        guard let changes = changeInstance.changeDetails(for: fetchResult) else {
            return
        }
        
        DispatchQueue.main.sync {
            self.fetchResult = changes.fetchResultAfterChanges
            if changes.hasIncrementalChanges {
                guard let collectionView = self.collectionView else { fatalError() }
                collectionView.performBatchUpdates({
                    
                    if let removed = changes.removedIndexes, removed.count > 0 {
                        collectionView.deleteItems(at: removed.map({ IndexPath(item: $0, section: 0) }))
                    }
                    
                    if let inserted = changes.insertedIndexes, inserted.count > 0 {
                        collectionView.insertItems(at: inserted.map({ IndexPath(item: $0, section: 0) }))
                    }
                    
//                    if let changed = changes.changedIndexes, changed.count > 0 {
//                        collectionView.reloadItems(at: changed.map({ IndexPath(item: $0, section: 0) }))
//                    }
                    
                    if changes.hasMoves {
                        // 'attempt to perform a delete and a move from the same index path (<NSIndexPath: {length = 2, path = 0 - 0})'
                        changes.enumerateMoves { fromIndex, toIndex in
                            print(fromIndex, toIndex)
                            collectionView.moveItem(at: IndexPath(item: fromIndex, section: 0),
                                                    to: IndexPath(item: toIndex, section: 0))
                        }
                    }
                })
            } else {
                self.collectionView!.reloadData()
            }
            self.resetCachedAssets()
        }
        
        
    }
    
    
}

extension PhotoGridViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return cellSize
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: lineSpace, left: 0, bottom: lineSpace, right: 0)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return itemSpace
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return lineSpace
    }
    
}



extension PhotoGridViewController: UICollectionViewDataSourcePrefetching {
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        let prefetchs = indexPaths.map { (indexPath) -> PHAsset in
            fetchResult.object(at: indexPath.item)
        }
        imageManager.startCachingImages(for: prefetchs, targetSize: thumbnailSize, contentMode: .aspectFill, options: nil)
    }
    
    func collectionView(_ collectionView: UICollectionView, cancelPrefetchingForItemsAt indexPaths: [IndexPath]) {
        let canceled = indexPaths.map { (indexPath) -> PHAsset in
            fetchResult.object(at: indexPath.item)
        }
        
        imageManager.stopCachingImages(for: canceled, targetSize: thumbnailSize, contentMode: .aspectFill, options: nil)
    }
}


extension PhotoGridViewController {
    func setTitle(_ title: String) {
        titleView.setTitle(title, for: .normal)
    }
}
