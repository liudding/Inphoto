//
//  MapDrawerViewController.swift
//  Inphoto
//
//  Created by liuding on 2018/11/30.
//  Copyright © 2018 eastree. All rights reserved.
//

import UIKit
import Pulley
import MapKit

class MapDrawerViewController: UIViewController {
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet var searchBar: UISearchBar!
    
    @IBOutlet var topSeparatorView: UIView!
    @IBOutlet var bottomSeperatorView: UIView!
    
    @IBOutlet var gripperTopConstraint: NSLayoutConstraint!
    // We adjust our 'header' based on the bottom safe area using this constraint
    @IBOutlet var headerSectionHeightConstraint: NSLayoutConstraint!
    
    fileprivate var drawerBottomSafeArea: CGFloat = 0.0 {
        didSet {
            self.loadViewIfNeeded()
            
            // We'll configure our UI to respect the safe area. In our small demo app, we just want to adjust the contentInset for the tableview.
            tableView.contentInset = UIEdgeInsets(top: 0.0, left: 0.0, bottom: drawerBottomSafeArea, right: 0.0)
        }
    }
    
    fileprivate let searchCompleter = MKLocalSearchCompleter()
    fileprivate var completerResults = [MKLocalSearchCompletion]()
    fileprivate var localSearch: MKLocalSearch? {
        willSet {
            localSearch?.cancel()
        }
    }
    
    fileprivate var recentAddress: [Address] = []
    
    fileprivate var isSearchMode = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchCompleter.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // The bounce here is optional, but it's done automatically after appearance as a demonstration.
        Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(bounceDrawer), userInfo: nil, repeats: false)
    }
    
    @objc fileprivate func bounceDrawer() {
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
        drawerBottomSafeArea = bottomSafeArea
        
        /*
         Some explanation for what is happening here:
         1. Our drawer UI needs some customization to look 'correct' on devices like the iPhone X, with a bottom safe area inset.
         2. We only need this when it's in the 'collapsed' position, so we'll add some safe area when it's collapsed and remove it when it's not.
         3. These changes are captured in an animation block (when necessary) by Pulley, so these changes will be animated along-side the drawer automatically.
         */
        if drawer.drawerPosition == .collapsed
        {
            headerSectionHeightConstraint.constant = 68.0 + drawerBottomSafeArea
        }
        else
        {
            headerSectionHeightConstraint.constant = 68.0
        }
        
        // Handle tableview scrolling / searchbar editing
        
        tableView.isScrollEnabled = drawer.drawerPosition == .open || drawer.currentDisplayMode == .panel
        
        if drawer.drawerPosition != .open
        {
            searchBar.resignFirstResponder()
        }
        
        if drawer.currentDisplayMode == .panel
        {
            topSeparatorView.isHidden = drawer.drawerPosition == .collapsed
            bottomSeperatorView.isHidden = drawer.drawerPosition == .collapsed
        }
        else
        {
            topSeparatorView.isHidden = false
            bottomSeperatorView.isHidden = true
        }
    }
    
    /// This function is called when the current drawer display mode changes. Make UI customizations here.
    func drawerDisplayModeDidChange(drawer: PulleyViewController) {
        gripperTopConstraint.isActive = drawer.currentDisplayMode == .drawer
    }
}


extension MapDrawerViewController {
    fileprivate func endEditing() {
        view.endEditing(true)
        searchBar.showsCancelButton = false
        pulleyViewController?.setDrawerPosition(position: .collapsed, animated: true)
        
    }
    
    fileprivate func startEditing() {
        pulleyViewController?.setDrawerPosition(position: .open, animated: true)
        
        searchBar.showsCancelButton = true
        isSearchMode = true
    }
    
    fileprivate func createHighlightedString(text: String, rangeValues: [NSValue]) -> NSAttributedString {
        let attributes = [NSAttributedString.Key.backgroundColor: UIColor(named: "suggestionHighlight")! ]
        let highlightedString = NSMutableAttributedString(string: text)
        
        let ranges = rangeValues.map { $0.rangeValue }
        ranges.forEach { (range) in
            highlightedString.addAttributes(attributes, range: range)
        }
        
        return highlightedString
    }
    
    
    fileprivate func search(for suggestedCompletion: MKLocalSearchCompletion, completionHandler: @escaping ([MKMapItem]?) -> Void) {
        let searchRequest = MKLocalSearch.Request(completion: suggestedCompletion)
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        localSearch = MKLocalSearch(request: searchRequest)
        localSearch?.start { [weak self] (response, error) in
            guard error == nil else {
                self?.displaySearchError(error)
                return
            }
            
            completionHandler(response?.mapItems)
            
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
        }
    }
    
    private func displaySearchError(_ error: Error?) {
        if let error = error as NSError?, let errorString = error.userInfo[NSLocalizedDescriptionKey] as? String {
            let alertController = UIAlertController(title: "未找到相关地点", message: errorString, preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "我知道了", style: .default, handler: nil))
            present(alertController, animated: true, completion: nil)
        }
    }
}

extension MapDrawerViewController: UISearchBarDelegate {
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        startEditing()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchCompleter.queryFragment = searchText
    }
    
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        view.endEditing(true)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        endEditing()
        self.isSearchMode = false
    }
}

extension MapDrawerViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isSearchMode {
            return completerResults.count
        }
        return recentAddress.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AddressCell", for: indexPath)
        
        if isSearchMode {
            let suggestion = completerResults[indexPath.row]
            cell.textLabel?.attributedText = createHighlightedString(text: suggestion.title, rangeValues: suggestion.titleHighlightRanges)
            cell.detailTextLabel?.attributedText = createHighlightedString(text: suggestion.subtitle, rangeValues: suggestion.subtitleHighlightRanges)
        } else {
            let address = recentAddress[indexPath.row]
            cell.textLabel?.text = address.name
            cell.detailTextLabel?.text = address.address
        }
        
        return cell
    }

    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 81.0
    }

    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let primaryVC = pulleyViewController?.primaryContentViewController as! MapPrimaryViewController
        
        if isSearchMode {
            let suggestion = completerResults[indexPath.row]
            searchBar.text = suggestion.title
            search(for: suggestion) { [weak self] (places) in
                if let coordinate = places?[0].placemark.coordinate {
                    primaryVC.didSelect(coordinate: coordinate, changeSpan: true)
                    self?.endEditing()
                }
            }
        } else {
            let addr = recentAddress[indexPath.row]
            primaryVC.didSelect(coordinate: addr.coordinate, changeSpan: true)
            self.endEditing()
        }
        
        pulleyViewController?.setDrawerPosition(position: .collapsed, animated: true)
    }
}

extension MapDrawerViewController: MKLocalSearchCompleterDelegate {
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        completerResults = completer.results
        tableView.reloadData()
    }
    
    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        if let error = error as NSError? {
            print("MKLocalSearchCompleter encountered an error: \(error.localizedDescription)")
        }
    }
}

