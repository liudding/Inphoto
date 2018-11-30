//
//  MapDrawerViewController.swift
//  Inphoto
//
//  Created by liuding on 2018/11/27.
//  Copyright © 2018 eastree. All rights reserved.
//

import UIKit
import PullUpController
import CoreLocation
import MapKit

class MapPullupViewController: PullUpController {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    fileprivate let searchCompleter = MKLocalSearchCompleter()
    fileprivate var completerResults = [MKLocalSearchCompletion]()
    fileprivate var localSearch: MKLocalSearch? {
        willSet {
            localSearch?.cancel()
        }
    }

    fileprivate var recentAddress: [Address] = []
    
    fileprivate var isSearchMode = false
    
    var initialPointOffset: CGFloat {
        return pullUpControllerPreferredSize.height
    }
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchCompleter.delegate = self
        
        tableView.attach(to: self)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
//        view.layer.cornerRadius = 12
//        view.clipsToBounds = true
    }
    
    
    override func pullUpControllerDidDrag(to point: CGFloat) {
        //        print("did drag to \(point)")
        view.endEditing(true)
    }
    
    // MARK: - PullUpController
    
    override var pullUpControllerPreferredSize: CGSize {
        return CGSize(width: min(UIScreen.main.bounds.width, UIScreen.main.bounds.height),
                      height: 86)
    }
    
    override var pullUpControllerPreferredLandscapeFrame: CGRect {
        return CGRect(x: 10, y: 10, width: 300, height: UIScreen.main.bounds.height - 20)
    }
    
    override var pullUpControllerMiddleStickyPoints: [CGFloat] {
        return [86, UIScreen.main.bounds.height * 1/3, UIScreen.main.bounds.height - 64 - 50]
    }
    
    override var pullUpControllerBounceOffset: CGFloat {
        return 20
    }
    
//    override func pullUpControllerAnimate(action: PullUpController.Action,
//                                          withDuration duration: TimeInterval,
//                                          animations: @escaping () -> Void,
//                                          completion: ((Bool) -> Void)?) {
//        switch action {
//        case .move:
//            UIView.animate(withDuration: 0.3,
//                           delay: 0,
//                           usingSpringWithDamping: 0.7,
//                           initialSpringVelocity: 0,
//                           options: .curveEaseInOut,
//                           animations: animations,
//                           completion: completion)
//        default:
//            UIView.animate(withDuration: 0.3,
//                           animations: animations,
//                           completion: completion)
//        }
//    }
}


extension MapPullupViewController {
    fileprivate func endEditing() {
        view.endEditing(true)
        searchBar.showsCancelButton = false
        pullUpControllerMoveToVisiblePoint(pullUpControllerMiddleStickyPoints[0], animated: true, completion: nil)
        isSearchMode = false
    }
    
    fileprivate func startEditing() {
        pulleyViewController?.setDrawerPosition(position: .open, animated: true)
        
        if let lastStickyPoint = pullUpControllerAllStickyPoints.last {
            pullUpControllerMoveToVisiblePoint(lastStickyPoint, animated: true, completion: nil)
        }
        
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

extension MapPullupViewController: UISearchBarDelegate {
    
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
    }
}

extension MapPullupViewController: UITableViewDataSource, UITableViewDelegate {
    
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
        
        if isSearchMode {
            let suggestion = completerResults[indexPath.row]
            searchBar.text = suggestion.title
            search(for: suggestion) { [weak self] (places) in
                if let coordinate = places?[0].placemark.coordinate {
                    (self?.parent as? LocationController)?.zoom(to: coordinate)
                    self?.endEditing()
                }
            }
        } else {
            let addr = recentAddress[indexPath.row]
            (parent as? LocationController)?.zoom(to: addr.coordinate)
            self.endEditing()
        }
    }
}

extension MapPullupViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        searchCompleter.queryFragment = searchController.searchBar.text ?? ""
    }
}

extension MapPullupViewController: MKLocalSearchCompleterDelegate {
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


