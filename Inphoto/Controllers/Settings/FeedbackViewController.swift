//
//  FeedbackViewController.swift
//  Jice
//
//  Created by liuding on 2018/8/15.
//  Copyright © 2018 fivebytes. All rights reserved.
//

import UIKit
import WebKit

class FeedbackViewController: SwiftWebVC {
    
    private let tucaoUrl = Constant.tucaoURL
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 11.0, *) {
            self.navigationItem.largeTitleDisplayMode = .never
        }
        
        self.navigationController?.navigationBar.isTranslucent = false;
        
        
        let myRequest = URLRequest(url: URL(string: tucaoUrl)!)
        self.loadRequest(myRequest)
    }
}
