//
//  ViewController.swift
//  Maps
//
//  Created by Swapnil Kumbhar on 2022-05-24.
//

import UIKit
import CoreLocation
import MapKit

class ViewController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    var locationManager = CLLocationManager();

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        
        locationManager.delegate = self;
        
        locationManager.requestWhenInUseAuthorization();
        
        locationManager.startUpdatingLocation();
        
    }
    
    func displayPointer(
        lat: CLLocationDegrees,
        lng: CLLocationDegrees
    ) {
        let latDelta: CLLocationDegrees = 0.05;
        let lngDelta: CLLocationDegrees = 0.05;
        
        let span = MKCoordinateSpan(latitudeDelta: latDelta, longitudeDelta: lngDelta);
        
        let location = CLLocationCoordinate2D(latitude: lat, longitude: lng)
        
        let region = MKCoordinateRegion(center: location, span: span)
        
        
        mapView.setRegion(region, animated: true)
        addAnnotation(coordinate: location, title: "My Location")
        
    }
    
    func addAnnotation(
        coordinate: CLLocationCoordinate2D,
        title: String
    ) {
        let annotation = MKPointAnnotation();
        annotation.title = title;
        annotation.coordinate = coordinate;
        mapView.addAnnotation(annotation);
    }
}


extension ViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location: CLLocation = locations.last {
            displayPointer(lat: location.coordinate.latitude, lng: location.coordinate.longitude)
        }
    }
    
}
