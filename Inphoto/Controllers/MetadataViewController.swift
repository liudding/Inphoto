//
//  MetadataViewController.swift
//  Inphoto
//
//  Created by liuding on 2018/11/29.
//  Copyright © 2018 eastree. All rights reserved.
//

import UIKit
import PullUpController

class MetadataViewController: PullUpController {

    @IBOutlet weak var tableView: UITableView!
    
    var metadata: [String: Any] = [:] {
        didSet {
            metadata = metadata.filter({$1 is [String: Any]})
            groupedMetadata = metadata.map { (arg) -> [String: Any] in
                let (key, value) = arg
                
                var group: [String: Any] = ["title": key]
                if let subDict = value as? [String: Any] {
                    let items = subDict.map({ (key: String, value: Any) -> [String: Any] in
                        return ["key": key, "value": value]
                    })
                    group["items"] = items
                }
                return group
            }
            
            groupedMetadata.sort { (first, second) -> Bool in
                if first["title"] as! String > second["title"] as! String {
                    return true
                }
                
                return false
            }
            
            tableView.reloadData()
        }
    }
    
    private var groupedMetadata = [[String: Any]]()
    fileprivate var cachedCellHeight = [IndexPath: CGFloat]()
    
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
    
    override func pullUpControllerWillMove(to stickyPoint: CGFloat) {
        //        print("will move to \(stickyPoint)")
    }
    
    override func pullUpControllerDidMove(to stickyPoint: CGFloat) {
        //        print("did move to \(stickyPoint)")
    }
    
    override func pullUpControllerDidDrag(to point: CGFloat) {
        //        print("did drag to \(point)")
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
    
    
    fileprivate func calculateTextHeight(text: String) -> CGFloat {
        
        let font:UIFont! = UIFont.systemFont(ofSize: 13)
        let attributes: [NSAttributedString.Key : Any] = [NSAttributedString.Key.font: font]
        
        let option = NSStringDrawingOptions.usesLineFragmentOrigin
        let rect:CGRect = text.boundingRect(with: CGSize(width: UIScreen.main.bounds.width/2, height: 999), options: option, attributes: attributes, context: nil)
        
        return rect.size.height
    }
    
}


extension MetadataViewController: UITableViewDataSource, UITableViewDelegate {
    // MARK: - UITableViewDataSource
    func numberOfSections(in tableView: UITableView) -> Int {
        return groupedMetadata.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let items = groupedMetadata[section]["items"] as! [[String: Any]]
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MetadataCell", for: indexPath) as! MetadataCell
        
        let items = groupedMetadata[indexPath.section]["items"] as! [[String: Any]]
        let item = items[indexPath.row]
        
        cell.titleLabel.text = item["key"] as? String
        cell.subTitleLabel.text = "\(String(describing: item["value"]!))"
        
        return cell
    }
    
    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        var height = cachedCellHeight[indexPath]
        if let h = height {
            return h
        }
        
        let items = groupedMetadata[indexPath.section]["items"] as! [[String: Any]]
        let item = items[indexPath.row]
        let text = String(describing: item["value"]!)
        height = calculateTextHeight(text: text) + 6

        cachedCellHeight[indexPath] = height!
        
        return height!
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return groupedMetadata[section]["title"] as? String
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

