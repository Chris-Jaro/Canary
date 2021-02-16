//
//  MapManager.swift
//  Kanarek
//
//  Created by Chris Yarosh on 22/01/2021.
//

import UIKit
import MapKit

protocol MapManagerDelegate {
    func loadPoints(for cityName: String)
}

class MapManager {
    var delegate: MapManagerDelegate?
    
    var reportLocation: CLLocation?

    //#### - Provides current city name in lowercase -> Not needed now 
    func getCurrentCity(for currentLocation: CLLocation?){
        let geoCoder = CLGeocoder()
        if let location = currentLocation{
            geoCoder.reverseGeocodeLocation(location, completionHandler: { (placemarks, _) -> Void in
                if let placemark = placemarks?.first{
                    if let city = placemark.locality {
                        self.delegate!.loadPoints(for: city.lowercased())
                    }
                    
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
    
    func addNeutralStop(for stop:Stop, on map: MKMapView){
        addPoint(where: stop.location, title: stop.stopName, subtitle:"lines: \(stop.lines)\nType: \(stop.type)\nreport_status: \(stop.status)", map: map)
    }
    
    func addDangerousStop(for stop:Stop, on map: MKMapView){
        addPoint(where: stop.location,
                 title: stop.stopName,
                 subtitle:"report_status: \(stop.status)\nType: \(stop.type)\nlines: \(stop.lines)\n___REPORT___\nTime: \(dateConvertter(interval: stop.dateModified))\ndirection: \(stop.direction)", map: map)
        addCircle(where: stop.location, map: map)
    }
    
    //#### - Resets current mapView and places the user in its center -> Not needed now
    func setUsersLocation(for location: CLLocation, map: MKMapView){
        let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        map.setRegion(region, animated: true)
    }
    
    //#### - Cleans the whole map of all annotations
    func deleteOldPoints(on map:MKMapView){
        var list = map.annotations
        if let userIndex = list.firstIndex(where: { (annotation) -> Bool in
            if type(of: annotation) == MKUserLocation.self {
                return true
            } else {
                return false
            }
        }) {
            list.remove(at: userIndex)
        }
        map.removeAnnotations(list)
        map.removeOverlays(map.overlays)
    }
    
    //#### - Cleans the list of currently monitrored stops
    func resetMonitoring(for manager: CLLocationManager){
        let regions = manager.monitoredRegions
        regions.forEach { (region) in
            manager.stopMonitoring(for: region)
        }
    }
    
    func monitorRegionAtLocation(center: CLLocationCoordinate2D, identifier: String, for locationManager: CLLocationManager) {
        // MAKE SURE THE DIVICE SUPPORTS REGION MONITORING
        guard locationManager.monitoredRegions.count <= 20 else { return } // only 20 allowed by Apple IMPLEMENT SOME SORT OF SORTING BASED ON THE DISTANCE TO THE USER?
        
        if CLLocationManager.isMonitoringAvailable(for: CLCircularRegion.self) {
            let region = CLCircularRegion(center: center,radius: 200, identifier: identifier)
            region.notifyOnEntry = true
            region.notifyOnExit = true
       
            locationManager.startMonitoring(for: region)
        }
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
    
    //#### Function converts timeIntervalSince2001 to 'HH:mm'
    func dateConvertter(interval:TimeInterval ) -> String {
        let date = Date(timeIntervalSinceReferenceDate: interval)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        
        return dateFormatter.string(from: date)
    }
    
}
