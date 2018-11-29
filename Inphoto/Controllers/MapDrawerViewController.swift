//
//  MapDrawerViewController.swift
//  Inphoto
//
//  Created by liuding on 2018/11/27.
//  Copyright © 2018 eastree. All rights reserved.
//

import UIKit
import Pulley

class MapDrawerViewController: UIViewController {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var gripperView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        gripperView.layer.cornerRadius = 2.5
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if #available(iOS 10.0, *)
        {
            let feedbackGenerator = UISelectionFeedbackGenerator()
            self.pulleyViewController?.feedbackGenerator = feedbackGenerator
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // The bounce here is optional, but it's done automatically after appearance as a demonstration.
        Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(bounceDrawer), userInfo: nil, repeats: false)
    }
    
    @objc fileprivate func bounceDrawer() {
        
        // We can 'bounce' the drawer to show users that the drawer needs their attention. There are optional parameters you can pass this method to control the bounce height and speed.
        self.pulleyViewController?.bounceDrawer(bounceHeight: 10)
    }
}


extension MapDrawerViewController: PulleyDrawerViewControllerDelegate {
    
    func collapsedDrawerHeight(bottomSafeArea: CGFloat) -> CGFloat
    {
        // For devices with a bottom safe area, we want to make our drawer taller. Your implementation may not want to do that. In that case, disregard the bottomSafeArea value.
        return 68.0 + (pulleyViewController?.currentDisplayMode == .drawer ? bottomSafeArea : 0.0)
    }
    
    func partialRevealDrawerHeight(bottomSafeArea: CGFloat) -> CGFloat
    {
        // For devices with a bottom safe area, we want to make our drawer taller. Your implementation may not want to do that. In that case, disregard the bottomSafeArea value.
        return 264.0 + (pulleyViewController?.currentDisplayMode == .drawer ? bottomSafeArea : 0.0)
    }
    
    func supportedDrawerPositions() -> [PulleyPosition] {
        return PulleyPosition.all // You can specify the drawer positions you support. This is the same as: [.open, .partiallyRevealed, .collapsed, .closed]
    }
    
    // This function is called by Pulley anytime the size, drawer position, etc. changes. It's best to customize your VC UI based on the bottomSafeArea here (if needed). Note: You might also find the `pulleySafeAreaInsets` property on Pulley useful to get Pulley's current safe area insets in a backwards compatible (with iOS < 11) way. If you need this information for use in your layout, you can also access it directly by using `drawerDistanceFromBottom` at any time.
    func drawerPositionDidChange(drawer: PulleyViewController, bottomSafeArea: CGFloat)
    {
        // We want to know about the safe area to customize our UI. Our UI customization logic is in the didSet for this variable.
//        drawerBottomSafeArea = bottomSafeArea
        
        /*
         Some explanation for what is happening here:
         1. Our drawer UI needs some customization to look 'correct' on devices like the iPhone X, with a bottom safe area inset.
         2. We only need this when it's in the 'collapsed' position, so we'll add some safe area when it's collapsed and remove it when it's not.
         3. These changes are captured in an animation block (when necessary) by Pulley, so these changes will be animated along-side the drawer automatically.
         */
        if drawer.drawerPosition == .collapsed
        {
//            headerSectionHeightConstraint.constant = 68.0 + drawerBottomSafeArea
        }
        else
        {
//            headerSectionHeightConstraint.constant = 68.0
        }
        
        // Handle tableview scrolling / searchbar editing
        
        tableView.isScrollEnabled = drawer.drawerPosition == .open || drawer.currentDisplayMode == .panel
        
        if drawer.drawerPosition != .open
        {
            searchBar.resignFirstResponder()
        }
        
        if drawer.currentDisplayMode == .panel
        {
//            topSeparatorView.isHidden = drawer.drawerPosition == .collapsed
//            bottomSeperatorView.isHidden = drawer.drawerPosition == .collapsed
        }
        else
        {
//            topSeparatorView.isHidden = false
//            bottomSeperatorView.isHidden = true
        }
    }
    
    /// This function is called when the current drawer display mode changes. Make UI customizations here.
    func drawerDisplayModeDidChange(drawer: PulleyViewController) {
        
        print("Drawer: \(drawer.currentDisplayMode)")
//        gripperTopConstraint.isActive = drawer.currentDisplayMode == .drawer
    }
}

extension MapDrawerViewController: UISearchBarDelegate {
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        pulleyViewController?.setDrawerPosition(position: .open, animated: true)
    }
}

extension MapDrawerViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 50
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return tableView.dequeueReusableCell(withIdentifier: "SampleCell", for: indexPath)
    }
}

extension MapDrawerViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 81.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
//        let primaryContent = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "PrimaryTransitionTargetViewController")
        
        pulleyViewController?.setDrawerPosition(position: .collapsed, animated: true)
        
//        pulleyViewController?.setPrimaryContentViewController(controller: primaryContent, animated: false)
    }
}



