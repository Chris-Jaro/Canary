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
    var notificationManager = NotificationManager()
    let pushNotificationManager = PushNotificationManager()
    let userDefaults = UserDefaults.standard // Accessing user defaults
    var timer: Timer?
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var currentLocationButton: UIButton!
    @IBOutlet weak var warningView: UIView!
    
    //## - Changes the color of battery and time an service to white
    override var preferredStatusBarStyle: UIStatusBarStyle{
        return .lightContent
    }
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
        warningView.layer.cornerRadius = 10 // Rounds the corner of the warningView
        
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
        timer = Timer.scheduledTimer(timeInterval: 60, target: self, selector: #selector(timerAction), userInfo: nil, repeats: true)
        
        //#### Delegates
        databaseManager.delegate = self
        mapManager.delegate = self
    }
    
    @objc func timerAction(){
        print("Timer Action")
        
        databaseManager.renewStopStatus()
        
        //#### Delaying the code for a few seconds to allow the dangerous stop to be neutral before checking the region
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { // Change `2.0` to the desired number of seconds.
            //## Even if there are no regions to monitor the screen will get back to normal when the dangerous stop becomes neutral
            guard self.locationManager.monitoredRegions.count > 0 else {
                print("There are no regions")
                self.warningView.isHidden = true
                self.mapView.alpha = 1.0
                return
            }
            //## If there are regions to monitor they are checked every minute and ui repspons is triggered according to the state(.inside/.outside)
            for region in self.locationManager.monitoredRegions{
                self.locationManager.requestState(for: region)
            }
        }
        
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
            destinationVC.reportManagerOne.stopsInTheArea = mapManager.filterStopsInTheArea(stops: databaseManager.getStops())
        }
    }
        
}

//MARK: - Map Manager Delegate Methods
extension MainController: MapManagerDelegate{
    //#### Function is activated by MapManager when it returns the name of the city for the user's location and check if it is one of the supported cities, if not it loads the default (poznan)
    func loadPoints(for cityName: String) {
        let supportedCityNames = ["poznan", "warsaw"]
        if supportedCityNames.contains(cityName){
            //REMOVE THE USER DEFUALT CITY NAME -> then every time the aplicaiton is loaded the city name is deleted and updated
            userDefaults.removeObject(forKey: K.UserDefualts.cityName)
            //SET UP THE CITY NAME AS A USER DEFUALT
            userDefaults.setValue(cityName, forKey: K.UserDefualts.cityName)
            databaseManager.loadPoints(for: cityName)
        } else {
            //REMOVE THE USER DEFUALT CITY NAME -> then every time the aplicaiton is loaded the city name is deleted and updated
            userDefaults.removeObject(forKey: K.UserDefualts.cityName)
            databaseManager.loadPoints()
        }
        
        //## On app start the function is triggerd and checks the push notification settings
        pushNotificationManager.onAppStart()
    }
}

//MARK: - Database Manager Delegate Methods
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

//MARK: - MapView Delegate Methods
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
        
        if annotation.subtitle!.contains("true"){ //## Force unwrapping the subtitle because every single stop has to have a subtitle
            annotationView.markerTintColor = UIColor.systemRed
        } else {
            annotationView.markerTintColor = UIColor.systemBlue
        }
        
        //#### Responsible for the image of the MarkerAnnotation
        if annotation.subtitle!.contains("tram"){
            annotationView.glyphImage = UIImage(systemName: "tram")
        } else if annotation.subtitle!.contains("bus") {
            annotationView.glyphImage = UIImage(systemName: "bus")
        } else {
            annotationView.glyphImage = UIImage(systemName: "face.smiling.fill")
        }
        
        //### Responsible for the pop-up ("callout")
        annotationView.canShowCallout = true
        annotationView.calloutOffset = CGPoint(x: 0, y: 0)
        annotationView.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        
        
        
        return annotationView
        
    }
    
    //This function is responsible for the action after clicking the "detailDisclosure" button of the callout
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        guard let annotation = view.annotation as? MKPointAnnotation else { return }
        
        let alert = UIAlertController(title: annotation.title, message: annotation.subtitle, preferredStyle: .alert) // Create a new alert
        let alertAction = UIAlertAction(title: "OK", style: .default) // Creates the action button
        alert.addAction(alertAction) // Add the action button
        self.present(alert, animated: true, completion: nil) // Show the alert
    }
    
    //#### - ACCESES THE currenLocationButton
    func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
        reportManagerMain.hiddenLocationButton = false
    }

}

//MARK: - LocationManager Delegate Methods
extension MainController: CLLocationManagerDelegate{
    
    //#### - Takes care of the authorization status
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        //## Guards the authorization status of location request
        guard locationManager.authorizationStatus != .denied else { return } // IMPLEMENT AN ALERT ON MAIN SCREEN TO NOTIFY THE USER
        locationManager.startUpdatingLocation()
        
    }
    
    //#### - ACCESES THE currenLocation and updates every second
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        guard let location = locations.last else { return }
        
        reportManagerMain.currentLocation = location
        
        if !reportManagerMain.startLocationLoaded {
            //#### Setting the first location of the user when he opens the app
            mapManager.setUsersLocation(for: location, map: mapView)
            reportManagerMain.startLocationLoaded = true
            
            mapManager.getCurrentCity(for: reportManagerMain.currentLocation)// Load the point for the city in the given location
        }
        
        //#### This IF block updates the visibility of the current location button
        if reportManagerMain.hiddenLocationButton {
            currentLocationButton.isHidden = true
        } else {
            currentLocationButton.isHidden = false
        }
    }
    
    //#### Schedules the notification for entering the dangerous region
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        notificationManager.setNotification(title: "Warning - Region Enterd", body: "Entered \(region.identifier)", userInfo: ["aps":["Coordinates":"To show on the map"]]) // -> LOCAL NOTIFICATION ACTION ON CLICKING
    }
    
    //#### Controls the visibility of the waringView depending on user being in the region
    func locationManager(_ manager: CLLocationManager, didDetermineState state: CLRegionState, for region: CLRegion) {
        if state == CLRegionState.inside{
            print("In the region")
            warningView.isHidden = false
            mapView.alpha = 0.8
        } else {
            print("Outside of the region")
            warningView.isHidden = true
            mapView.alpha = 1.0
        }
    }
    
    //#### - handles the error
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
}
