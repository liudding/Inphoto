//
//  ResourceViewController.swift
//  Inphoto
//
//  Created by liuding on 2018/12/3.
//  Copyright © 2018 eastree. All rights reserved.
//

import UIKit
import Photos
import PullUpController

class ResourceViewController: PullUpController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var asset: PHAsset? {
        didSet {
            loadAssetResources()
            tableView.reloadData()
        }
    }
    var resources: [PHAssetResource] = []
    
    var initialPointOffset: CGFloat {
        return pullUpControllerPreferredSize.height
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.attach(to: self)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        view.layer.cornerRadius = 12
        view.clipsToBounds = true
    }
    
    
    func loadAssetResources() {
        guard let asset = asset else {
            return
        }

        resources = PHAssetResource.assetResources(for: asset)
        print(resources)
    }
    
    
    // MARK: - PullUpController
    
    override var pullUpControllerPreferredSize: CGSize {
        return CGSize(width: min(UIScreen.main.bounds.width, UIScreen.main.bounds.height),
                      height: UIScreen.main.bounds.height * 2/3)
    }
    
    override var pullUpControllerPreferredLandscapeFrame: CGRect {
        return CGRect(x: 10, y: 10, width: 300, height: UIScreen.main.bounds.height - 20)
    }
    
    override var pullUpControllerMiddleStickyPoints: [CGFloat] {
        return [0, UIScreen.main.bounds.height * 2/3]
    }
    
    override var pullUpControllerBounceOffset: CGFloat {
        return 20
    }
    
    override func pullUpControllerAnimate(action: PullUpController.Action,
                                          withDuration duration: TimeInterval,
                                          animations: @escaping () -> Void,
                                          completion: ((Bool) -> Void)?) {
        switch action {
        case .move:
            UIView.animate(withDuration: 0.3,
                           delay: 0,
                           usingSpringWithDamping: 0.7,
                           initialSpringVelocity: 0,
                           options: .curveEaseInOut,
                           animations: animations,
                           completion: completion)
        default:
            UIView.animate(withDuration: 0.3,
                           animations: animations,
                           completion: completion)
        }
    }
    
}


extension ResourceViewController: UITableViewDataSource, UITableViewDelegate {
    // MARK: - UITableViewDataSource
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return resources.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.resourceCell.identifier, for: indexPath) as! ResourceTableViewCell
        
        let item = resources[indexPath.row]
        
        cell.resourceImageView.image = nil
        cell.titleLabel.text = item.originalFilename
        let filesize = item.value(forKey: "fileSize") as! Int
        cell.subtitleLabel.text = "\(filesize.fileSize)"
        
        return cell
    }
    
    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 66
    }
    
//    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//        return 40
//    }
//
//    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//        return "ttt"
//    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

