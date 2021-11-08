//
//  MapViewController.swift
//  WINFOX
//
//  Created by  Admin on 05.11.2021.
//

import UIKit
import MapKit

class MapViewController: UIViewController, UICollectionViewDelegateFlowLayout {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var logotButton: UIButton!
    let locationManager = CLLocationManager()
    var places: [PlacesStruct] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        backgroundSetting()
        getPlaces()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        checkLocationEnabled()
    }
    
    private func checkLocationEnabled() {
        if CLLocationManager.locationServicesEnabled() {
            setupManager()
            checkAuthorization()
        } else {
            showAlertLocation(title: "Geolocation service is disabled", message: "Do you want to enable?", url: URL(string: "App-Prefs:root=LOCATION_SERVICES"))
        }
    }
    
    private func setupManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    private func checkAuthorization() {
        switch CLLocationManager.authorizationStatus() {
        case .authorizedAlways:
            break
        case .authorizedWhenInUse:
            mapView.showsUserLocation = true
            locationManager.startUpdatingLocation()
            RequestManager.shared.sendCoords(latitude: locationManager.location?.coordinate.latitude, longitude: locationManager.location?.coordinate.longitude) { success in
                guard success else { return }
                print("Coordinate send to server success")
            }
            break
        case .denied:
            showAlertLocation(title: "You have banned the use of the location.", message: "Do you want to change it?", url: URL(string: UIApplication.openSettingsURLString ))
            break
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted:
            break
        @unknown default:
            break
        }
    }
    
    private func showAlertLocation(title: String, message: String, url: URL?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let settingsAction = UIAlertAction(title: "Settings", style: .default) { alert in
            if let url = url {
                UIApplication.shared.open(url, options: [:], completionHandler: nil )
            }
        }
        let cancelAction =  UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(settingsAction)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func tapLogout(_ sender: UIButton) {
        AuthManager.shared.logout()
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        let vc = storyboard.instantiateViewController(withIdentifier: "LoginController") as! LoginController
        navigationController?.pushViewController(vc, animated: true)
    }
    
    private func backgroundSetting() {
        logotButton.layer.cornerRadius = 6
    }
    
    private func getPlaces() {
        RequestManager.shared.getPlace { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let places):
                    self?.places = places
                    self?.putAnnotation()
                case .failure:
                    self?.places = []
                    self?.showError()
                }
            }
        }
    }
    
    func putAnnotation()
    {
        if places.count != 0 {
            for place in places
            {
                let annotation = MKPointAnnotation()
                annotation.title = place.name
                annotation.accessibilityElementsHidden = true
                annotation.coordinate = CLLocationCoordinate2D(latitude: place.latitide, longitude: place.longitude)
                mapView.addAnnotation(annotation)
            }
        }
    }
    
    private func showError() {
        let alert = UIAlertController(title: "Error", message: "Something went wrong. Try again later.", preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
}

extension MapViewController:  CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last?.coordinate {
            let region = MKCoordinateRegion(center: location, latitudinalMeters: 1000, longitudinalMeters: 1000)
            mapView.setRegion(region, animated: true)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        checkAuthorization()
    }
}

extension MapViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        print("did select")
        print(view)
        print(view.annotation?.title)
        print(view.annotation?.coordinate)
        let place = places.filter{ $0.name == view.annotation?.title}
        if place.count != 0 {
            let collectionView = MenuCollectionViewController(collectionViewLayout: UICollectionViewFlowLayout())
            collectionView.place = place
            let tap = UITapGestureRecognizer(target: self, action: #selector(removeCollectionView))
            self.view.addGestureRecognizer(tap)
            self.addChild(collectionView)
            self.view.addSubview(collectionView.view)
//        self.didMove(toParent: collectionView)
        }
    }
    
    @objc func removeCollectionView() {
        if self.view.subviews.count > 2 {
        self.view.subviews.last?.removeFromSuperview()
        }
    }
    
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
    }
}
