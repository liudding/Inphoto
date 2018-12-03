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
import JZLocationConverterSwift

class DetailViewController: UIViewController {
    
    var asset: PHAsset! {
        didSet {
            datetime = asset.creationDate
            location = asset.location
            fileName = asset.value(forKey: "filename") as? String
            
            loadAssetResources()
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
    
    private var resourcesViewController: ResourceViewController {
        let currentPullUpController = children.filter({ $0 is ResourceViewController }).first as? ResourceViewController
        let pullUpController = currentPullUpController ?? R.storyboard.main.resourceVC()
        return pullUpController!
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        PHPhotoLibrary.shared().register(self)
        
        if !isAssetTypeSupported() {
   
        }
        
        loadThumbnail()
        loadPhoto()
        
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
        showActionSheet()
    }
}

extension DetailViewController {
    
    fileprivate func updateView(with imageData: Data) {
        let image = UIImage(data: imageData)!
        self.imageView.isHidden = false
        self.imageView.image = image
        
        self.imageFile = ImageFile(imageData: imageData)
        self.preparePhotoInfos(with: imageData)
    }
    
    func formattedDatetime(_ date: Date) -> (String, String) {
        let strDate = DateFormatter.localizedString(from: date, dateStyle: .full, timeStyle: .none)
        let strTime = DateFormatter.localizedString(from: date, dateStyle: .none, timeStyle: .short)
        return (strDate, strTime)
    }
    
    func preparePhotoInfos(with imageData: Data) {
        var infos = [PhotoInfo]()
        var indexPaths = [IndexPath]()
        if let date = datetime {
            
//            let strDate = DateFormatter.localizedString(from: date, dateStyle: .full, timeStyle: .none)
//            let strTime = DateFormatter.localizedString(from: date, dateStyle: .none, timeStyle: .short)
            let (strDate, strTime) = formattedDatetime(date)
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
    
    private func saveNewMeta(shouldDeleteOld: Bool = true) {
        let meta = assembleMeta()
        
        let asset = self.asset!
        
        saveAsCopy(with: meta) { [weak self] (success, error) in
            guard success else {
                self?.displayErrorMessage(error: error)
                return
            }
            if shouldDeleteOld {
                PHPhotoLibrary.deleteAsset(asset) { [weak self] success, error in
                    guard success else {
                        self?.displayErrorMessage(error: error)
                        return
                    }
                }
            }
        }
    }
    
    
    fileprivate func assembleMeta() -> [String: Any] {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy:MM:dd HH:mm:ss"
        let formattedTime = formatter.string(from: self.datetime!)
        
        
        var meta: [String: Any] = [
            (kCGImagePropertyExifDictionary as String): [
                (kCGImagePropertyExifDateTimeOriginal as String): formattedTime
            ]
        ]
        
        if let coordinate = location?.coordinate  {
            meta[(kCGImagePropertyGPSDictionary as String)] = [
                (kCGImagePropertyGPSLatitude as String): abs(coordinate.latitude ),
                (kCGImagePropertyGPSLatitudeRef as String): coordinate.latitudeRef,
                
                (kCGImagePropertyGPSLongitude as String): abs(coordinate.longitude),
                (kCGImagePropertyGPSLongitudeRef as String): coordinate.longitudeRef,
            ]
        }
        
        return meta
    }
    
    
    // 使用原 asset 的 resource 新建一个 asset，以保证 live photo 不会变成静态照片
    
    /// save with changes that can be undo.
    fileprivate func save(with newMeta: [String: Any]) {
        let options = PHContentEditingInputRequestOptions()
        options.isNetworkAccessAllowed = true
        options.canHandleAdjustmentData = { ajustmentData in
            return true
        }
        editingInputRequestId = asset.requestContentEditingInput(with: options) {[weak self] (editingInput, info) in
            guard let input = editingInput, let imageURL = input.fullSizeImageURL else { return }
            
            let output = PHContentEditingOutput(contentEditingInput: input)
            
            let archiveData =  try? NSKeyedArchiver.archivedData(withRootObject: "inphoto", requiringSecureCoding: false)
            
            if let data = archiveData {
                let identifier = PhotoConstant.ajustmentDataIdentifier
                let adjustmentData = PHAdjustmentData(formatIdentifier: identifier, formatVersion: PhotoConstant.ajustmentDataVersion, data: data)
                output.adjustmentData = adjustmentData
            }
            
            ImageFile.saveImage(sourceURL: imageURL, destinationURL: output.renderedContentURL, type: "public.jpeg", with: newMeta)
            
            
            PHPhotoLibrary.shared().performChanges({ [weak self] in
                let asset = (self?.asset)!
                let request = PHAssetChangeRequest(for: asset)
                request.contentEditingOutput = output
                request.creationDate = self?.datetime
            }, completionHandler: { (success, error) in
                if success == false {
                    // 报错： The operation couldn’t be completed
                    print(error?.localizedDescription as Any)
                }
            })
        }
    }

    // 只更新第一个resource，保存为新的 asset
    fileprivate func saveAsCopy(with newMeta: [String: Any], completionHandler: @escaping (Bool, Error?) -> Void) {
        
        let first = self.resources.first
        let fileURL = first?.value(forKey: "fileURL") as! URL
        let tempUrl = NSURL.fileURL(withPath: NSTemporaryDirectory() + fileURL.lastPathComponent)
        ImageFile.saveImage(sourceURL: fileURL, destinationURL: tempUrl, type: "public.jpeg", with: newMeta)
        
        PHPhotoLibrary.shared().performChanges({ [weak self] in
            let creationRequest = PHAssetCreationRequest.forAsset()
            
            let options = PHAssetResourceCreationOptions()
            options.originalFilename = first?.originalFilename
            options.uniformTypeIdentifier = first?.uniformTypeIdentifier
            creationRequest.addResource(with: .photo, fileURL: tempUrl, options: options)
            
            for (index, resource) in (self?.resources.enumerated())! {
                if index == 0 {
                    continue
                }
                let options = PHAssetResourceCreationOptions()
                options.originalFilename = resource.originalFilename
                options.uniformTypeIdentifier = resource.uniformTypeIdentifier

                let fileURL = resource.value(forKey: "fileURL") as! URL
                creationRequest.addResource(with: resource.type, fileURL: fileURL, options: options)
            }
        }, completionHandler: { (success, error) -> Void in
            CleanTemp.cleanFile(tempUrl.path)
            completionHandler(success, error)
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
                print(error?.localizedDescription as Any)
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
    
    private func addResourceViewController() {
        let pullUpController = self.resourcesViewController
        pullUpController.loadViewIfNeeded()
        pullUpController.asset = asset
        addPullUpController(pullUpController,
                            initialStickyPointOffset: pullUpController.initialPointOffset,
                            animated: true)
    }
}


extension DetailViewController: UITableViewDataSource, UITableViewDelegate {
    // MARK: - Table view data source
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
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
        
        cell.location = self.location
        if let location = self.location {
            JZLocationConverter.default.wgs84ToGcj02(location.coordinate) {(coordinate) in
                cell.coordinate = coordinate
                
                let gcjLocation = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
                Geo.default().reverseGeocodeLocation(gcjLocation) { (address, error) in
                    if location == cell.location {
                        cell.addressLabel.text = address
                    }
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
               addResourceViewController()
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
            let (strDate, strTime) = formattedDatetime(newDate)
            photoInfos[0].mainInfo = strDate
            photoInfos[0].subInfo = strTime
            tableView.reloadSections(IndexSet(arrayLiteral: 0), with: .automatic)
        }
    }
}


extension DetailViewController: LocationManageControllerDelegate {
    func locationControllerVC(_ vc: LocationManageController, didSelect location: CLLocation) {
        self.location = location
        print("Location", location.coordinate)
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
    
    private func displayErrorMessage(title: String = "出错了", error: Error?) {
        if let error = error as NSError?, let errorString = error.userInfo[NSLocalizedDescriptionKey] as? String {
            let alertController = UIAlertController(title: title, message: errorString, preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "我知道了", style: .default){ (action) in
            })
            
            present(alertController, animated: true, completion: nil)
        }
    }
    
    private func showActionSheet() {
        let actionSheet = UIAlertController(title: "保存照片", message: nil, preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "保存同时删除旧照片", style: .default){ [weak self](action) in
            self?.saveNewMeta(shouldDeleteOld: true)
        })
        
        actionSheet.addAction(UIAlertAction(title: "另存为新照片", style: .default){ [weak self](action) in
            self?.saveNewMeta(shouldDeleteOld: false)
        })
        
        actionSheet.addAction(UIAlertAction(title: "取消", style: .cancel))
        
        present(actionSheet, animated: true, completion: nil)
    }
    
    
}
