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
    
    let locationManager = CLLocationManager()
    var mapManager = MapManager()
    var databaseManager = DatabaseManager()
    var reportManagerMain = ReportManager()
    
    var vWarning : UIView?
    var timer: Timer?
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var currentLocationButton: UIButton!
    
    //#### Two functions that hide the navigation bar on the main screen
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = true
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.isNavigationBarHidden = false
    }
    //#### Loads the view
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.layer.cornerRadius = 10 // Rounds the corner of the mapView
        
        //#### Location manager configuaration
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.allowsBackgroundLocationUpdates = true // This line is respinsible for background location updates
        
        //#### Map View configuration
        mapView.isZoomEnabled = true
        mapView.showsUserLocation = true
        mapView.delegate = self
        mapView.setUserTrackingMode(.follow, animated: true)
        
        //#### Timer configuration -> after 60 seconds the function checkin if some of the dangerous stops are too obsolete ##CHANGE TO 60 SEC
        timerAction()
        timer = Timer.scheduledTimer(timeInterval: 60, target: self, selector: #selector(timerAction), userInfo: nil, repeats: true)
        
        //#### Delegates
        databaseManager.delegate = self
        mapManager.delegate = self
        
    }
    
    @objc func timerAction(){
        databaseManager.renewStopStatus()
        print("Timer Action")
    }
    
    @IBAction func currentLocationButtonPressed(_ sender: UIButton) {
        guard let location = reportManagerMain.currentLocation else { return } // guards the function from being executed if the user did not allow locaiton
        mapManager.setUsersLocation(for: location, map: mapView)
        reportManagerMain.hiddenLocationButton = true
    }
    
    @IBAction func reportButtonPressed(_ sender: UIButton) {
        guard let location = reportManagerMain.currentLocation else { return } // guards the function from being executed if the user did not allow locaiton
        mapManager.reportLocation = location
        performSegue(withIdentifier: "GoToReportOne", sender: self)
    }
    
    //##### Prepares for segue (any action needed to be taken before going to the other screen)
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "GoToReportOne"{
            let destinationVC = segue.destination as! ReportControllerOne
            destinationVC.reportManagerOne.stopsInTheArea = mapManager.loadStopsInTheArea(stops: databaseManager.getStops())
        }
    }
        
}
//MARK: - MapManagerDelegate
extension MainController: MapManagerDelegate{
    //#### Function is activated by MapManager when it returns the name of the city for the user's location and check if it is one of the supported cities of not it loads the default (poznan)
    func loadPoints(for cityName: String) {
        let cityNames = ["poznan"]
        if cityNames.contains(cityName){
            databaseManager.loadPoints(for: cityName)
        } else {
            databaseManager.loadPoints()
        }
    }
}

//MARK: - DatabaseManagerDelegate
extension MainController: DatabaseManagerDelegate {
    //#### Funciton is triggered by database manager when the points from the database are loaded and then it refreshes the mapView with the new data
    func updateUI(list:[Any]) {
        guard let stops:[Stop] = list as? [Stop] else { return }
        mapManager.deleteOldPoints(on: mapView)
        mapManager.resetMonitoring(for: locationManager)
        for stop in stops {
            if stop.status{
                mapManager.addDangerousStop(for: stop, on: mapView)
                mapManager.monitorRegionAtLocation(center: stop.location, identifier: stop.stopName, for: locationManager)
            } else {
                mapManager.addNeutralStop(for: stop, on: mapView)
            }
        }
    }

}

//MARK: - Warning Functionality
extension MainController {
    func showWarning(onView : UIView) {
        let warningView = UIView.init(frame: onView.bounds)
        warningView.backgroundColor = UIColor.red.withAlphaComponent(0.2)
        DispatchQueue.main.async {
            onView.addSubview(warningView)
        }
        vWarning = warningView
    }
    
    func removeWarning() {
        DispatchQueue.main.async {
            self.vWarning?.removeFromSuperview()
            self.vWarning = nil
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
        reportManagerMain.hiddenLocationButton = false
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
        
        reportManagerMain.currentLocation = location
        
        if !reportManagerMain.startLocationLoaded {
            //#### Setting the first location of the user when he opens the app
            mapManager.setUsersLocation(for: location, map: mapView)
            reportManagerMain.startLocationLoaded = true
            
            // Load the point for the city in the given location
            mapManager.getCurrentCity(for: reportManagerMain.currentLocation)

        }
        
        //#### This if block updates the visibility of the current location button
        if reportManagerMain.hiddenLocationButton {
            currentLocationButton.isHidden = true
        } else {
            currentLocationButton.isHidden = false
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        //####
        //NOTIFICATIONS
        //####
        print("Entered \(region.identifier)")
        showWarning(onView: mapView)
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        print("Exited \(region.identifier)")
        removeWarning()
    }
    
    //#### TO CHECK IF THE USER IS IN THE REGION
//      ## Somewhere in the code above
//    for region in locationManager.monitoredRegions{
//        locationManager.requestState(for: region)
//    }
//    func locationManager(_ manager: CLLocationManager, didDetermineState state: CLRegionState, for region: CLRegion) {
//        if state == CLRegionState.inside{
//            showWarning(onView: mapView)
//        } else {
//            removeWarning()
//        }
//    }
    
    //#### - handles the error
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
}
