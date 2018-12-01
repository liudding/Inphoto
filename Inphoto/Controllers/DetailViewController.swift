//
//  DetailViewController.swift
//  Inphoto
//
//  Created by liuding on 2018/10/24.
//  Copyright © 2018 eastree. All rights reserved.
//

import UIKit
import Photos
import PhotosUI

class DetailViewController: UIViewController {
    
    var asset: PHAsset! {
        didSet {
            datetime = asset.creationDate
            location = asset.location
            fileName = asset.value(forKey: "filename") as? String
        }
    }
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var livePhotoBadgeView: UIImageView!
    @IBOutlet weak var saveButtonItem: UIBarButtonItem!
    
    fileprivate var imageRequestId: PHImageRequestID?
    fileprivate var editingInputRequestId: PHContentEditingInputRequestID?
    fileprivate let imageManager = PHCachingImageManager()
    
    fileprivate var datetime: Date?
    fileprivate var location: CLLocation?
    
    var imageFile: ImageFile?
    var fileName: String?
    private var photoInfos: [PhotoInfo] = []
    private var resources: [PHAssetResource] = []
    
    var photoSize: CGSize {
        let scale = UIScreen.main.scale
        
        return CGSize(width: UIScreen.main.bounds.width * scale,
                      height: imageView.bounds.height * scale)
    }
    
    private var metadataViewController: MetadataViewController {
        let currentPullUpController = children.filter({ $0 is MetadataViewController }).first as? MetadataViewController
        let pullUpController = currentPullUpController ?? R.storyboard.main.metadataVC()
        return pullUpController!
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        PHPhotoLibrary.shared().register(self)
        
        if !isAssetTypeSupported() {
            //            let alert = UIAlertController(title: "暂不支持的类型", message: "", preferredStyle: .alert)
            //            alert.addAction(UIAlertAction(title: "确定", style: .default) { _ in
            ////                self.navigationController?.popViewController(animated: true)
            //            })
            //            present(alert, animated: true)
            //            return
        }
        
        loadThumbnail()
        loadPhoto()
        
//        preparePhotoInfos()
        
        if asset.mediaSubtypes == .photoLive {
            livePhotoBadgeView.image = PHLivePhotoView.livePhotoBadgeImage(options: .overContent)
        }
    }
    
    deinit {
        PHPhotoLibrary.shared().unregisterChangeObserver(self)
        
        cancelPhotoWorks()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if UIDevice.current.userInterfaceIdiom == .pad {
//            ajustImageViewHeight()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    

    
    // MARK: Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == R.segue.detailViewController.detail_Date.identifier {
            let navi = segue.destination as! UINavigationController
            let datetimeVC = navi.viewControllers.first! as! DateFormViewController
            datetimeVC.originDatetime = asset.creationDate ?? Date()
            datetimeVC.delegate = self
        }
        
        if segue.identifier == R.segue.detailViewController.detail_Location.identifier {
            let navi = segue.destination as! UINavigationController
            let locationVC = navi.viewControllers.first! as! LocationManageController
            locationVC.location = location
            locationVC.locationDelegate = self
        }
    }

    @IBAction func onTapSave(_ sender: Any) {
    }
}

extension DetailViewController {
    
    fileprivate func updateView(with imageData: Data) {
        let image = UIImage(data: imageData)!
        self.imageView.isHidden = false
        self.imageView.image = image
        
        self.imageFile = ImageFile(imageData: imageData)
        self.preparePhotoInfos(with: imageData)
//        self.tableView.reloadData()
    }
    
