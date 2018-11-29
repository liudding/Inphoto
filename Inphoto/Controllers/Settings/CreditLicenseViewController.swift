//
//  LicenseViewController.swift
//  Jice
//
//  Created by liuding on 2018/8/17.
//  Copyright © 2018 fivebytes. All rights reserved.
//

import UIKit
import LicensesViewController

class CreditLicenseViewController: LicensesViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.loadPlist(Bundle.main, resourceName: "Credits")
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
