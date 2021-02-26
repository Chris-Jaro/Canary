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
    
    let locationManager = CLLocationManager() // Accessing location-related methods
    var mapManager = MapManager() // Accessing map-related methods
    var databaseManager = DatabaseManager() // Accessing database-related methods and variables
    var dataManagerMain = DataManager() // Accessing all data related variables and methods needed by this controller
    var notificationManager = NotificationManager() // Accessing local notification methods
    let pushNotificationManager = PushNotificationManager() // Accessing puhs notification methods
    let userDefaults = UserDefaults.standard // Accessing user defaults
    var timer: Timer? // timer for refreshing the dangerous points
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
    
    //## - Function is triggered when the view is loaded ans performs actions:
        // -> rounds the corners of map and warning views
        // -> sets location manager delegate and configures it
        // -> sets map delegate and configures it
        // -> sets a timer to refresh outdated stops every 60 seconds
        // -> sets delegates for databaseManager and mapManager
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
    
    //## - Function is triggered every 60 seconds by the timer set up when the view is loaded and perforems action:
        // -> user must allow location services for the timer to perform is action (to avoid database bugs if the user passively choses Warsaw with renewStopsStaus()) 
        // -> triggers renewStopsStatus function (which checks is a stops set to dangerous more than 2 minutes ago If so it sets it back to neutral)
        // -> delays the execution of the code for two seconds
            // -> if there are no dangerous stops or user is not in one -> the view normal map view is restored
            // -> if user is in the dangerous region -> the waring view is shown on the map
    @objc func timerAction(){
        guard let _ = dataManagerMain.currentLocation else { return }
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
    
    //## - Function is triggered by tapping "currentLocationButton" in the top-left corner of the map and performs action:
        // -> if the user did not allow location services -> they are sent back to the deafult locaiton and zoom for the chosen city
        // -> if user allowed location services -> set user's location as mapView center
        // -> hides the button until the user modifies the visible region of the maps
    @IBAction func currentLocationButtonPressed(_ sender: UIButton) {
        // guards the function from being executed if the user did not allow locaiton
        guard let location = dataManagerMain.currentLocation, dataManagerMain.defaultLocation == nil else {
            mapManager.setUsersLocation(for: dataManagerMain.defaultLocation!, map: mapView, zoom: 0.1)
            return
        }
        mapManager.setUsersLocation(for: location, map: mapView)
        dataManagerMain.hiddenLocationButton = true
    }
    
    //## - Function is triggere by tapping "report button" and performs actions:
        // -> if user did not allow location -> alert is displayed to inform the user and point to phone settings to allow location
        // -> passes the location of the report to dataManager
        // -> performs segue to ReportViewOne
    @IBAction func reportButtonPressed(_ sender: UIButton) {
        // guards the function from being executed if the user did not allow locaiton
        guard let location = dataManagerMain.currentLocation else {
            //Alert is show to let the user know that they will not be able to report anything without allowing location services
            let alert = UIAlertController(title: "Brak Lokalizacji Użytkownika", message: "Wymagana jest lokaclizacja użytkowinika do zgłaszania przstanków. \nAby zmienić: \nUstawienia -> Kanarek -> Lokalizacja", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return
        }
        
        mapManager.reportLocation = location
        performSegue(withIdentifier: K.Segues.toReportOne, sender: self)
    }
    
    
    //## - Function is triggerd just berofe the segue is initiated and performs action
        // -> passes a list of stops in the 1000m range from the user
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "GoToReportOne"{
            let destinationVC = segue.destination as! ReportControllerOne
            destinationVC.dataManagerOne.stopsInTheArea = mapManager.filterStopsInTheArea(stops: databaseManager.getStops())
        }
    }
        
}

//MARK: - MapManagerDelegate Methods
extension MainController: MapManagerDelegate{
    
