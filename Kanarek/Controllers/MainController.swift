//
//  ViewController.swift
//  Kanarek
//
//  Created by Chris Yarosh on 22/11/2020.
//

import UIKit
import CoreLocation
import MapKit
import Firebase

class MainController: UIViewController {
    
    var startLocationLoaded = false
    var hiddenLocationButton = true
    
    let locationManager = CLLocationManager()
    var mapManager = MapManager()
    
    let db = Firestore.firestore()
    
    var timer: Timer?
    var currentLocation: CLLocation?
    
    var stops: [Stop] = [] // Getter from database manager
    var dangerousStops: [Stop] = []
    
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var currentLocationButton: UIButton!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = true
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.isNavigationBarHidden = false
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.layer.cornerRadius = 10
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
        locationManager.allowsBackgroundLocationUpdates = true // This line is respinsible for background location updates
        
        mapView.isZoomEnabled = true
        mapView.showsUserLocation = true
        mapView.delegate = self
        mapView.setUserTrackingMode(.follow, animated: true)
        
        timer = Timer.scheduledTimer(timeInterval: 60, target: self, selector: #selector(renewStopStatus), userInfo: nil, repeats: true)
        
        mapManager.delegate = self
        
    }
    

    @IBAction func currentLocationButtonPressed(_ sender: UIButton) {
        if let location = currentLocation{
            mapManager.setUsersLocation(for: location, map: mapView)
            hiddenLocationButton = true
        }
    }
    
    @IBAction func reportButtonPressed(_ sender: UIButton) {
        if let location = currentLocation{
            mapManager.reportLocation = location
        }
        performSegue(withIdentifier: "GoToReportOne", sender: self)
    }
    
    
    
    //##### Prepares for segue (any action needed to be taken before going to the other screen)
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "GoToReportOne"{
            let destinationVC = segue.destination as! ReportControllerOne
            if let location = currentLocation{
                destinationVC.reportCoortdinates = "\(location.coordinate.latitude),\(location.coordinate.longitude)"
                destinationVC.stops = mapManager.loadStopsInTheArea(stops: stops)
            }
        }
    }
    
//MARK: - Database-related Functions
    //#### Loads list of stops from the database and listens for the changes -> Not needed now
    func loadPoints(){
        db.collection(K.FirebaseQuery.stopsCollectionName)
            .order(by: K.FirebaseQuery.date)
            .addSnapshotListener { (querySnapshot, error) in
                var stops:[Stop] = []
            self.dangerousStops = []
            if let e = error{
                print ("There was an issue receiving data from firestore, \(e)")
            } else {
                if let snapshotDocuments = querySnapshot?.documents {
                    for doc in snapshotDocuments {
                        let data = doc.data()
                        if let stopName = data[K.FirebaseQuery.stopName] as? String, let stopStatus = data[K.FirebaseQuery.status] as? Bool, let lat = data[K.FirebaseQuery.lat] as? Double, let lon = data [K.FirebaseQuery.lon] as? Double, let lines = data[K.FirebaseQuery.lines] as? [Int], let direction = data[K.FirebaseQuery.direction] as? String, let date = data[K.FirebaseQuery.date] as? Double{
                            let stopLocation = CLLocationCoordinate2D(latitude: lat, longitude: lon)
                            let linesList = lines.sorted()
                            let newStop = Stop(stopName: stopName, status: stopStatus, location: stopLocation, lines: linesList, direction: direction, dateModified: date)
                            stops.append(newStop)
                            
                            if newStop.status {
                                self.dangerousStops.append(newStop)
                            }
                        }
                    }
                    self.updateMap(stops: stops, map: self.mapView)
                }
            }
        }
    }
    
    //#### Adds a point to the database -> Not needed now (insurence if there are no stops in the area)
    func addPointToDatabase(location: CLLocation, line: Int, stopName: String){
        db.collection(K.FirebaseQuery.stopsCollectionName).document(stopName).setData([K.FirebaseQuery.date: Date.timeIntervalSinceReferenceDate,
                                                                                       K.FirebaseQuery.lat:  location.coordinate.latitude,
                                                                                       K.FirebaseQuery.lon: location.coordinate.longitude,
                                                                                       K.FirebaseQuery.lines: [line],
                                                                                       K.FirebaseQuery.status: true,
                                                                                       K.FirebaseQuery.stopName: stopName,])
    }
    
    //#### - Updates status variable of a stop in the database
    func updatePointStatus(documentID stopName: String, status: Bool, direction: String) {
        db.collection(K.FirebaseQuery.stopsCollectionName).document(stopName).setData([K.FirebaseQuery.status: status,
                                                                                       K.FirebaseQuery.date: 12.34,
                                                                                      K.FirebaseQuery.direction: direction], merge: true)
    }
    
    //#### - Restores the stop back to its normal state
    @objc func renewStopStatus(){
        guard dangerousStops.count > 0 else {return}
        print("updating database")
        for stop in dangerousStops{
            if Date.timeIntervalSinceReferenceDate - stop.dateModified > 180 {
                updatePointStatus(documentID: stop.stopName, status: false, direction: "No direction")
            }
        }
    }
    
        
}
//MARK: - MapManagerDelegate
extension MainController: MapManagerDelegate{
    
