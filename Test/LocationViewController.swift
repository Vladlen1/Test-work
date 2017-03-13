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
import MapKit

class LocationViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate  {

    @IBOutlet weak var latitudeField: UITextField!
    @IBOutlet weak var longitudeField: UITextField!
    @IBOutlet weak var locationField: UITextView!
    @IBOutlet weak var mapView: MKMapView!
    
    let locationManager = CLLocationManager()
    
    var longitude: String?
    var cityName: String?
    var latitude: String?
    let regionRadius: CLLocationDistance = 1000

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
            locationManager.requestLocation()
        }

        mapView.delegate = self
        mapView.showsUserLocation = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if longitude != nil && cityName != nil && latitude != nil{
            locationField.text = cityName
            longitudeField.text = longitude
            latitudeField.text = latitude
        }
    }
    
    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate,
                                                                  regionRadius * 2.0, regionRadius * 2.0)
        mapView.setRegion(coordinateRegion, animated: true)
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
            centerMapOnLocation(location: locate)
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
        dateFormatter.dateFormat = "HH:mm:ss dd-MM-yyyy"
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
