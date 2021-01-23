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
    func loadPoints(){
        db.collection(K.FirebaseQuery.stopsCollectionName)
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
                        if let stopName = data[K.FirebaseQuery.stopName] as? String, let stopStatus = data[K.FirebaseQuery.status] as? Bool, let lat = data[K.FirebaseQuery.lat] as? Double, let lon = data [K.FirebaseQuery.lon] as? Double, let lines = data[K.FirebaseQuery.lines] as? [Int], let direction = data[K.FirebaseQuery.direction] as? String, let date = data[K.FirebaseQuery.date] as? Double{
                            let stopLocation = CLLocationCoordinate2D(latitude: lat, longitude: lon)
                            let linesList = lines.sorted()
                            let newStop = Stop(stopName: stopName, status: stopStatus, location: stopLocation, lines: linesList, direction: direction, dateModified: date)
                            self.stops.append(newStop)
                            
                            if newStop.status {
                                self.dangerousStops.append(newStop)
                            }
                        }
                    }
                    DispatchQueue.main.async {
                        self.delegate!.updateUI(list: self.stops)
                    }
                }
            }
        }
    }
    
    func loadLineDirections(for chosenLineNumber: Int){
        db.collectionGroup(K.FirebaseQuery.linesCollectionName)
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
//                        self.tableView.reloadData()
                    }
                }
            }
    }
    
    //#### - Updates status variable of a stop in the database
    func updatePointStatus(documentID stopName: String, status: Bool, direction: String, date:Double = 12.34) {
        db.collection(K.FirebaseQuery.stopsCollectionName).document(stopName).setData([K.FirebaseQuery.status: status,
                                                                                       K.FirebaseQuery.date: 12.34,
                                                                                      K.FirebaseQuery.direction: direction], merge: true)
    }
    
    //#### - Restores the stop back to its normal state
    func renewStopStatus(){
        guard dangerousStops.count > 0 else {return}
        for stop in dangerousStops{
            if Date.timeIntervalSinceReferenceDate - stop.dateModified > 20 {
                updatePointStatus(documentID: stop.stopName, status: false, direction: "No direction")
            }
        }
    
    }
    
}

/*
 For future reference
 
 //#### Adds a point to the database -> Not needed now (insurence if there are no stops in the area)
 func addPointToDatabase(location: CLLocation, line: Int, stopName: String){
     db.collection(K.FirebaseQuery.stopsCollectionName).document(stopName).setData([K.FirebaseQuery.date: Date.timeIntervalSinceReferenceDate,
                                                                                    K.FirebaseQuery.lat:  location.coordinate.latitude,
                                                                                    K.FirebaseQuery.lon: location.coordinate.longitude,
                                                                                    K.FirebaseQuery.lines: [line],
                                                                                    K.FirebaseQuery.status: true,
                                                                                    K.FirebaseQuery.stopName: stopName,])
 }
 
 //MARK: - Database-related Functions
     //#### Loads list of stops from the database and listens for the changes -> Not needed now
 //    func loadPoints(){
 //        db.collection(K.FirebaseQuery.stopsCollectionName)
 //            .order(by: K.FirebaseQuery.date)
 //            .addSnapshotListener { (querySnapshot, error) in
 //                var stops:[Stop] = []
 //            self.dangerousStops = []
 //            if let e = error{
 //                print ("There was an issue receiving data from firestore, \(e)")
 //            } else {
 //                if let snapshotDocuments = querySnapshot?.documents {
 //                    for doc in snapshotDocuments {
 //                        let data = doc.data()
 //                        if let stopName = data[K.FirebaseQuery.stopName] as? String, let stopStatus = data[K.FirebaseQuery.status] as? Bool, let lat = data[K.FirebaseQuery.lat] as? Double, let lon = data [K.FirebaseQuery.lon] as? Double, let lines = data[K.FirebaseQuery.lines] as? [Int], let direction = data[K.FirebaseQuery.direction] as? String, let date = data[K.FirebaseQuery.date] as? Double{
 //                            let stopLocation = CLLocationCoordinate2D(latitude: lat, longitude: lon)
 //                            let linesList = lines.sorted()
 //                            let newStop = Stop(stopName: stopName, status: stopStatus, location: stopLocation, lines: linesList, direction: direction, dateModified: date)
 //                            stops.append(newStop)
 //
 //                            if newStop.status {
 //                                self.dangerousStops.append(newStop)
 //                            }
 //                        }
 //                    }
 //                    self.updateMap(stops: stops, map: self.mapView)
 //                }
 //            }
 //        }
 //    }
 //
 //    //#### - Updates status variable of a stop in the database
 //    func updatePointStatus(documentID stopName: String, status: Bool, direction: String) {
 //        db.collection(K.FirebaseQuery.stopsCollectionName).document(stopName).setData([K.FirebaseQuery.status: status,
 //                                                                                       K.FirebaseQuery.date: 12.34,
 //                                                                                      K.FirebaseQuery.direction: direction], merge: true)
 //    }
 //
 //    //#### - Restores the stop back to its normal state
 //    @objc func renewStopStatus(){
 //        guard databaseManager.getDangerousStops().count > 0 else {return}
 //        print("updating database")
 //        for stop in databaseManager.getDangerousStops(){
 //            if Date.timeIntervalSinceReferenceDate - stop.dateModified > 180 {
 //                updatePointStatus(documentID: stop.stopName, status: false, direction: "No direction")
 //            }
 //        }
 //    }
 
 
 //MARK: - Database-related Functions REPORT THREE
     
 //    //#### Provides a list of a line directions
 //    func loadLineDirections(for chosenLineNumber: Int){
 //        db.collectionGroup(K.FirebaseQuery.linesCollectionName)
 //            .whereField(K.FirebaseQuery.lineNumber, isEqualTo: chosenLineNumber)
 //            .addSnapshotListener { (querySnapshot, error) in
 //                self.directions = []
 //                if let e = error {
 //                    print("There was an issue recieving data from firestore, \(e)")
 //                } else {
 //                    if let snapshotDocuments = querySnapshot?.documents {
 //                        for doc in snapshotDocuments{
 //                            let data = doc.data()
 //                            if let lineDirections = data[K.FirebaseQuery.directions] as? [String]{
 //                               self.directions.append(contentsOf: lineDirections)
 //                            }
 //                        }
 //                        self.tableView.reloadData()
 //                    }
 //                }
 //            }
 //    }
 
 
 
 
 */