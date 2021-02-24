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
        // guards the function from being executed if the user did not allow locaiton
        guard let location = reportManagerMain.currentLocation, reportManagerMain.defaultLocation == nil else {
            mapManager.setUsersLocation(for: reportManagerMain.defaultLocation!, map: mapView, zoom: 0.1)
            return
        }
        mapManager.setUsersLocation(for: location, map: mapView)
        reportManagerMain.hiddenLocationButton = true
    }
    
    @IBAction func reportButtonPressed(_ sender: UIButton) {
        // guards the function from being executed if the user did not allow locaiton
        guard let location = reportManagerMain.currentLocation else {
            //Alert is show to let the user know that they will not be able to report anything without allowing location services
            let alert = UIAlertController(title: "Brak Lokalizacji Użytkownika", message: "Wymagana jest lokaclizacja użytkowinika do zgłaszania przstanków. \nAby zmienić: \nUstawienia -> Kanarek -> Lokalizacja", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return
        }
        
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

//MARK: - MapManagerDelegate Methods
extension MainController: MapManagerDelegate{
    //#### Function is activated by MapManager when it returns the name of the city for the user's location and check if it is one of the supported cities, if not it loads the default (poznan) + shows alert to let the user know we only support Poznan and Warsaw
    func loadPoints(for cityName: String) {
        let supportedCityNames = ["poznan", "warsaw"]
        
        //## If the user did not allow location services this variable is created with the default value for Poznan or Warsaw
        guard reportManagerMain.defaultLocation == nil else {
            databaseManager.loadPoints(for: cityName) //Load the points for defualt city chosen by the user
            return
        }
        
        if supportedCityNames.contains(cityName){
            //Remove default city name -> then every time the aplicaiton is loaded the city name is deleted and updated
            userDefaults.removeObject(forKey: K.UserDefualts.cityName)
            //Set up city name as a default for the user
            userDefaults.setValue(cityName, forKey: K.UserDefualts.cityName)
            databaseManager.loadPoints(for: cityName)
        } else {
            //REMOVE THE USER DEFUALT CITY NAME -> then every time the aplicaiton is loaded the city name is deleted and updated
            userDefaults.removeObject(forKey: K.UserDefualts.cityName)
            
            //Show alert to notify the user that we only support Poznan and Warsaw -> which he can access with disabled location
            let alert = UIAlertController(title: "Użytkownik poza obszarem", message: "No obecnym etapie dostępne są Poznań i Warszawa. Jest do nich dostęp przy odrzuceniu pozwolenia localizacji\nAby zmienić: \nUstawienia -> Kanarek -> Lokalizacja", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            databaseManager.loadPoints()
        }
        
        //## On app start the function is triggerd and checks the push notification settings
        pushNotificationManager.onAppStart()
    }
}

//MARK: - DatabaseManagerDelegate Methods
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

//MARK: - LocationManagerDelegate Methods
extension MainController: CLLocationManagerDelegate{
    
    //#### - Takes care of the authorization status
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        //## Guards the authorization status of location request
        guard locationManager.authorizationStatus != .denied else {
            // If the user does not allow location services they have to chose one of the two cities as the default location
            let alert = UIAlertController(title: "Brak Lokalizacji", message: "Ze względu na brak udostępnienia lokalizacji proszę wybrać jedno z dostępnych miast jako podstawową opcję", preferredStyle: .alert)
            
            //Loading the points for the current defualt lcoation in central Poznan
            alert.addAction(UIAlertAction(title: "Poznań", style: .default, handler: { (_) in
                // Setting the default location for Poznan
                self.reportManagerMain.defaultLocation = CLLocation(latitude: 52.40719427249367, longitude: 16.919447576063167)
                // Loading the points in Poznan
                self.mapManager.getCurrentCity(for: self.reportManagerMain.defaultLocation)
                // Setting the deafult location in the middle of user's mapView
                self.mapManager.setUsersLocation(for: self.reportManagerMain.defaultLocation!, map: self.mapView, zoom: 0.1)
            }))
            
            //Loading the points for the current defualt lcoation in central Warsaw
            alert.addAction(UIAlertAction(title: "Warszawa", style: .default, handler: { (_) in
                // Setting the default location for Warsaw
                self.reportManagerMain.defaultLocation = CLLocation(latitude: 52.247982010547354, longitude: 21.015697127985522)
                // Loading the points in Warsaw
                self.mapManager.getCurrentCity(for: self.reportManagerMain.defaultLocation)
                // Setting the deafult location in the middle of user's mapView
                self.mapManager.setUsersLocation(for: self.reportManagerMain.defaultLocation!, map: self.mapView, zoom: 0.1)
            }))
            
            self.present(alert, animated: true, completion: nil)
            
            return
        }
        //# If user allowed location services -> start updating location
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
