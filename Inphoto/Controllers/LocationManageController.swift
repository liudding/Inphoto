//
//  LocationManageController.swift
//  Inphoto
//
//  Created by liuding on 2018/11/28.
//  Copyright © 2018 eastree. All rights reserved.
//

import UIKit
import Pulley

class LocationManageController: PulleyViewController {
    
//    @IBOutlet weak var primaryContainerView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
    }
    
    @IBAction func onTapCancel(_ sender: Any) {
        dismiss(animated: true) {
            
        }
    }
    @IBAction func onTapDone(_ sender: Any) {
    }
}
