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

class RMAMapVC: UIViewController {
    @IBOutlet weak var showSearch: UIBarButtonItem!
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var addLocationButton: UIButton!
    @IBOutlet weak var radiusSlider: UISlider!
    @IBAction func radiusSlider(_ sender: UISlider) {
    }
    
    var isInAddLocationMode = false
    weak var locationDelegate: SetLocationDelegate?
    lazy var currentPlace = GMSPlace()
    var taskLocation = RMALocation()
    
    var locationManager = CLLocationManager()
    var userLocation = CLLocation()
    var selectedLocation = CLLocation()
    
    var resultsViewController: GMSAutocompleteResultsViewController?
    var searchController: UISearchController?
    var resultView: UITextView?
    var marker = GMSMarker()
    var radiusCircle = GMSCircle()
    let defaultCamera = GMSCameraPosition.camera(withLatitude: 0.0,
                                                 longitude: 0.0,
                                                 zoom: 14.0)
    var shouldAllowPan: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(scaleRadius))
//        panGesture.delegate = self
//        mapView.addGestureRecognizer(panGesture)
        
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
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
            
            radiusCircle.position = userLocation.coordinate
            radiusCircle.radius = 200
            radiusCircle.fillColor = UIColor.Maps.circleFill
            radiusCircle.strokeColor = UIColor.Maps.circleStroke
            radiusCircle.map = mapView
        } else {
            showSearch.tintColor = .clear
        }
        
        resultsViewController = GMSAutocompleteResultsViewController()
        resultsViewController?.delegate = self
        
        searchController = UISearchController(searchResultsController: resultsViewController)
        searchController?.searchResultsUpdater = resultsViewController
        searchController?.hidesNavigationBarDuringPresentation = false
        searchController?.dimsBackgroundDuringPresentation = false
        
        // When UISearchController presents the results view, present it in
        // this view controller, not one further up the chain.
        definesPresentationContext = true
    }
    
    override func viewWillLayoutSubviews() {
        searchController?.searchBar.frame.size.width = view.frame.size.width
        searchController?.searchBar.frame.size.height = 44.0
        
        addLocationButton.isHidden = !isInAddLocationMode
        addLocationButton.frame.size.width = view.frame.size.width/2
        addLocationButton.layer.backgroundColor = UIColor.Maps.addLocationButton.cgColor
        showSearch.isEnabled = isInAddLocationMode
        //radiusSlider.isHidden = true
        //radiusSlider.transform = CGAffineTransformMakeRotation()
    }
    
    func reverseGeocodeCoordinate(_ coordinate: CLLocationCoordinate2D) -> String {
        let geocoder = GMSGeocoder()
        var locationName = ""
        geocoder.reverseGeocodeCoordinate(coordinate) { response, error in
            guard let address = response?.firstResult() else {
                return
            }
            locationName = address.locality!
        }
        return locationName
    }
    
    private func animateCameraTo(coordinate: CLLocationCoordinate2D, zoom: Float = 14.0) {
        let camera = GMSCameraPosition.camera(withTarget: coordinate, zoom: zoom)
        mapView.animate(to: camera)
    }
    
    @objc func scaleRadius(sender: UIPanGestureRecognizer) {
        let panInterval = sender.translation(in: self.mapView)
        var isChangingRadius = false
        var startingPoint = CGPoint()
        switch sender.state {
        case .began:
            startingPoint = sender.location(in: self.mapView)
            isChangingRadius = true
        case .changed:
            print(panInterval)
        case .ended:
            isChangingRadius = false
        case .cancelled, .failed, .possible:
            return
        }
    }
    
    @IBAction func addLocationButton(_ sender: UIButton) {
        let locatioName = reverseGeocodeCoordinate(marker.position)
        if locatioName == "" {
            taskLocation.name = "Loc: \(marker.position.latitude), \(marker.position.longitude)"
        } else {
            taskLocation.name = locatioName
        }
        taskLocation.latitude = marker.position.latitude
        taskLocation.longitude = marker.position.longitude
        taskLocation.radius = radiusCircle.radius
        locationDelegate?.setLocation(location: taskLocation)
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func showSearch(_ sender: UIBarButtonItem) {
        if #available(iOS 11.0, *) {
            navigationItem.searchController = searchController
        } else {
            navigationItem.titleView = searchController?.searchBar
        }
    }
    
}

extension RMAMapVC: GMSAutocompleteViewControllerDelegate, GMSAutocompleteResultsViewControllerDelegate {
    func resultsController(_ resultsController: GMSAutocompleteResultsViewController,
                           didAutocompleteWith place: GMSPlace) {
        searchController?.isActive = false
        animateCameraTo(coordinate: place.coordinate)
        searchController?.searchBar.text = place.formattedAddress ?? "Just text..."
        if #available(iOS 11.0, *) {
            navigationItem.searchController?.dismiss(animated: true, completion: nil)
        } else {
            navigationItem.titleView = nil
        }
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
        radiusCircle.position = coordinate
        radiusCircle.map = mapView
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
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        
    }
    func didDismissSearchController(_ searchController: UISearchController) {
        
    }
}

extension RMAMapVC: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        // (viewController as! ViewController).place = currentPlace
    }
}
