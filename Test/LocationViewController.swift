//
//  LocationViewController.swift
//  Test
//
//  Created by Влад Бирюков on 03.03.17.
//  Copyright © 2017 Влад Бирюков. All rights reserved.
//
import UIKit
import CoreLocation
import RealmSwift

class LocationViewController: UIViewController, CLLocationManagerDelegate  {

    @IBOutlet weak var latitudeField: UITextField!
    @IBOutlet weak var longitudeField: UITextField!
    @IBOutlet weak var locationField: UITextView!
    
    let locationManager = CLLocationManager()
    
    var longitude: String?
    var cityName: String?
    var latitude: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
            locationManager.requestLocation()
        }

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if longitude != nil && cityName != nil && latitude != nil{
            locationField.text = cityName
            longitudeField.text = longitude
            latitudeField.text = latitude
        }
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        CLGeocoder().reverseGeocodeLocation(manager.location!, completionHandler: {(placemarks, error)->Void in
            if let placemarks = placemarks {
                let placemark = placemarks[0]
                self.locationField.text = self.formatAddressFromPlacemark(placemark: placemark)

            }
            self.parseLocation(locations: locations)
        })
    }
    
    func formatAddressFromPlacemark(placemark: CLPlacemark) -> String {
        return (placemark.addressDictionary!["FormattedAddressLines"] as!
            [String]).joined(separator: ", ")
    }
    
    func parseLocation(locations: [CLLocation]) {
        for locate in locations{
            latitudeField.text = String(format: "%f", locate.coordinate.latitude)
            longitudeField.text = String(format: "%f", locate.coordinate.longitude)
            self.addNewLocation(date: locate.timestamp)

        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error while updating location " + error.localizedDescription)
    }
    
    func addNewLocation(date: Date){
        var cityName = self.locationField.text!.components(separatedBy: ",")
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let DateInFormat = dateFormatter.string(from: date)
        let realm = try! Realm()
        try! realm.write {
            let newlocation = Location()
            newlocation.city = cityName[1]
            newlocation.longitude = self.longitudeField.text!
            newlocation.latitude = self.latitudeField.text!
            newlocation.date = DateInFormat
            realm.add(newlocation)
        }
    }

}
