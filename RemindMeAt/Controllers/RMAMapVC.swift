//
//  RMAMapVC.swift
//  RemindMeAt
//
//  Created by Yurii Tsymbala on 2/7/18.
//  Copyright © 2018 SoftServe Academy. All rights reserved.
//

import UIKit
import GooglePlaces
import GoogleMaps
import CoreLocation

struct TaskLocation {
    var name = ""
    var coordinates = CLLocationCoordinate2D()
    var radius: CLLocationDegrees?
}

class RMAMapVC: UIViewController {
    @IBAction func showSearch(_ sender: UIBarButtonItem) {
    }
    @IBOutlet weak var showSearch: UIBarButtonItem!
    
    @IBOutlet weak var mapView: GMSMapView!
    
    @IBOutlet weak var searchBarView: UIView!
    
    @IBOutlet weak var addLocationButton: UIButton!
    
    @IBAction func addLocationButton(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    var isInAddLocationMode = false
    
    weak var locationDelegate: SetLocationDelegate?
    lazy var currentPlace = GMSPlace()
    var taskLocation = TaskLocation()
    
    var locationManager = CLLocationManager()
    var userLocation = CLLocation()
    var selectedLocation = CLLocation()
    
    var resultsViewController: GMSAutocompleteResultsViewController?
    var searchController: UISearchController?
    var resultView: UITextView?
    var marker = GMSMarker()
    let defaultCamera = GMSCameraPosition.camera(withLatitude: 0.0,
                                                 longitude: 0.0,
                                                 zoom: 14.0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.distanceFilter = 50
        locationManager.startUpdatingLocation()
        locationManager.delegate = self
        mapView.delegate = self
        mapView.camera = defaultCamera
        mapView.isMyLocationEnabled = true
        mapView.settings.myLocationButton = true
        mapView.settings.compassButton = true
        
        if let loc = locationManager.location {
            userLocation = loc
            animateCameraTo(coordinate: userLocation.coordinate)
        }
        
        if isInAddLocationMode {
            marker.position = userLocation.coordinate
            marker.map = mapView
            showSearch.tintColor = .gray
        } else {
            showSearch.tintColor = .clear
        }
        
        resultsViewController = GMSAutocompleteResultsViewController()
        resultsViewController?.delegate = self
        
        searchController = UISearchController(searchResultsController: resultsViewController)
        searchController?.searchResultsUpdater = resultsViewController
        searchBarView.addSubview((searchController?.searchBar)!)
        searchController?.hidesNavigationBarDuringPresentation = false
        
        // When UISearchController presents the results view, present it in
        // this view controller, not one further up the chain.
        definesPresentationContext = true
    }
    
    override func viewWillLayoutSubviews() {
        searchController?.searchBar.frame.size.width = view.frame.size.width
        searchController?.searchBar.frame.size.height = 44.0
        
        addLocationButton.isHidden = !isInAddLocationMode
        showSearch.isEnabled = isInAddLocationMode
        searchBarView.isHidden = true
    }
    
    private func reverseGeocodeCoordinate(_ coordinate: CLLocationCoordinate2D) {
        let geocoder = GMSGeocoder()
        geocoder.reverseGeocodeCoordinate(coordinate) { response, error in
            guard let address = response?.firstResult(), let name = address.lines?.first else {
                return
            }
            self.taskLocation.name = name
        }
    }
    private func animateCameraTo(coordinate: CLLocationCoordinate2D, zoom: Float = 14.0) {
        let camera = GMSCameraPosition.camera(withTarget: coordinate, zoom: zoom)
        mapView.animate(to: camera)
    }
}

extension RMAMapVC: GMSAutocompleteViewControllerDelegate, GMSAutocompleteResultsViewControllerDelegate {
    func resultsController(_ resultsController: GMSAutocompleteResultsViewController,
                           didAutocompleteWith place: GMSPlace) {
        searchController?.isActive = false
        animateCameraTo(coordinate: place.coordinate)
        searchController?.searchBar.text = place.formattedAddress ?? "Just text..."
    }
    
    
    func resultsController(_ resultsController: GMSAutocompleteResultsViewController,
                           didFailAutocompleteWithError error: Error){
        // TODO: handle the error.
        print("Error: ", error.localizedDescription)
    }
    
    // Turn the network activity indicator on and off again.
    func didRequestAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    func didUpdateAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        print("Error: ", error.localizedDescription)
    }
    
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        print("Canceling")
    }
}

extension RMAMapVC: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        
    }
    
}

extension RMAMapVC: GMSMapViewDelegate {
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        marker.position = coordinate
        reverseGeocodeCoordinate(coordinate)
        taskLocation.coordinates = coordinate
    }
    func mapViewDidFinishTileRendering(_ mapView: GMSMapView) {
    }
    func didTapMyLocationButton(for mapView: GMSMapView) -> Bool {
        animateCameraTo(coordinate: userLocation.coordinate)
        return true
    }
}

extension RMAMapVC: UISearchBarDelegate, UISearchControllerDelegate {
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        let autocompleteController = GMSAutocompleteViewController()
        autocompleteController.delegate = self
        present(autocompleteController, animated: true, completion: nil)
    }
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        
    }
    
    func didPresentSearchController(_ searchController: UISearchController) {
        
    }
}

extension RMAMapVC: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        // (viewController as! ViewController).place = currentPlace
    }
}


