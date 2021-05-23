//
//  DatabaseManager.swift
//  Kanarek
//
//  Created by Chris Yarosh on 22/01/2021.
//

import Foundation
import Firebase
import CoreLocation

protocol DatabaseManagerDelegate {
    func updateUI(list:[Any])
    
    func failedWithError(error:Error)
}

class DatabaseManager {
    
    var delegate: DatabaseManagerDelegate?
    let userLoginDetails = UserDefaults.standard //Accessing user defaults
    let db = Firestore.firestore() // Creating database reference
    var stops = [Stop]()
    var dangerousStops = [Stop]()
    var directions = [String]()
    var lineNumbers = [Int]()
    
    ///# Functions return the data
    func getStops() -> [Stop]{
        return stops
    }
    func getDirections() -> [String]{
        return directions
    }
    
    ///# - Function is triggered by MainController (in loadPoints method as the delegate of MapManager after receiving the city name) and performs action:
        // -> connects to the database (and constantly listens to the changes made in the database)
        // -> resets stops and dangerousStops lists
        // -> reads data from the database, creates stop objects and adds them to proper lists
        // -> filters the list for only night stops between 00:00-04:00
        // -> calls its delegate to update the map with filtered stop list (which displays the stops on the map using MapManager methods)
    func loadPoints(for city: String){
        db.collection("\(city)\(K.FirebaseQuery.stopsCollectionName)")
            .order(by: K.FirebaseQuery.date)
            .addSnapshotListener { (querySnapshot, error) in
                self.stops = []
                self.dangerousStops = []
                if let e = error{
                    self.delegate?.failedWithError(error: e)
                } else {
                    if let snapshotDocuments = querySnapshot?.documents {
                        for doc in snapshotDocuments {
                            let data = doc.data()
                            if let stopName = data[K.FirebaseQuery.stopName] as? String,
                               let stopStatus = data[K.FirebaseQuery.status] as? Bool,
                               let lat = data[K.FirebaseQuery.lat] as? Double,
                               let lon = data [K.FirebaseQuery.lon] as? Double,
                               let lines = data[K.FirebaseQuery.lines] as? [Int],
                               let reportDetails = data[K.FirebaseQuery.reportDetails] as? String,
                               let date = data[K.FirebaseQuery.date] as? Double,
                               let type = data[K.FirebaseQuery.type] as? String,
                               let nightWork = data[K.FirebaseQuery.nightWork] as? Bool{
                                let stopLocation = CLLocationCoordinate2D(latitude: lat, longitude: lon)
                                let linesList = lines.sorted()
                                let newStop = Stop(stopName: stopName, status: stopStatus, location: stopLocation, lines: linesList, reportDetails: reportDetails, dateModified: date, type: type, nightwork: nightWork)
                                self.stops.append(newStop)
                                
                                if newStop.status {
                                    self.dangerousStops.append(newStop)
                                }
                            }
                        }
                        self.stops = self.filterStops(stops: self.stops) // Filters the stops considering current hour of the day
                        DispatchQueue.main.async {
                            self.delegate!.updateUI(list: self.stops)
                        }
                    }
                }
            }
    }
    
    ///# - Function is triggered by loadPoints method and performs action:
        // -> returns all stops if it is between 04:00-24:00
        // -> returns only nightStops if it is between 00:00-04:00
    func filterStops(stops: [Stop]) -> [Stop] {
        //Accessing the current hour of the device
        let now = Calendar.current.dateComponents(in: .current, from: Date())
        if let currentHour = now.hour {
            /*
             A -> If currentHour is between <00:00-04:00) -> We display the night stops only
             B -> If currentHour is between <04:00-00:00) -> We display all the stops
             */
            if 0 <= currentHour && currentHour < 4  {
//              --A--
                var filteredStops = [Stop]()
                stops.forEach { (stop) in
                    if stop.nightwork {filteredStops.append(stop)} // 'nightwork' is a boolean value
                }
                return filteredStops
            } else {
//              --B--
                return stops
            }

        } else {
            print("Could not get device's current hour -> Night Stops")
            return stops // If there is a problem loading the time
        }
    }
    
