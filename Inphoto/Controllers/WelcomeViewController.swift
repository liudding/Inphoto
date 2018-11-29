//
//  WelcomeViewController.swift
//  Inphoto
//
//  Created by liuding on 2018/10/23.
//  Copyright © 2018 eastree. All rights reserved.
//

import UIKit
import Photos

class WelcomeViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        
    }
    
    @IBAction func photoAuthorize(_ sender: Any) {
        PHPhotoLibrary.requestAuthorization { status -> Void in
            
            DispatchQueue.main.async {
                if status == .authorized {
                    self.dismiss(animated: true, completion: {
                        
                    })
                }
            }
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
