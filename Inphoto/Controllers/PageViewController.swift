//
//  PageViewController.swift
//  Inphoto
//
//  Created by liuding on 2018/10/24.
//  Copyright © 2018 eastree. All rights reserved.
//

import UIKit
import Photos
import Pageboy

class PageViewController: PageboyViewController {
    
    var currentDetailVC: DetailViewController!
    var page: Int = 0
    var currentAsset: PHAsset!
    var fetchResult: PHFetchResult<PHAsset>!
    
    let imageManager = PHCachingImageManager()
    var previousCachedByPage = 0

    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        
        self.dataSource = self
        self.delegate = self
        
        self.scrollToPage(.at(index: page), animated: false)
    }
    
    
    
    @IBAction func onTapDate(_ sender: Any) {
        
    }
    
    @IBAction func onTapLocation(_ sender: Any) {
    }
    
    

    
    // MARK: Func
    
    func updateNaviBar() {
//        self.title =
    }
    
    private func loadAsset(_ asset: PHAsset) {
        let options = PHImageRequestOptions()
        options.isNetworkAccessAllowed = true
        options.isSynchronous = true
        
        PHImageManager.default().requestImage(for: asset, targetSize: PHImageManagerMaximumSize, contentMode: .aspectFill, options: options) { (image, info) in
            
        }
    }
    
    private func updateCachedAssets(by page: Int) {
        
        let preheat = 4
        let space = 2
        
        if abs(page - previousCachedByPage) < space {
            return
        }
        
        var prefetchs = [PHAsset]()
        let range = (page-preheat)...(page+preheat)
        for index in range {
            if index == page || index < 0 || index >= fetchResult.count {
                continue
            }
            
            prefetchs.append(fetchResult.object(at: index))
        }
        
        var removed = [PHAsset]()
        for index in (previousCachedByPage-preheat)...(previousCachedByPage+preheat) {
            if range.contains(index) {
                continue
            }
            if index < 0 || index >= fetchResult.count {
                continue
            }
            removed.append(fetchResult.object(at: index))
        }
        
        
        imageManager.startCachingImages(for: prefetchs, targetSize: PHImageManagerMaximumSize, contentMode: .aspectFill, options: nil)
        imageManager.stopCachingImages(for: removed, targetSize: PHImageManagerMaximumSize, contentMode: .aspectFill, options: nil)
    }
    
    private func getDetailVC(index: Int) -> DetailViewController? {
        
        guard index >= 0 && index < fetchResult.count else {
            return nil
        }
        
        let asset = fetchResult.object(at: index)
        let detailVC = R.storyboard.main.photoDetail()!
        detailVC.asset = asset
        
        
        return detailVC
    }
    
    
    // MARK: Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        
        if segue.identifier == R.segue.pageViewController.page_Date.identifier {
//            let navi = segue.destination as! UINavigationController
//            let datetimeVC = navi.viewControllers.first! as! DatetimeViewController
//            datetimeVC.delegate = self
        }
    }

}


extension PageViewController {
    func changeAssect(date: Date) {
        PHPhotoLibrary.shared().performChanges({
            
            let request = PHAssetChangeRequest(for: self.currentAsset)
            
            request.creationDate = Date()
        }) { (success, error) in
            if success == true {
                print("修改成功")
            }
        }
    }
}


extension PageViewController: PageboyViewControllerDataSource, PageboyViewControllerDelegate {
    func numberOfViewControllers(in pageboyViewController: PageboyViewController) -> Int {
        return fetchResult.count
    }
    
    func viewController(for pageboyViewController: PageboyViewController, at index: PageboyViewController.PageIndex) -> UIViewController? {
        
        return getDetailVC(index: index)
    }
    
    func defaultPage(for pageboyViewController: PageboyViewController) -> PageboyViewController.Page? {
        return nil
    }
    
    func pageboyViewController(_ pageboyViewController: PageboyViewController, didScrollToPageAt index: Int, direction: PageboyViewController.NavigationDirection, animated: Bool) {
        page = index
        currentDetailVC = (pageboyViewController.currentViewController as! DetailViewController)
        currentAsset = currentDetailVC.asset
        
        dateLabel.text = ""
        locationLabel.text = ""
        
//        if let location = currentAsset.location {
//            CLGeocoder().reverseGeocodeLocation(location) { (placemarks, error) in
//                guard let placemarks = placemarks else {
//                    return
//                }
//                
//                if let placemark = placemarks.first {
//                    let infos = [placemark.thoroughfare, placemark.locality, placemark.administrativeArea, placemark.country]
//                    
//                    self.locationLabel.text = infos.reduce("") { (locaitonText: String, info) in
//                        guard let infoText = info else {
//                            return ""
//                        }
//                        return "\(locaitonText)" + (locaitonText != "" ? "," : "") + "\(infoText)"
//                    }
//                }
//                
//            }
//        }
        
        
    }
    
}

//extension PageViewController: UIPopoverPresentationControllerDelegate {
//    func popoverPresentationControllerDidDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) {
//        if let popover = datetimePickerVC {
//            if let date = popover.selectedDate {
//                changeAssect(date: date)
//            }
//        }
//    }
//}

