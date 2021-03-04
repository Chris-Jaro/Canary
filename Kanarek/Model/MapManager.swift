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
    
    //## - Function is triggered by MainController and performs actions:
        // -> takes provided location and performs reverseGeocoding which results in a city name for the location (in english)
        // -> After receiving the city name MapManager delegate's (here MainController) method loadPoints is called with the city name
    func getCurrentCity(for currentLocation: CLLocation?){
        let geoCoder = CLGeocoder()
        // "preferredLocale:" variable forces the language of the geoCoder results (to English in this case "en")
        if let location = currentLocation{
            geoCoder.reverseGeocodeLocation(location, preferredLocale: Locale.init(identifier: "en"), completionHandler: { (placemarks, _) -> Void in
                if let placemark = placemarks?.first{
                    if let city = placemark.locality {
                        self.delegate!.loadPoints(for: city.lowercased())
                    }
                    
                }
            })
        }
    }
    
    //## - Function is triggered by MainController during preparation for segue and perfroms actions:
        // -> filters the stops list and returns the stops that are within 500m from the user's location (report locaiton)
        // -> if there are no stops the list is passes as an empty list and suitable error message is displayed in ReportOneController
    func filterStopsInTheArea(stops:[Stop]) -> [Stop] {
        var stopsInMyArea = [Stop]()
        if let location = reportLocation{
            for stop in stops{
                let distance = location.distance(from: CLLocation(latitude: stop.location.latitude, longitude: stop.location.longitude))
                if distance < 500 {
                    stopsInMyArea.append(stop)
                }
            }
        }
        return stopsInMyArea
    }
    
    //## - Function is triggered by DatabaseManager (in MainController as its delegate with the updateUI method) and performs action:
        // -> adds a neutral stop to the mapView where it specifies stop's title, subtitle and location (unsing addPoint function)
    func addNeutralStop(for stop:Stop, on map: MKMapView){
        addPoint(where: stop.location, title: stop.stopName, subtitle:"linie: \(stop.lines)\ntyp: \(stop.type)\nstatus_zgłoszenia: \(stop.status)", map: map)
    }
    
    //## - Function is triggered by DatabaseManager (in MainController as its delegate with the updateUI method) and performs action:
        // -> adds a dangerous stop to the mapView where it specifies stop's title, subtitle and location (unsing addPoint function)
        // -> adds circle overlay to the mapView at the location of the dangerous stop
    func addDangerousStop(for stop:Stop, on map: MKMapView){
        addPoint(where: stop.location,
                 title: stop.stopName,
                 subtitle:"!UWAGA!\nstatus_zgłoszenia: \(stop.status)\ntyp: \(stop.type)\nlinie: \(stop.lines)\n\n________ZGŁOSZENIE________\nczas: \(dateConvertter(interval: stop.dateModified))\n nr \(stop.reportDetails)\n____________________________", map: map)
        addCircle(where: stop.location, map: map)
    }
    
    //## - Function is triggered by MainController's locationManager (only once on the first load of the mapView) and tapping the currentLocationButton and performs action:
        // -> resets the mapView region (the visible part of the map) with privided arguments (location and zoom)
    func setUsersLocation(for location: CLLocation, map: MKMapView, zoom: Double = 0.01){
        let center = location.coordinate
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: zoom, longitudeDelta: zoom))
        map.setRegion(region, animated: true)
    }
    
    //## - Function is triggered by DatabaseManager (in MainController as its delegate with the updateUI method) and performs action:
        // -> deletes all the annotation from the map (except for the userLocation annotation) - to avoid stucking stops when refreshing the map
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
    
    //## - Function is triggered by DatabaseManager (in MainController as its delegate with the updateUI method) and performs action:
        // -> cleans the list of monitored regions (dangerous stops)
    func resetMonitoring(for manager: CLLocationManager){
        let regions = manager.monitoredRegions
        regions.forEach { (region) in
            manager.stopMonitoring(for: region)
        }
    }
    
    //## - Function is triggered by DatabaseManager (in MainController as its delegate with the updateUI method) and performs action:
        // -> adds a region to monitoredRegions list of LocationManager
    func monitorRegionAtLocation(center: CLLocationCoordinate2D, identifier: String, for locationManager: CLLocationManager) {
        // Checks if the divice supports Region Monitoring
        guard CLLocationManager.isMonitoringAvailable(for: CLCircularRegion.self) else { return }
        
        // guard locationManager.monitoredRegions.count <= 20 else {return} - only 20 allowed by Apple (IMPLEMENT SOME SORT OF SORTING BASED ON THE DISTANCE TO THE USER?) ----- Highly Unlikely given that there would have to be reports every 6 seconds
        
        let region = CLCircularRegion(center: center,radius: 200, identifier: identifier)
        region.notifyOnEntry = true
        
        locationManager.startMonitoring(for: region)
        
    }
}

//MARK: - Inner Methods
// Methods used only by the methods within MapManager class
extension MapManager {
    //## - Function simplifies the process of adding the point to the mapView
    func addPoint(where location: CLLocationCoordinate2D, title: String, subtitle: String, map: MKMapView){
        let point = MKPointAnnotation()
        point.coordinate = location
        point.title = title
        point.subtitle = subtitle
        map.addAnnotation(point)
    }
    
    //## - Function simplifies the process of adding the circle overlay for dangerous stops
    func addCircle(where location: CLLocationCoordinate2D, map: MKMapView){
        let regionRadius = 200.0
        let circle = MKCircle(center: location, radius: regionRadius)
        map.addOverlay(circle)
    }
    
    //## - Function converts timeIntervalSince2001 to 'HH:mm' which is then displayed in report details on the pop-up
    func dateConvertter(interval:TimeInterval ) -> String {
        let date = Date(timeIntervalSinceReferenceDate: interval)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        
        return dateFormatter.string(from: date)
    }
    
}