    func preparePhotoInfos(with imageData: Data) {
        var infos = [PhotoInfo]()
        var indexPaths = [IndexPath]()
        if let date = datetime {
            
            let strDate = DateFormatter.localizedString(from: date, dateStyle: .full, timeStyle: .none)
            let strTime = DateFormatter.localizedString(from: date, dateStyle: .none, timeStyle: .short)
            let info = PhotoInfo(icon: R.image.calendar()!, mainInfo: strDate, subInfo: strTime)
            infos.append(info)
            
            indexPaths.append(IndexPath(row: 0, section: 0))
        }
        
        if fileName != nil, let imageFile = imageFile {
            let imageProperties = "\(imageFile.stringSize)    \(imageFile.pixelSize)"
            let info = PhotoInfo(icon: R.image.picture()!, mainInfo: fileName!, subInfo: imageProperties)
            infos.append(info)
            indexPaths.append(IndexPath(row: 1, section: 0))
            
            if imageFile.lensInfo != "" {
                let lensInfo = PhotoInfo(icon: R.image.cameralens()!, mainInfo: imageFile.cameraModel, subInfo: imageFile.lensInfo)
                infos.append(lensInfo)
                indexPaths.append(IndexPath(row: 2, section: 0))
            }
        }
        
        self.photoInfos = infos
        
        tableView.insertRows(at: indexPaths, with: .automatic)
    }
    
    func isAssetTypeSupported() -> Bool {
        if asset.mediaType != .image  {
            return false
        }
//        if asset.mediaSubtypes == .photoLive {
//            return true
//        }
//
        return true
    }
    
    func loadAssetResources() {
        resources = PHAssetResource.assetResources(for: asset)
    }
    
    func loadThumbnail() {
        let options = PHImageRequestOptions()
        options.deliveryMode = .fastFormat
        options.isNetworkAccessAllowed = false
        
        imageManager.requestImage(for: asset, targetSize: photoSize, contentMode: .aspectFill, options: options, resultHandler: { [weak self] image, _ in
            if let _ = image {
                self?.imageView.image = image
            }
        })
    }
    
    func loadPhoto() {
        let options = PHImageRequestOptions()
        options.deliveryMode = .highQualityFormat
        options.isNetworkAccessAllowed = true
        options.isSynchronous = false;
        options.progressHandler = {(progress: Double, _, _, _) in
            DispatchQueue.main.async {
            }
        }
        // Failed to load image data for asset
        imageRequestId = PHImageManager.default().requestImageData(for: asset, options: options, resultHandler: { [weak self] (imageData, dataUTI, orientation, info) in
            
            DispatchQueue.main.async {
                guard let data = imageData else {
                    if let error = info?[PHImageErrorKey] as? Error  {
                        self?.displayImageLoadingError(error)
                    }
                    return;
                }
                
//                let fileURL = info?["PHImageFileURLKey"] as? URL
//                self?.fileName = fileURL?.lastPathComponent
                
                self?.updateView(with: data)
            }
        })
    }

    func cancelPhotoWorks() {
        if let requestId = imageRequestId {
            PHImageManager.default().cancelImageRequest(requestId)
        }
        
        if let inputRequestId = editingInputRequestId {
            asset.cancelContentEditingInputRequest(inputRequestId)
        }
    }
    
    
    fileprivate func ajustImageViewHeight() {
        let bounds = tableView.tableHeaderView?.bounds
        let height = imageView.bounds.width * CGFloat(asset.pixelHeight) / CGFloat(asset.pixelWidth)
        tableView.tableHeaderView?.bounds = CGRect(x: 0, y: 0, width: (bounds?.width)!, height: height)
        
        self.tableView.setNeedsLayout()
    }
    
    fileprivate func changePhotoDate(_ newDate: Date) {
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy:MM:dd HH:mm:ss"

        let meta = [
            (kCGImagePropertyExifDictionary as String): [
                (kCGImagePropertyExifDateTimeOriginal as String): formatter.string(from: newDate)
            ]
        ]
        
        save(with: meta)
    }
    
