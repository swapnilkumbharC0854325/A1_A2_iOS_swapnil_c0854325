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
    
    var tappedLocations: [CLLocationCoordinate2D] = [];
    var myLocation: CLLocation? = nil;
    var tappedLocationTitles: [String] = ["A", "B", "C"];
    
    var isPolygonAdded = false;

    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self;
        
        mapView.delegate = self;
    
        mapView.showsUserLocation = true;
        
        if(CLLocationManager.locationServicesEnabled())
        {
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.requestWhenInUseAuthorization();
            locationManager.startUpdatingLocation();
        }
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(triggerTouchAction))
        mapView.addGestureRecognizer(tapGesture)
        
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(triggerTouchAction))
        mapView.addGestureRecognizer(longPressGesture)
    }
    
    
    
    @objc func triggerTouchAction(gestureReconizer: UITapGestureRecognizer) {
        if gestureReconizer.state == .ended {
            if tappedLocations.count < 3 {
                let touchLocation = gestureReconizer.location(in: mapView);
                let coordinateOfTouch = mapView.convert(touchLocation, toCoordinateFrom: mapView);
                
                displayPointer(lat: coordinateOfTouch.latitude, lng: coordinateOfTouch.longitude, title: tappedLocationTitles[tappedLocations.count])
                
                tappedLocations.append(CLLocationCoordinate2D(latitude: coordinateOfTouch.latitude, longitude: coordinateOfTouch.longitude))
            }
            
            if tappedLocations.count == 3 && isPolygonAdded == false {
                let points = tappedLocations.map { point in
                    return CLLocationCoordinate2DMake(point.latitude, point.longitude)
                }
                let overlay = MKPolygon(coordinates: points, count: points.count)
                mapView.addOverlay(overlay)
                isPolygonAdded = true;
            }
            
        }
    }

    func displayPointer(
        lat: CLLocationDegrees,
        lng: CLLocationDegrees,
        title: String
    ) {
        let latDelta: CLLocationDegrees = 0.5;
        let lngDelta: CLLocationDegrees = 0.5;
        
        let span = MKCoordinateSpan(latitudeDelta: latDelta, longitudeDelta: lngDelta);
        
        let location = CLLocationCoordinate2D(latitude: lat, longitude: lng)
        
        let region = MKCoordinateRegion(center: location, span: span)
        
        
        mapView.setRegion(region, animated: true)
        if (title != "My Location") {
            addAnnotation(coordinate: location, title: title)
        }
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
    
    @objc func getDistance(pointer1: CLLocation, pointer2: CLLocation) ->String {
        let distanceInMeters = pointer1.distance(from: pointer2);
        let distanceInKms = distanceInMeters / 1000;
        return String(format: "%.2f", distanceInKms)
    }
}


extension ViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location: CLLocation = locations.last {
            myLocation = CLLocation(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
            displayPointer(lat: location.coordinate.latitude, lng: location.coordinate.longitude, title: "My Location")
        }
    }
    
}

extension ViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is MKPolygon {
            let rendrer = MKPolygonRenderer(overlay: overlay)
            rendrer.lineWidth = 1
            rendrer.fillColor = UIColor.red.withAlphaComponent(0.5)
            rendrer.strokeColor = UIColor.green
            return rendrer
        }
        return MKOverlayRenderer()
    }
    
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        let distanceFromA = getDistance(pointer1: myLocation!, pointer2: CLLocation(latitude: tappedLocations[0].latitude, longitude: tappedLocations[0].longitude))
        let distanceFromB = getDistance(pointer1: myLocation!, pointer2: CLLocation(latitude: tappedLocations[1].latitude, longitude: tappedLocations[1].longitude))
        let distanceFromC = getDistance(pointer1: myLocation!, pointer2: CLLocation(latitude: tappedLocations[2].latitude, longitude: tappedLocations[2].longitude))
        
        let alertController = UIAlertController(title: "Distance", message: "From Point A : \(distanceFromA) KM\n From Point B : \(distanceFromB) KM\n From Point C : \(distanceFromC) KM", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            return nil
        }
        let annotationView = MKPinAnnotationView()
        annotationView.pinTintColor = #colorLiteral(red: 0.7450980544, green: 0.1568627506, blue: 0.07450980693, alpha: 1);
        annotationView.canShowCallout = true
        annotationView.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        return annotationView
    }
}
