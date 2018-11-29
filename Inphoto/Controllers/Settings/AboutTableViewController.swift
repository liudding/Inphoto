//
//  AboutTableViewController.swift
//  Jice
//
//  Created by liuding on 2018/8/6.
//  Copyright © 2018 fivebytes. All rights reserved.
//

import UIKit
import Armchair

class AboutTableViewController: UITableViewController {

    @IBOutlet weak var versionLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 11.0, *) {
            self.navigationItem.largeTitleDisplayMode = .never
        } else {
            // Fallback on earlier versions
        }
        
        versionLabel.text = "\(AppInfo.version ?? "") (build \(AppInfo.buildVersion!))"

    }
    // MARK: - Table view delegate
    
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 && indexPath.row == 2 {
            Armchair.rateApp()
        }
    }
}