    fileprivate func editAssetResource(with newMeta: [String: Any]) {
        let resources = PHAssetResource.assetResources(for: asset)
        let first = resources.first
        let fileURL = first?.value(forKey: "fileURL") as! URL
        
//        Metadata.updateImage(on: fileURL, to: fileURL, with: newMeta)
//        for item in resources {
//            print(item.value(forKey: "fileURL"))
//        }
        
        let tempUrl = NSURL.fileURL(withPath: NSTemporaryDirectory() + fileURL.lastPathComponent)
        ImageFile.saveImage(sourceURL: fileURL, destinationURL: tempUrl, with: newMeta)
        
        PHPhotoLibrary.shared().performChanges({
            let request = PHAssetCreationRequest.forAsset()
            let option = PHAssetResourceCreationOptions()
            option.originalFilename = "test.png"
            request.addResource(with: .photo, fileURL: tempUrl, options: option)
        }) { (success, error) in
            if success == true {
                print("保存成功")
            }
        }
    }
    
    // 如果是普通照片，则采用编辑
    // 如果是 live photo，则使用原 live photo 的 resource 新建一个 live photo，以保证 live photo 不会变成静态照片
    
    /// save with changes that can be undo.
    fileprivate func save(with newMeta: [String: Any]) {
        let options = PHContentEditingInputRequestOptions()
        options.isNetworkAccessAllowed = true
        options.canHandleAdjustmentData = { ajustmentData in
            return false
        }
        editingInputRequestId = asset.requestContentEditingInput(with: options) {[weak self] (editingInput, info) in
            guard let input = editingInput, let imageURL = input.fullSizeImageURL else { return }
            
            print(input.mediaType == .image, input.mediaSubtypes.rawValue)
            
            let output = PHContentEditingOutput(contentEditingInput: input)
            
            let archiveData =  try? NSKeyedArchiver.archivedData(withRootObject: "inphoto", requiringSecureCoding: false)
            
            if let data = archiveData {
                let identifier = PhotoConstant.ajustmentDataIdentifier
                let adjustmentData = PHAdjustmentData(formatIdentifier: identifier, formatVersion: PhotoConstant.ajustmentDataVersion, data: data)
                output.adjustmentData = adjustmentData
            }
            
            ImageFile.saveImage(sourceURL: imageURL, destinationURL: output.renderedContentURL, with: newMeta)
            
//            let tempUrl = NSURL.fileURL(withPath: NSTemporaryDirectory() + imageURL.lastPathComponent)
//            Metadata.updateImage(on: imageURL, to: tempUrl, with: newMeta)
            
//            let image = UIImage(contentsOfFile: tempUrl.path)!
////            let image = input.displaySizeImage!
//
//            let renderedJPEGData = image.jpegData(compressionQuality: 1)
//            try? renderedJPEGData?.write(to: output.renderedContentURL)
            
            
            PHPhotoLibrary.shared().performChanges({ [weak self] in
                let request = PHAssetChangeRequest(for: (self?.asset)!)
                request.contentEditingOutput = output
                request.creationDate = self?.datetime
            }, completionHandler: { (success, error) in
                if success == false {
                    // 报错： The operation couldn’t be completed
                    print(error, error?.localizedDescription)
                }
            })
        }
    }
    

    
    // update the first resource and keep the others
    fileprivate func saveAsCopy() {
        
        PHPhotoLibrary.shared().performChanges({ [weak self] in
            let creationRequest = PHAssetCreationRequest.forAsset()
            
            
            for resource in (self?.resources)! {
                let options = PHAssetResourceCreationOptions()
                options.originalFilename = resource.originalFilename
                options.uniformTypeIdentifier = resource.uniformTypeIdentifier
                
                let fileURL = resource.value(forKey: "fileURL") as! URL
                creationRequest.addResource(with: resource.type, fileURL: fileURL, options: options)
            }
        }, completionHandler: { (success, error) -> Void in
            if !success {
                print(error?.localizedDescription)
            }
        })
    }
    