    func updateMap(stops: [Stop], map: MKMapView) {
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
        self.stops = stops
        for stop in stops {
            mapManager.addPoint(where: stop.location, title: stop.stopName, subtitle: "report_status:\(stop.status)\nlines:\(stop.lines)", map: mapView)
            if stop.status{
                mapManager.addPoint(where: stop.location, title: stop.stopName, subtitle: "report_status:\(stop.status)\nlines:\(stop.lines)\ndirection:\(stop.direction)", map: mapView)
                mapManager.addCircle(where: stop.location, map: mapView)
            }
        }
    }
}

//MARK: - MapViewDelegate Methods
extension MainController: MKMapViewDelegate{
    //#### - DEFINES THE VIEW OF THE CIRCLE
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let color = UIColor.systemRed
        let circleRenderer = MKCircleRenderer(overlay: overlay)
        circleRenderer.lineWidth = 1.0
        circleRenderer.alpha = 0.3
        circleRenderer.fillColor = color
        circleRenderer.strokeColor = color
        return circleRenderer
        }
    
    //#### - DEFINES THE VIEW OF THE POINT
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard let annotation = annotation as? MKPointAnnotation else { return nil }
        
        let annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: "MyMarker")
        if annotation.subtitle!.contains("status:true"){ //## Force unwrapping the subtitle because every single stop has to have a subtitle
            annotationView.markerTintColor = UIColor.systemRed
        } else {
            annotationView.markerTintColor = UIColor.systemBlue
        }
        annotationView.glyphImage = UIImage(systemName: "tram")
        return annotationView
        
    }
    
    //#### - ACCESES THE currenLocationButton
    func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
        hiddenLocationButton = false
    }

}

//MARK: - LocationManagerDelegate Methods
extension MainController: CLLocationManagerDelegate{
    //#### - Takes care of the authorization status
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        
        guard locationManager.authorizationStatus == .authorizedWhenInUse else { return }
        
        locationManager.startUpdatingLocation()
        
    }
    
    //#### - ACCESES THE currenLocation and updates for every second
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        guard let location = locations.last else { return }
        
        currentLocation = location
        
        if !startLocationLoaded {
            mapManager.setUsersLocation(for: location, map: mapView)
            startLocationLoaded = true
            
            loadPoints()
            // IMPLEMENT THE CITY NAME GETTER - HERE
        }
        
        if hiddenLocationButton {
            currentLocationButton.isHidden = true
        } else {
            currentLocationButton.isHidden = false
        }
    }
    
    //#### - handles the error
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
}
