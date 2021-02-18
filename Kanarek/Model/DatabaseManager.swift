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
}

class DatabaseManager {
    
    var delegate: DatabaseManagerDelegate?
    
    let userLoginDetails = UserDefaults.standard
    
    let db = Firestore.firestore()
    
    var stops:[Stop] = []
    var dangerousStops:[Stop] = []
    var directions:[String] = []
    
    func getStops() -> [Stop]{
        return stops
    }
    
    func getDirections() -> [String]{
        return directions
    }
    
    //#### Loads list of stops from the database and listens for the changes -> Not needed now
    func loadPoints(for cityName: String = "poznan"){
        db.collection("\(cityName)\(K.FirebaseQuery.stopsCollectionName)")
            .order(by: K.FirebaseQuery.date)
            .addSnapshotListener { (querySnapshot, error) in
                self.stops = []
                self.dangerousStops = []
                if let e = error{
                    print ("There was an issue receiving data from firestore, \(e)")
                } else {
                    if let snapshotDocuments = querySnapshot?.documents {
                        for doc in snapshotDocuments {
                            let data = doc.data()
                            if let stopName = data[K.FirebaseQuery.stopName] as? String,
                               let stopStatus = data[K.FirebaseQuery.status] as? Bool,
                               let lat = data[K.FirebaseQuery.lat] as? Double,
                               let lon = data [K.FirebaseQuery.lon] as? Double,
                               let lines = data[K.FirebaseQuery.lines] as? [Int],
                               let direction = data[K.FirebaseQuery.direction] as? String,
                               let date = data[K.FirebaseQuery.date] as? Double,
                               let type = data[K.FirebaseQuery.type] as? String,
                               let nightWork = data[K.FirebaseQuery.nightWork] as? Bool{
                                let stopLocation = CLLocationCoordinate2D(latitude: lat, longitude: lon)
                                let linesList = lines.sorted()
                                let newStop = Stop(stopName: stopName, status: stopStatus, location: stopLocation, lines: linesList, direction: direction, dateModified: date, type: type, nightwork: nightWork)
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
    
    //Function that filters the stops depending on the hour of the day (night/day lines)
    func filterStops(stops: [Stop]) -> [Stop]{
        //Accessing the current hour of the device
        let now = Calendar.current.dateComponents(in: .current, from: Date())
        if let currentHour = now.hour {
            /*
             A -> If currentHour is between <00:00-04:00) -> We display the night stops only
             B -> If currentHour is between <04:00-00:00) -> We display all the stops
             */
            if 0 <= currentHour && currentHour < 4  {
//              --A--
                var filterdStops = [Stop]()
                stops.forEach { (stop) in
                    if stop.nightwork {filterdStops.append(stop)} // 'nightwork' is a boolean value
                }
                return filterdStops
            } else {
//              --B--
                return stops
            }

        } else {
            print("Could not get device's current hour -> Night Stops")
            return stops // If there is a problem loading the time
        }
    }
    
    //#### - Loads the directions for the chosen line number and currnet city
    func loadLineDirections(for chosenLineNumber: Int, cityName: String = "poznan"){
        db.collectionGroup("\(cityName)\(K.FirebaseQuery.linesCollectionName)")
            .whereField(K.FirebaseQuery.lineNumber, isEqualTo: chosenLineNumber)
            .addSnapshotListener { (querySnapshot, error) in
                self.directions = []
                if let e = error {
                    print("There was an issue recieving data from firestore, \(e)")
                } else {
                    if let snapshotDocuments = querySnapshot?.documents {
                        for doc in snapshotDocuments{
                            let data = doc.data()
                            if let lineDirections = data[K.FirebaseQuery.directions] as? [String]{
                                self.directions.append(contentsOf: lineDirections)
                            }
                        }
                        DispatchQueue.main.async {
                            self.delegate!.updateUI(list: self.directions)
                        }
                    }
                }
            }
    }
    
    //#### - Updates status variable of a stop in the database
    func updatePointStatus(documentID stopName: String, status: Bool, direction: String, date:Double = 12.34, cityName: String = "poznan") {
        db.collection("\(cityName)\(K.FirebaseQuery.stopsCollectionName)").document(stopName).setData([K.FirebaseQuery.status: status,
                                                                                                       K.FirebaseQuery.date: date,
                                                                                                       K.FirebaseQuery.direction: direction], merge: true)
    }
    
    //#### - Restores the stop back to its normal state
    func renewStopStatus(){
        guard dangerousStops.count > 0 else {return}
        for stop in dangerousStops{
            if Date.timeIntervalSinceReferenceDate - stop.dateModified > 120 {
                updatePointStatus(documentID: stop.stopName, status: false, direction: "No direction")
            }
        }
        
    }
    
    //#### - Saves report details to the history collection
    func saveReport(stop:String, line:Int, direction:String){
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm E, d MMM y" // 12:05 Tue, 16 Feb 2021
        db.collection(K.FirebaseQuery.historyCollectionName).document().setData([
            "user_email" : userLoginDetails.value(forKey: "UserEmail")!, // For history + purposes
            "date": dateFormatter.string(from: date), // For timeline purposes
            "stop_name":stop, // In the title of the noftification
            "latitude":52.1231241231223, // For setting the map center on this stop on clikcing
            "longitude":16.214124123861289, // For setting the map center on this stop on clikcing
            "details":"Line nr \(line) towards \(direction)"
        ], merge : true)
    }
    
}

/*
 For future reference -> STOPS CHART -> EXCEL TO CSV -> CSV + PYTHON -> DICTIONARY OF STOPS FOR EARIER ADDING TO THE DATABASE !!!
 
 //#### Adds a point to the database -> Not needed now (insurence if there are no stops in the area)
 func addPointToDatabase(location: CLLocation, line: Int, stopName: String, cityName: String = "poznan"){
 db.collection("\(cityName)\(K.FirebaseQuery.stopsCollectionName)").document(stopName).setData([K.FirebaseQuery.date: Date.timeIntervalSinceReferenceDate,
 K.FirebaseQuery.lat:  location.coordinate.latitude,
 K.FirebaseQuery.lon: location.coordinate.longitude,
 K.FirebaseQuery.lines: [line],
 K.FirebaseQuery.status: true,
 K.FirebaseQuery.stopName: stopName,])
 }
 
 */
