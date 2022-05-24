//
//  ViewController.swift
//  Maps
//
//  Created by Swapnil Kumbhar on 2022-05-24.
//

import UIKit
import CoreLocation

class ViewController: UIViewController {
    
    var locationManager = CLLocationManager();

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        
        locationManager.delegate = self;
        
        locationManager.requestWhenInUseAuthorization();
        
        
    }


}


extension ViewController: CLLocationManagerDelegate {
    
}
