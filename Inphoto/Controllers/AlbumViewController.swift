//
//  AlbumViewController.swift
//  Inphoto
//
//  Created by liuding on 2018/10/23.
//  Copyright © 2018 eastree. All rights reserved.
//

import UIKit
import Photos

class AlbumViewController: UITableViewController {
    
    weak var photoGridVC: PhotoGridViewController!
    
    let albumManager = AlbumManager.default()
    var albums: [Album] = []
    
    var didSelectAlbum: ((Album) -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetchAlbumsAsync()
        
        PHPhotoLibrary.shared().register(self)
    }
    
    deinit {
        PHPhotoLibrary.shared().unregisterChangeObserver(self)
    }

    
    private func fetchAlbumsAsync() {
        /*
         * Qos: Quality of Service
         * userInteractive: 希望尽快完成，用户对结果很期望，不要放太耗时操作
         * userinitiated: 不要放太耗时操作
         **/
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.albums = self?.albumManager.fetchAlbums() ?? []
            
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
        }
    }


    @IBAction func onTapDone(_ sender: Any) {
        self.dismiss(animated: true) {
            
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

// MARK: UITableViewDataSource
extension AlbumViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return albums.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.albumCell.identifier, for: indexPath) as! AlbumTableViewCell
        
        let album = albums[indexPath.row]
        
        cell.thumbnailView.image = album.thumbnail
        cell.thumbnailView.backgroundColor = .lightGray
        cell.thumbnailView.contentMode = .scaleAspectFill
        cell.titleLabel.text = album.title
        cell.numLabel.text =  "\(album.itemsCount)"
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
}


extension AlbumViewController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let album = albums[indexPath.row]
        
        didSelectAlbum?(album)
        
        dismiss(animated: true, completion: nil)
        
        
//        let options = PHFetchOptions()
//        options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
//        photoGridVC.fetchResult = PHAsset.fetchAssets(in: album.collection as! PHAssetCollection, options: options)
//        photoGridVC.assetCollection = album.collection as! PHAssetCollection
//        photoGridVC.setTitle(album.title)
    }
}


fileprivate extension AlbumViewController {
    


    
    func getThumnail(asset: PHAsset) -> UIImage? {
        var thumnail: UIImage?
        DispatchQueue.global().sync {
            let options = PHImageRequestOptions()
            options.deliveryMode = .fastFormat
            options.isSynchronous = true
            options.isNetworkAccessAllowed = false
            PHImageManager.default().requestImage(for: asset, targetSize: CGSize(width: 40.0, height: 40.0), contentMode: .aspectFit, options: options, resultHandler: { image, _ in
                if let image = image {
                    thumnail = image
                }
            })
        }
        return thumnail
    }
}


// MARK: PHPhotoLibraryChangeObserver
extension AlbumViewController: PHPhotoLibraryChangeObserver {
    
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        
        self.fetchAlbumsAsync()
    }
}