    func loadLineNumbers(for stopType: String){
        if stopType == "tramwaj" {
            db.collection("poznan_tram_lines")
                .order(by: "line_number")
                .getDocuments { (querySnapshot, error) in
                    guard error == nil else {
                        print("There was an error getting line numbers")
                        return
                    }
                    self.lineNumbers = []
                    for document in querySnapshot!.documents {
                        if let lineNumber = document.data()["line_number"] as? Int{
                            self.lineNumbers.append(lineNumber)
                        }
                    }
                    DispatchQueue.main.async {
                        self.delegate!.updateUI(list: self.lineNumbers)
                    }
                }
        } else if stopType == "autobus"{
            db.collection("poznan_bus_lines")
                .order(by: "line_number")
                .getDocuments { (querySnapshot, error) in
                    guard error == nil else {
                        print("There was an error getting line numbers")
                        return
                    }
                    self.lineNumbers = []
                    for document in querySnapshot!.documents {
                        if let lineNumber = document.data()["line_number"] as? Int{
                            self.lineNumbers.append(lineNumber)
                        }
                    }
                    DispatchQueue.main.async {
                        self.delegate!.updateUI(list: self.lineNumbers)
                    }
                }
        }
        
    }
    
    ///# - Function is triggered by ReportManagerThree with a lineNumber and cityName and performs action:
        // -> connects to the database of the city
        // -> reads the directionsList document for provided line number
        // -> triggers updateUI method of ReportManagerThree (delegate) which refreshes the tableView data gathered from the database
    func loadLineDirections(for chosenLineNumber: Int, city: String){
        db.collection("\(city)\(K.FirebaseQuery.linesCollectionName)")
            .document("\(chosenLineNumber)")
            .getDocument(completion: { (document, error) in
                self.directions = []
                if let e = error {
                    self.delegate?.failedWithError(error: e)
                    print("There was an issue receiving data from Firestore, \(e)")
                } else {
                    if let document = document, document.exists {
                        if let data = document.data(){
                            if let lineDirections = data[K.FirebaseQuery.directions] as? [String]{
                                self.directions.append(contentsOf: lineDirections)
                            }
                        }
                        DispatchQueue.main.async {
                            self.delegate!.updateUI(list: self.directions)
                        }
                    }
                }
            })
    }
    
    ///# - Function is triggered by renewStopStatus() and ReportManagerThree and performs action:
        // -> connects to the database of the given city
        // -> updates the stop document in the database with the provided data (stopName = document's ID)
    func updatePointStatus(documentID stopName: String, status: Bool, reportDetails: String, date:Double = 12.34, city: String) {
        db.collection("\(city)\(K.FirebaseQuery.stopsCollectionName)")
            .document(stopName).setData([K.FirebaseQuery.status: status,
                                         K.FirebaseQuery.date: date,
                                         K.FirebaseQuery.reportDetails: reportDetails], merge: true)
    }
    
    ///# - Function is triggered by timer in MainController (only if the user allowed location services) and performs action:
        // -> if the stop was reported more than 3 minutes (180s) ago its neutral status gets restored
    func renewStopStatus(){
        guard dangerousStops.count > 0 else {return}
        for stop in dangerousStops{
            if Date.timeIntervalSinceReferenceDate - stop.dateModified > 180 {
                if let cityName = UserDefaults.standard.string(forKey: K.UserDefaults.cityName){
                    updatePointStatus(documentID: stop.stopName, status: false, reportDetails: "No details", date: Date.timeIntervalSinceReferenceDate ,city: cityName)
                }
            }
        }
    }
    
    ///# - Function is triggered by ReportControllerThree and performs action:
        // -> connects to the database
        // -> takes the data and creates a new document in the history database collection for the current city
    func saveReport(stop:String, line:Int, direction:String, city: String){
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm E, d MMM y" // "12:05 Tue, 16 Feb 2021" - format
        db.collection("\(city)\(K.FirebaseQuery.historyCollectionName)").document().setData([
            "user_email" : userLoginDetails.value(forKey: "UserEmail")!, // For history + purposes
            "date": dateFormatter.string(from: date), // For timeline purposes
            "stop_name":stop, // In the title of the notification
            "latitude":52.1231241231223, // For setting the map center on this stop on clicking
            "longitude":16.214124123861289, // For setting the map center on this stop on clicking
            "details":"Linia nr \(line) w kierunku \(direction)"
        ], merge : true)
    }
    
}


