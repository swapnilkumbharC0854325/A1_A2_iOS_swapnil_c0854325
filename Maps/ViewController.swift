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
        mapView.isZoomEnabled = true;
    
        mapView.showsUserLocation = false;
        
        if(CLLocationManager.locationServicesEnabled())
        {
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.requestWhenInUseAuthorization();
            locationManager.requestLocation();
        }
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(triggerTouchAction))
        mapView.addGestureRecognizer(tapGesture)
        
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(triggerTouchAction))
        mapView.addGestureRecognizer(longPressGesture)
    }
    
    func naviagtePointOneToPointTwo(sourcePlaceMark: CLLocationCoordinate2D, destinationPlaceMark: CLLocationCoordinate2D) {
        
        let directionRequest = MKDirections.Request()
        
        directionRequest.source = MKMapItem(placemark: MKPlacemark(coordinate: sourcePlaceMark))
        directionRequest.destination = MKMapItem(placemark: MKPlacemark(coordinate: destinationPlaceMark))
        
        directionRequest.transportType = .automobile
        
        let directions = MKDirections(request: directionRequest)
        directions.calculate { (response, error) in
            guard let directionResponse = response else {return}
            let route = directionResponse.routes[0]
            self.mapView.addOverlay(route.polyline, level: .aboveRoads)
            let rect = route.polyline.boundingMapRect
            self.mapView.setVisibleMapRect(rect, edgePadding: UIEdgeInsets(top: 100, left: 100, bottom: 100, right: 100), animated: true)
        }
    }
    
    
    @IBAction func navigate(_ sender: UIButton) {
        if (tappedLocations.count == 3) {
            mapView.removeOverlays(mapView.overlays);
            naviagtePointOneToPointTwo(sourcePlaceMark: tappedLocations[0], destinationPlaceMark: tappedLocations[1])
            naviagtePointOneToPointTwo(sourcePlaceMark: tappedLocations[1], destinationPlaceMark: tappedLocations[2])
            naviagtePointOneToPointTwo(sourcePlaceMark: tappedLocations[2], destinationPlaceMark: tappedLocations[0])
        }
    }
    
    @objc func triggerTouchAction(gestureReconizer: UITapGestureRecognizer) {
        if gestureReconizer.state == .ended {
            if tappedLocations.count < 3 {
                let touchLocation = gestureReconizer.location(in: mapView);
                let coordinateOfTouch = mapView.convert(touchLocation, toCoordinateFrom: mapView);
                
                displayPointer(lat: coordinateOfTouch.latitude, lng: coordinateOfTouch.longitude, title: tappedLocationTitles[tappedLocations.count])
                
                tappedLocations.append(CLLocationCoordinate2D(latitude: coordinateOfTouch.latitude, longitude: coordinateOfTouch.longitude))
                
                let points = tappedLocations.map { point in
                    return CLLocationCoordinate2DMake(point.latitude, point.longitude)
                }
                let overlay = MKPolyline(coordinates: points, count: points.count)
                mapView.addOverlay(overlay)
            }
            
            if tappedLocations.count == 3 && isPolygonAdded == false {
                let points = tappedLocations.map { point in
                    return CLLocationCoordinate2DMake(point.latitude, point.longitude)
                }
                let overlay = MKPolygon(coordinates: points, count: points.count)
                mapView.addOverlay(overlay)
                let lastPoints: [CLLocationCoordinate2D] = [tappedLocations[2], tappedLocations[0]];
                let polylinePoints = lastPoints.map { point in
                    return CLLocationCoordinate2DMake(point.latitude, point.longitude)
                }
                let polylineOverlay = MKPolyline(coordinates: polylinePoints, count: polylinePoints.count)
                mapView.addOverlay(polylineOverlay)
                isPolygonAdded = true;
            }
        }
    }
    
    func setRegion(
        lat: CLLocationDegrees,
        lng: CLLocationDegrees
    ) {
        let latDelta: CLLocationDegrees = 0.5;
        let lngDelta: CLLocationDegrees = 0.5;
        
        let span = MKCoordinateSpan(latitudeDelta: latDelta, longitudeDelta: lngDelta);
        
        let location = CLLocationCoordinate2D(latitude: lat, longitude: lng)
         
        let region = MKCoordinateRegion(center: location, span: span)
        
        
        mapView.setRegion(region, animated: true)
    }

    func displayPointer(
        lat: CLLocationDegrees,
        lng: CLLocationDegrees,
        title: String
    ) {
       
        let location = CLLocationCoordinate2D(latitude: lat, longitude: lng)
        
        addAnnotation(coordinate: location, title: title)
    }
    
    func addAnnotation(
        coordinate: CLLocationCoordinate2D,
        title: String
    ) {
        let annotation = MKPointAnnotation();
        annotation.title = title;
        annotation.subtitle = "Long press to remove"
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
        if let location: CLLocation = locations.first {
            myLocation = CLLocation(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
            displayPointer(lat: location.coordinate.latitude, lng: location.coordinate.longitude, title: "My Location")
            setRegion(lat: location.coordinate.latitude, lng: location.coordinate.longitude);
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error")
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
        if overlay is MKPolyline {
            let rendrer = MKPolylineRenderer(overlay: overlay)
            rendrer.strokeColor = #colorLiteral(red: 0.7450980544, green: 0.1568627506, blue: 0.07450980693, alpha: 1)
            rendrer.lineWidth = 3
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
        let annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: "droppablePin")
        annotationView.markerTintColor = #colorLiteral(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 1)
        annotationView.canShowCallout = true
        annotationView.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        return annotationView
    }
}
