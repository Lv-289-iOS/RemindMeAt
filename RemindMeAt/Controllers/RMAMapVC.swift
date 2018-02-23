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
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var addLocationButton: UIButton!
    @IBOutlet weak var radiusPicker: UIPickerView!
    @IBOutlet weak var currentRadius: UILabel!
    @IBOutlet weak var loadNameIndicator: UIActivityIndicatorView!
    @IBOutlet weak var enterOrLeaveStack: UIStackView!
    @IBOutlet weak var radiusStack: UIStackView!
    @IBOutlet weak var checkSwitch: UISwitch!
    @IBOutlet weak var notifyLabel: UILabel!
    @IBOutlet weak var leftBarView: UIView!
    
    let radiusValues: [Double] = [50, 100, 250, 500]
    let defaultRadius: Double = 250
    var isInAddLocationMode = false
    var task: RMATask?
    weak var locationDelegate: SetLocationDelegate?
    var taskLocation = RMALocation()
    var taskForMarker = [GMSMarker: RMATask]()
    var imageLoader = RMAFileManager()
    var isOnEnter = true
    
    var locationManager = CLLocationManager()
    var userLocation = CLLocation()
    
    lazy var geocoder = GMSGeocoder()
    var resultsViewController: GMSAutocompleteResultsViewController?
    var searchController: UISearchController?
    var marker = GMSMarker()
    var radiusCircle = GMSCircle()
    let defaultCamera = GMSCameraPosition.camera(withLatitude: 49.8383,
                                                 longitude: 24.0232,
                                                 zoom: 13.0)
    var isAddLocationTapped = false
    var isGeocodeCompleted = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        radiusPicker.dataSource = self
        radiusPicker.delegate = self
        
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 50
        locationManager.startUpdatingLocation()
        
        mapView.delegate = self
        //mapView.camera = defaultCamera
        mapView.isMyLocationEnabled = true
        mapView.settings.myLocationButton = true
        mapView.settings.compassButton = true
        
        if let loc = locationManager.location {
            userLocation = loc
            animateCameraTo(coordinate: userLocation.coordinate)
        }
        resultsViewController = GMSAutocompleteResultsViewController()
        resultsViewController?.delegate = self
        
        searchController = UISearchController(searchResultsController: resultsViewController)
        searchController?.searchResultsUpdater = resultsViewController
        searchController?.hidesNavigationBarDuringPresentation = false
        searchController?.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        
        startupSetup()
    }
    
    func startupSetup() {
        navigationItem.searchController = searchController
        
        leftBarView.layer.opacity = 0.5
        let maskPath = UIBezierPath.init(roundedRect: self.leftBarView.bounds, byRoundingCorners:[.topRight, .bottomRight], cornerRadii: CGSize.init(width: 10.0, height: 10.0))
        let maskLayer = CAShapeLayer()
        maskLayer.frame = self.leftBarView.bounds
        maskLayer.path = maskPath.cgPath
        self.leftBarView.layer.mask = maskLayer
        
        radiusPicker.selectRow(radiusValues.index(of: defaultRadius)!, inComponent: 0, animated: false)
        currentRadius.text = "Radius:\n\(Int(defaultRadius))m"
        searchController?.searchBar.placeholder = "Search for location..."
        addLocationButton.isHidden = !isInAddLocationMode
        addLocationButton.layer.backgroundColor = UIColor.Maps.addLocationButton.cgColor
        
        enterOrLeaveStack.isHidden = !isInAddLocationMode
        radiusStack.isHidden = !isInAddLocationMode
        loadNameIndicator.isHidden = true
        leftBarView.isHidden = !isInAddLocationMode
    }
    
    override func viewWillLayoutSubviews() {
        searchController?.searchBar.frame.size.width = view.frame.size.width
        searchController?.searchBar.frame.size.height = 44.0
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if isInAddLocationMode {
            marker.position = userLocation.coordinate
            marker.map = mapView
            
            radiusCircle.position = userLocation.coordinate
            radiusCircle.radius = radiusValues[radiusPicker.selectedRow(inComponent: 0)]
            radiusCircle.fillColor = UIColor.Maps.circleFill
            radiusCircle.strokeColor = UIColor.Maps.circleStroke
            radiusCircle.map = mapView
        } else {
            let tasksWithLocations = RMARealmManager.getTasksWithLocation()
            
            for task in tasksWithLocations {
                let markerForLocation = GMSMarker()
                markerForLocation.position = CLLocationCoordinate2D(latitude: (task.location?.latitude)!, longitude: (task.location?.longitude)!)
                markerForLocation.title = task.name
                markerForLocation.map = mapView
                taskForMarker[markerForLocation] = task
                
                let radiusForLocation = GMSCircle()
                radiusForLocation.position = CLLocationCoordinate2D(latitude: (task.location?.latitude)!, longitude: (task.location?.longitude)!)
                radiusForLocation.radius = (task.location?.radius)!
                radiusForLocation.fillColor = UIColor.Maps.circleFill
                radiusForLocation.strokeColor = UIColor.Maps.circleStroke
                radiusForLocation.map = mapView
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "SegueToTask" {
            let holder = segue.destination as! RMANewTaskViewController
            holder.taskToBeUpdated = task
        }
    }
    
    private func animateCameraTo(coordinate: CLLocationCoordinate2D, zoom: Float = 14.0) {
        let camera = GMSCameraPosition.camera(withTarget: coordinate, zoom: zoom)
        mapView.animate(to: camera)
    }
    
    private func completeAddingLocation() {
        locationDelegate?.setLocation(location: taskLocation)
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func addLocationButton(_ sender: UIButton) {
        loadNameIndicator.isHidden = false
        loadNameIndicator.startAnimating()
        
        geocoder.reverseGeocodeCoordinate(marker.position) { (response, error) in
            guard error == nil else {
                return
            }
            
            if let result = response?.firstResult()?.lines?.first {
                if result != "" {
                    self.taskLocation.name = result
                } else {
                    self.taskLocation.name = "\(self.taskLocation.latitude), \(self.taskLocation.longitude)"
                }
                self.isGeocodeCompleted = true
                if self.isAddLocationTapped {
                    self.loadNameIndicator.stopAnimating()
                    self.completeAddingLocation()
                }
            }
        }
        taskLocation.whenEnter = isOnEnter
        taskLocation.latitude = marker.position.latitude
        taskLocation.longitude = marker.position.longitude
        taskLocation.radius = radiusCircle.radius
        isAddLocationTapped = true
        if isGeocodeCompleted {
            loadNameIndicator.stopAnimating()
            completeAddingLocation()
        }
    }
    
    @IBAction func checkSwitch(_ sender: UISwitch) {
        isOnEnter = !isOnEnter
        if isOnEnter {
            notifyLabel.text = "Entering mode"
        } else {
            notifyLabel.text = "Leaving mode"
        }
    }
}

extension RMAMapVC: GMSAutocompleteViewControllerDelegate, GMSAutocompleteResultsViewControllerDelegate {
    func resultsController(_ resultsController: GMSAutocompleteResultsViewController,
                           didAutocompleteWith place: GMSPlace) {
        searchController?.isActive = false
        animateCameraTo(coordinate: place.coordinate)
        searchController?.searchBar.text = place.formattedAddress ?? "Search..."
        navigationItem.searchController?.dismiss(animated: true, completion: nil)
    }
    
    func resultsController(_ resultsController: GMSAutocompleteResultsViewController,
                           didFailAutocompleteWithError error: Error) {
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

extension RMAMapVC: GMSMapViewDelegate {
    
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        marker.position = coordinate
        radiusCircle.position = coordinate
        radiusCircle.map = mapView
    }
    
    func didTapMyLocationButton(for mapView: GMSMapView) -> Bool {
        animateCameraTo(coordinate: userLocation.coordinate)
        return true
    }
    
    func mapView(_ mapView: GMSMapView, markerInfoWindow marker: GMSMarker) -> UIView? {
        
        let view = UIView(frame: CGRect.init(x: 0, y: 0, width: 200, height: 160))
        view.backgroundColor = UIColor.white
        view.layer.cornerRadius = 15
        
        let pictureInInfoWindow = UIImageView(frame: CGRect(x: 50, y: 10, width: 100, height: 100))
        if let task = taskForMarker[marker] {
            if let imageURL = task.imageURL {
                pictureInInfoWindow.image = imageLoader.loadImageFromPath(imageURL: imageURL)
            } else {
                pictureInInfoWindow.image = #imageLiteral(resourceName: "logo")
            }
        } else {
            pictureInInfoWindow.image = #imageLiteral(resourceName: "logo")
        }
        
        pictureInInfoWindow.contentMode = UIViewContentMode.scaleAspectFit
        
        let label = UILabel(frame: CGRect.init(x: 10, y: 120, width: 180, height: 20))
        label.text = marker.title
        label.font = UIFont.systemFont(ofSize: 12, weight: .light)
        label.textAlignment = .center
        
        view.addSubview(pictureInInfoWindow)
        view.addSubview(label)
        return view
    }
    
    func mapView(_ mapView: GMSMapView, didTapInfoWindowOf marker: GMSMarker) {
        task = taskForMarker[marker]
        performSegue(withIdentifier: "SegueToTask", sender: self)
    }
    
}

extension RMAMapVC: UISearchBarDelegate, UISearchControllerDelegate {
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        let autocompleteController = GMSAutocompleteViewController()
        autocompleteController.delegate = self
        present(autocompleteController, animated: true, completion: nil)
    }
}

extension RMAMapVC: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return radiusValues.count
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        radiusCircle.radius = radiusValues[row]
        currentRadius.text = "Radius:\n\(Int(radiusValues[row]))m"
        mapView.reloadInputViews()
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return String(Int(radiusValues[row]))
    }
}