    //## - Function is triggered by mapManager (because it is its delegate's function) when it receives the info about current city of the user and performs ations :
        // -> if user did not allow location services the defaul location for chosen city is displayed
        // -> if user allowed location services and is in one of the supported cities -> databaseManager loads the points for the given city from the database
        // -> if user allowed location services and is NOT in one of the supported cities -> alert is displayed to inform the user that we only support Poznan and Warsow and they can passively access then by not allowing location
        // -> resaves cityName (every time the application is run) to userDefaults to allow other parts of the app to access it (reportThreeView and Settings)
        // -> performs pushNotification subscription on initial app start or if someone changes city from Warsaw to Poznan (it changes the topic subscription accordingly)
    func loadPoints(for cityName: String) {
        let supportedCityNames = ["poznan", "warsaw"]
        
        //## If the user did not allow location services this variable is created with the default value for Poznan or Warsaw
        guard dataManagerMain.defaultLocation == nil else {
            databaseManager.loadPoints(for: cityName) //Load the points for defualt city chosen by the user
            return
        }
        
        if supportedCityNames.contains(cityName){
            //Remove default city name -> then every time the aplicaiton is loaded the city name is deleted and updated
            userDefaults.removeObject(forKey: K.UserDefaults.cityName)
            //Set up city name as a default for the user
            userDefaults.setValue(cityName, forKey: K.UserDefaults.cityName)
            databaseManager.loadPoints(for: cityName)
        } else {
            //REMOVE THE USER DEFUALT CITY NAME -> then every time the aplicaiton is loaded the city name is deleted and updated
            userDefaults.removeObject(forKey: K.UserDefaults.cityName)
            
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
    
    //## - Function is triggered by databaseManager (because it is its delegate's function) when it receives information regarding stops in this city from Firebase database and performs ations :
        // -> deletes old points from the map
        // -> resets the monitoring of dangerous regions
        // -> checks if the stop is dangerous or nerutral and places it on the map accordingly
        // -> adds dangerous stops to monitored regions
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
    //## - Function defines the way the circle overlay is displayed on the map (in this cese "danger zone" around the reported stop)
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
    //## - Function defines the way an annotation is displayed on the map (in this case the stop)
        // -> color of the annotation depending on stop status (blue/red)
        // -> glyph image if the annotation depending on the type of the stop (tram/bus/metro/train)
        // -> pop-up (callout) for the user to have access to stop details in a more suitable way
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
    
    // - Function defines the action that is perforemd when an annotation pop-up's button is tapped
        // -> show an alert with the details regarding the stop
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        guard let annotation = view.annotation as? MKPointAnnotation else { return }
        
        let alert = UIAlertController(title: annotation.title, message: annotation.subtitle, preferredStyle: .alert) // Create a new alert
        let alertAction = UIAlertAction(title: "OK", style: .default) // Creates the action button
        alert.addAction(alertAction) // Add the action button
        self.present(alert, animated: true, completion: nil) // Show the alert
    }
    
    //#### - ACCESES THE currenLocationButton
    //## - Function is triggered then the current region of the map (visible part) is chaneged and perfroms action:
        // -> it reveals the currentLocation button to allow user the return to his location
    func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
        dataManagerMain.hiddenLocationButton = false
    }

}

//MARK: - LocationManagerDelegate Methods
extension MainController: CLLocationManagerDelegate{
    
    //## - Function is triggered when the user allows or denies location services and performs action:
        // -> if the user allows location services -> starts updating locaiton
        // -> if the user does not allow locaiton services -> displays an alert with the option to chose a default city and allow it's passive observation (only loads points, but does not allow reporting)
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        //## Guards the authorization status of location request
        guard locationManager.authorizationStatus != .denied else {
            // If the user does not allow location services they have to chose one of the two cities as the default location
            let alert = UIAlertController(title: "Brak Lokalizacji", message: "Ze względu na brak udostępnienia lokalizacji proszę wybrać jedno z dostępnych miast jako podstawową opcję", preferredStyle: .alert)
            
            //Loading the points for the current defualt lcoation in central Poznan
            alert.addAction(UIAlertAction(title: "Poznań", style: .default, handler: { (_) in
                // Setting the default location for Poznan
                self.dataManagerMain.defaultLocation = CLLocation(latitude: 52.40719427249367, longitude: 16.919447576063167)
                // Loading the points in Poznan
                self.mapManager.getCurrentCity(for: self.dataManagerMain.defaultLocation)
                // Setting the deafult location in the middle of user's mapView
                self.mapManager.setUsersLocation(for: self.dataManagerMain.defaultLocation!, map: self.mapView, zoom: 0.1)
            }))
            
            //Loading the points for the current defualt lcoation in central Warsaw
            alert.addAction(UIAlertAction(title: "Warszawa", style: .default, handler: { (_) in
                // Setting the default location for Warsaw
                self.dataManagerMain.defaultLocation = CLLocation(latitude: 52.247982010547354, longitude: 21.015697127985522)
                // Loading the points in Warsaw
                self.mapManager.getCurrentCity(for: self.dataManagerMain.defaultLocation)
                // Setting the deafult location in the middle of user's mapView
                self.mapManager.setUsersLocation(for: self.dataManagerMain.defaultLocation!, map: self.mapView, zoom: 0.1)
            }))
            
            self.present(alert, animated: true, completion: nil)
            
            return
        }
        //# If user allowed location services -> start updating location
        locationManager.startUpdatingLocation()
    }
    
    //## - Function is triggered every seconnd when the location is updated
        // -> saves the current locaiton in the dataManager
        // -> sets the initial location of the user on the map (on app launch)
        // -> upadets the currentLocationButton visibility
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        guard let location = locations.last else { return }
        
        dataManagerMain.currentLocation = location
        
        if !dataManagerMain.startLocationLoaded {
            //#### Setting the first location of the user when he opens the app
            mapManager.setUsersLocation(for: location, map: mapView)
            dataManagerMain.startLocationLoaded = true
            
            mapManager.getCurrentCity(for: dataManagerMain.currentLocation)// Load the point for the city in the given location
        }
        
        //#### This IF block updates the visibility of the current location button
        if dataManagerMain.hiddenLocationButton {
            currentLocationButton.isHidden = true
        } else {
            currentLocationButton.isHidden = false
        }
    }
    
    //## - Function is triggered when user enters the monitoring region and preforms action:
        // -> sends local notificatio to the user with the report details
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        notificationManager.setNotification(title: "Warning - Region Enterd", body: "Entered \(region.identifier)", userInfo: ["aps":["Coordinates":"To show on the map"]])
    }
    
    //## - Function is triggered when the user's state is determied inside or outside of dangerous region and performs action:
        // -> if user is inside the dangerous region the warning view becomes visible and map becomes red
        // -> if user is outside the dangerous region the warning vewi becomes hidden and map normal state is restored
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
    
    //## - Function handles the error (prints for now)
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
}
