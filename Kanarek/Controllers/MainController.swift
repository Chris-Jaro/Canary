//
//  ViewController.swift
//  Kanarek
//
//  Created by Chris Yarosh on 22/11/2020.
//

import UIKit
import CoreLocation
import MapKit

class MainController: UIViewController{

    var startLocationLoaded = false
    var hiddenLocationButton = true
    
    let locationManager = CLLocationManager()
    var mapManager = MapManager()
    var databaseManager = DatabaseManager()
    
    var timer: Timer?
    var currentLocation: CLLocation?
    
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
        
        timer = Timer.scheduledTimer(timeInterval: 30, target: self, selector: #selector(timerAction), userInfo: nil, repeats: true)
        
        databaseManager.delegate = self
        
    }
    
    @objc func timerAction(){
        databaseManager.renewStopStatus()
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
                destinationVC.stops = mapManager.loadStopsInTheArea(stops: databaseManager.getStops())
            }
        }
    }
        
}
//MARK: - DatabaseManagerDelegate
extension MainController: DatabaseManagerDelegate {
    func updateUI(list:[Any]) {
        guard let stops:[Stop] = list as? [Stop] else { return }
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
            if stop.status{
                mapManager.addPoint(where: stop.location, title: stop.stopName, subtitle: "report_status:\(stop.status)\nlines:\(stop.lines)\ndirection:\(stop.direction)", map: mapView)
                mapManager.addCircle(where: stop.location, map: mapView)
            } else {
                mapManager.addPoint(where: stop.location, title: stop.stopName, subtitle: "report_status:\(stop.status)\nlines:\(stop.lines)", map: mapView)
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
            
            databaseManager.loadPoints()
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