    fileprivate func saveAsJpeg(fileURL: URL) {
        PHPhotoLibrary.shared().performChanges({
            let creationRequest = PHAssetChangeRequest.creationRequestForAssetFromImage(atFileURL: fileURL)!
            var album = PHPhotoLibrary.album(title: PhotoConstant.customAlbumTitle)
            if album == nil {
                try? PHPhotoLibrary.shared().performChangesAndWait {
                    let _ = PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: PhotoConstant.customAlbumTitle)
                }
                
                album = PHPhotoLibrary.album(title: PhotoConstant.customAlbumTitle)
            }
            
            guard let addAssetRequest = PHAssetCollectionChangeRequest(for: album!)
                else { return }
            addAssetRequest.addAssets([creationRequest.placeholderForCreatedAsset!] as NSArray)
            
        }, completionHandler: { success, error in
            if !success {
                print(error?.localizedDescription)
            }
        })
    }
    
    private func addPullUpController() {
        let pullUpController = self.metadataViewController
        _ = pullUpController.view // call pullUpController.viewDidLoad()
        pullUpController.metadata = imageFile?.properties ?? [:]
        addPullUpController(pullUpController,
                            initialStickyPointOffset: pullUpController.initialPointOffset,
                            animated: true)
    }
}


extension DetailViewController: UITableViewDataSource, UITableViewDelegate {
    // MARK: - Table view data source
    func numberOfSections(in tableView: UITableView) -> Int {
        var sections = 1
        if let _ = asset.location {
            sections += 1
        }
        return sections
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return photoInfos.count
        case 1:
            return 1
        default:
            return  0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.infoTableViewCell.identifier, for: indexPath) as! InfoTableViewCell

            let info = photoInfos[indexPath.row]
            cell.mainLabel.text = info.mainInfo
            cell.subLabel.text = info.subInfo
            cell.iconView.image = info.icon
            
            return cell
        }

        let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.mapTableViewCell.identifier, for: indexPath) as! MapTableViewCell
        
        // 在地图上展示的位置，与“照片”中显示的位置不一致
        cell.location = self.location
        if let location = self.location {
            Geo.default().reverseGeocodeLocation(location) { (address, error) in
                if location == cell.location {
                    cell.addressLabel.text = address
                }
            }
        }
        
        return cell
    }
    

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 8.0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return [60, 200][indexPath.section]
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                performSegue(withIdentifier: R.segue.detailViewController.detail_Date, sender: nil)
            } else if indexPath.row == 1 {
               
            } else if indexPath.row == 2 {
                addPullUpController()
            }
            
        }
        
        if indexPath.section == 1 {
            performSegue(withIdentifier: R.segue.detailViewController.detail_Location, sender: nil)
        }
    }
}


extension DetailViewController: PHPhotoLibraryChangeObserver {
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        guard let details = changeInstance.changeDetails(for: asset) else {
            return
        }
        
        DispatchQueue.main.async {
            guard details.objectAfterChanges != nil else {
                self.navigationController?.popViewController(animated: true)
                return
            }
            
            self.asset = details.objectAfterChanges
            
            if details.assetContentChanged {
                self.loadPhoto()
            }
        }
    }
}


extension DetailViewController: DateFormViewControllerDelegate {
    func dateFormVC(didSelectDate selectedDate: Date?) {
        if let newDate = selectedDate, datetime != selectedDate {
            datetime = newDate
            changePhotoDate(selectedDate!)
            
            tableView.reloadSections(IndexSet(arrayLiteral: 0), with: .automatic)
        }
    }
}


extension DetailViewController: LocationManageControllerDelegate {
    func locationControllerVC(_ vc: LocationManageController, didSelect location: CLLocation) {
        self.location = location
        tableView.reloadSections(IndexSet(arrayLiteral: 1), with: .automatic)
    }
}


extension DetailViewController {

    private func displayImageLoadingError(_ error: Error?) {
        if let error = error as NSError?, let errorString = error.userInfo[NSLocalizedDescriptionKey] as? String {
            let alertController = UIAlertController(title: "获取照片出错", message: errorString, preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "我知道了", style: .default){ [weak self] (action) in
                self?.dismiss(animated: true, completion: {
                })
            })
            
            present(alertController, animated: true, completion: nil)
        }
    }
}
