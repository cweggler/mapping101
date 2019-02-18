//
//  ViewController.swift
//  Mapping101
//
//  Created by Cara on 2/12/19.
//  Copyright © 2019 Cara. All rights reserved.
//

import UIKit
import MapKit

class ViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var locationText: UILabel!
    
    let locationManager = CLLocationManager()
    let geoCoder = CLGeocoder()
    
    
    let dateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateStyle = .short
        df.timeStyle = .short
        return df
    }()
    
    @IBAction func addCurrentLocationMarker(_ sender: Any) {
        if let location = locationManager.location {
            
            let closeAnnotations = mapView.annotations
                .map({ CLLocation(latitude: $0.coordinate.latitude, longitude: $0.coordinate.longitude) })
                .filter({$0.distance(from: location) < 30 }) // filter out all further than 30 meters
            
            if closeAnnotations.count > 1{ //user's location is too close to another annotation so ignore
                print("Other locations are too close. Not adding")
                return
            }
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = location.coordinate
            let timeStamp = dateFormatter.string(from: Date())
            annotation.title = "You were here at \(timeStamp)"
            mapView.addAnnotation(annotation)
            
            geoCoder.reverseGeocodeLocation(location, completionHandler: {(placeMarks: [CLPlacemark]?, error: Error?) in if error == nil {
                    let placeMark = placeMarks![0]
                self.reverseGeoCodeComplete(location: placeMark)
                }
            })
        }
    }
    

    
    func reverseGeoCodeComplete(location: CLPlacemark){
        var locationString: String = ""
        if location.subThoroughfare != nil {
           locationString = "\(location.subThoroughfare!)"
        }
        if location.thoroughfare != nil {
            locationString.append(" \(location.thoroughfare!)")
        }
        if location.locality != nil {
            locationString.append(" \(location.locality!),")
        }
        if location.administrativeArea != nil {
            locationString.append(" \(location.administrativeArea!)")
        }
        if location.country != nil {
            locationString.append(" \(location.country!)")
        }
        print(locationString)
        self.locationText.text = locationString
    }
        override func viewDidLoad() {
            super.viewDidLoad()
            locationManager.delegate = self
            locationManager.requestWhenInUseAuthorization()
            mapView.delegate = self
        
        }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus){
        if status == .authorizedWhenInUse {
            mapView.showsUserLocation = true
            moveToCurrentLocation()
        } else {
            let alert = UIAlertController(title: "Can't display location", message: "Please grant permission in settings", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK",
                                          style: .default,
                                          handler: { (action: UIAlertAction) -> Void in UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!) } ))
            present(alert, animated: true, completion: nil)
        }
    }
    
    func moveToCurrentLocation(){
        if let location = locationManager.location {
            mapView.setCenter(location.coordinate, animated: true)
        }
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKPointAnnotation {
            let pinAnnotation = MKPinAnnotationView()
            pinAnnotation.pinTintColor = UIColor.green
            pinAnnotation.annotation = annotation
            pinAnnotation.canShowCallout = true
            return pinAnnotation
        }
        return nil // use default view, so user location beacon isn't modified
    }

  
    
    
}


