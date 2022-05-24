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
    var tappedLocationTitles: [String] = ["A", "B", "C"];
    
    var isPolygonAdded = false;

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        
        locationManager.delegate = self;
        
        mapView.delegate = self;
        
        if(CLLocationManager.locationServicesEnabled())
        {
            locationManager.requestWhenInUseAuthorization();
            locationManager.startUpdatingLocation();
        }
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(triggerTouchAction))
        mapView.addGestureRecognizer(tapGesture)
    }
    
    
    
    @objc func triggerTouchAction(gestureReconizer: UITapGestureRecognizer) {
          //Add alert to show it works
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
        addAnnotation(coordinate: location, title: title)
        
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
}
