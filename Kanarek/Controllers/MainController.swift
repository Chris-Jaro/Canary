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
    
    var currentLocation: CLLocation?
    
    var startLocationLoaded = false
    var hiddenLocationButton = true
    
    let locationManager = CLLocationManager()
    
    let db = Firestore.firestore()
    
    var stops: [Stop] = [Stop(stopName: "Os. Rzeczypospolitej", status: false, location: CLLocationCoordinate2D(latitude: 52.38615148130084,
                                                                                                                longitude: 16.945134121143088), lines: [1,2], direction: "null"),
                         Stop(stopName: "Os. Piastowskie", status: true, location: CLLocationCoordinate2D(latitude: 52.390541474302026,
                                                                                                          longitude: 16.947058944429564), lines: [1,2], direction: "null"),]
    var stopsInMyArea: [Stop] = []
    
    
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
    }
    

    @IBAction func currentLocationButtonPressed(_ sender: UIButton) {
        if let location = currentLocation{
            setUsersLocation(for: location)
        }
    }
    
    @IBAction func reportButtonPressed(_ sender: UIButton) {
        loadStopsInTheArea()
        performSegue(withIdentifier: "GoToReportOne", sender: self)
    }
    
    //##### Prepares for segue (any action needed to be taken before going to the other screen)
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "GoToReportOne"{
            let destinationVC = segue.destination as! ReportControllerOne
            if let location = currentLocation{
                destinationVC.reportCoortdinates = "\(location.coordinate.latitude),\(location.coordinate.longitude)"
                destinationVC.stops = stopsInMyArea
            }
        }
    }
    
//MARK: - Database-related Functions
    //#### Loads list of stops from the database and listens for the changes -> Not needed now
    func loadPoints(){
        db.collection(K.FirebaseQuery.stopsCollectionName)
            .order(by: K.FirebaseQuery.date)
            .addSnapshotListener { (querySnapshot, error) in
            self.stops = []
            if let e = error{
                print ("There was an issue receiving data from firestore, \(e)")
            } else {
                if let snapshotDocuments = querySnapshot?.documents {
                    for doc in snapshotDocuments {
                        let data = doc.data()
                        if let stopName = data[K.FirebaseQuery.stopName] as? String, let stopStatus = data[K.FirebaseQuery.status] as? Bool, let lat = data[K.FirebaseQuery.lat] as? Double, let lon = data [K.FirebaseQuery.lon] as? Double, let lines = data[K.FirebaseQuery.lines] as? [Int], let direction = data[K.FirebaseQuery.direction] as? String{
                            let stopLocation = CLLocationCoordinate2D(latitude: lat, longitude: lon)
                            let linesList = lines.sorted()
                            let newStop = Stop(stopName: stopName, status: stopStatus, location: stopLocation, lines: linesList, direction: direction)
                            self.stops.append(newStop)
                        }
                    }
                    self.refreshMap()
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
    
    
//MARK: - Map-related Fuctions
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
    
    //#### - Refreshes information displayed in the map -> Not needed now
    func refreshMap(){
        var list = mapView.annotations
        if let userIndex = list.firstIndex(where: { (annotation) -> Bool in
            if type(of: annotation) == MKUserLocation.self {
                return true
            } else {
                return false
            }
        }) {
            list.remove(at: userIndex)
        }
        mapView.removeAnnotations(list)
        mapView.removeOverlays(mapView.overlays)
        for stop in stops {
            addPoint(where: stop.location, title: stop.stopName, subtitle: "status:\(stop.status)")
            if stop.status{
                addPoint(where: stop.location, title: stop.stopName, subtitle: "status:\(stop.status)\ndirection:\(stop.direction)")
                addCircle(where: stop.location)
            }
        }
        
    }
    
    //#### - Provides a list of stop names in a given area from current location -> To the first report list of stops
    func loadStopsInTheArea(){
        if let location = currentLocation{
            stopsInMyArea = []
            for stop in stops{
                let distance = location.distance(from: CLLocation(latitude: stop.location.latitude, longitude: stop.location.longitude))
                if distance < 1000 {
                    stopsInMyArea.append(stop)
                }
            }
//            stopsInMyArea.forEach { (stop) in
//                print (stop.stopName)
//            }
        }
    }
    
    //#### - Resets current mapView and places the user in its center -> Not needed now
    func setUsersLocation(for location: CLLocation){
        let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        mapView.setRegion(region, animated: true)
        
        hiddenLocationButton = true
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
        
//        print("Automatic: \(location.coordinate.latitude), \(location.coordinate.longitude)")
        
        if !startLocationLoaded {
            setUsersLocation(for: location)
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
