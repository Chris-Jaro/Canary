//
//  MapManager.swift
//  Kanarek
//
//  Created by Chris Yarosh on 22/01/2021.
//

import UIKit
import MapKit

struct MapManager {
    
    var reportLocation: CLLocation?

    //#### - Provides current city name in lowercase -> Not needed now
    
    // RETURNS THE CITY NAME FOR THE PROVIDED LOCATION
    func getCurrentCity(for currentLocation: CLLocation?){
        let geoCoder = CLGeocoder()
        if let location = currentLocation{
            geoCoder.reverseGeocodeLocation(location, completionHandler: { (placemarks, _) -> Void in
                if let placemark = placemarks?.first{
                    if let city = placemark.locality { print(city.lowercased()) }
                }
            })
        }
    }
    
    //#### - Provides a list of stop names in a given area from current location -> To the ReportOneController list of stops
    func loadStopsInTheArea(stops:[Stop]) -> [Stop] {
        var stopsInMyArea:[Stop] = []
        if let location = reportLocation{
            for stop in stops{
                let distance = location.distance(from: CLLocation(latitude: stop.location.latitude, longitude: stop.location.longitude))
                if distance < 1000 {
                    stopsInMyArea.append(stop)
                }
            }
        }
        return stopsInMyArea
    }
    
    //#### - Adds pointAnnotation to the map ->Not needed now
    func addPoint(where location: CLLocationCoordinate2D, title: String, subtitle: String, map: MKMapView){
        let point = MKPointAnnotation()
        point.coordinate = location
        point.title = title
        point.subtitle = subtitle
        map.addAnnotation(point)
    }
    
    //#### - Adds circle danger zone to the map -> Not needed now
    func addCircle(where location: CLLocationCoordinate2D, map: MKMapView){
        let regionRadius = 200.0
        let circle = MKCircle(center: location, radius: regionRadius)
        map.addOverlay(circle)
    }
    
    //#### - Resets current mapView and places the user in its center -> Not needed now
    func setUsersLocation(for location: CLLocation, map: MKMapView){
        let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        map.setRegion(region, animated: true)
    }
    
}





/*
 //#### - Adds pointAnnotation to the map ->Not needed now
 func addPoint(where location: CLLocationCoordinate2D, title: String, subtitle: String){
     let point = MKPointAnnotation()
     point.coordinate = location
     point.title = title
     point.subtitle = subtitle
     mapView.addAnnotation(point)
 }
 
 //#### - Adds circle danger zone to the map -> Not needed now
 func addCircle(where location: CLLocationCoordinate2D){
     let regionRadius = 200.0
     let circle = MKCircle(center: location, radius: regionRadius)
     mapView.addOverlay(circle)
 }
 
 //#### - Resets current mapView and places the user in its center -> Not needed now
 func setUsersLocation(for location: CLLocation){
     let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
     let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
     mapView.setRegion(region, animated: true)
 }
 
 //#### - Provides current city name in lowercase -> Not needed now
 func getCurrentCity(){
     let geoCoder = CLGeocoder()
     if let location = currentLocation{
         geoCoder.reverseGeocodeLocation(location, completionHandler: { (placemarks, _) -> Void in
             if let placemark = placemarks?.first{
                 if let city = placemark.locality { print(city.lowercased()) }
             }
         })
     }
 }
 
 //#### - Provides a list of stop names in a given area from current location -> To the ReportOneController list of stops
 func loadStopsInTheArea(){
     if let location = currentLocation{
         stopsInMyArea = []
         for stop in stops{
             let distance = location.distance(from: CLLocation(latitude: stop.location.latitude, longitude: stop.location.longitude))
             if distance < 1000 {
                 stopsInMyArea.append(stop)
             }
         }
     }
 }
 */
