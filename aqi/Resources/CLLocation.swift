//
//  CLLocation.swift
//  aqi
//
//  Created by aoi on 9/4/20.
//  Copyright © 2020 kc_cc. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation

class ViewController: UIViewController,CLLocationManagerDelegate {
    var manager:CLLocationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestAlwaysAuthorization()
    }
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        switch status {
        case .restricted,.denied,.notDetermined:
            // report error, do something
            print("error")
        default:
            // location si allowed, start monitoring
            manager.startUpdatingLocation()
        }
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        manager.stopUpdatingLocation()
        // do something with the error
    }
    /*
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let locationObj = locations.last {
            if locationObj.horizontalAccuracy < minAllowedAccuracy {
                manager.stopUpdatingLocation()
                // report location somewhere else
            }
        }
    }*/
}
