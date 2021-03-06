//
//  ReportManager.swift
//  Kanarek
//
//  Created by Chris Yarosh on 25/01/2021.
//

import Foundation
import CoreLocation

struct DataManager{
//--- ReportControllerOne Variables and Methods
    var stopsInTheArea: [Stop]?
    var chosenStopIndex: Int?
    
    //## - Function that filters the line numbers depending on the hour of the day (night/day lines)
    //## - Function is triggered by ReportOneController when preparing for segue and performs action:
        // -> filerts the list of lineNumbers for of the chosen stop depending on the time of the day
            // - <5:00-22:00) -> returns only day lineNumbers (x < 200  or 300 =< x )
            // - <22:00-00:00) + <04:00-05:00)  -> returns all lineNumbers because some lines are still operating and others already
            // - <00:00-04:00) -> returns only night lineNumbers (200 =< x < 300)
    func filterLineNumbers(lines: [Int]) -> [Int] {
        //Accessing the current hour of the device
        let now = Calendar.current.dateComponents(in: .current, from: Date())
        if let currentHour = now.hour {
            /*
             A -> If currentHour is between <5:00-22:00) -> We have day
             B -> if currentHour is between <22:00-00:00) + <04:00-05:00)  -> We have day&night
             C -> if currentHour is between <00:00-04:00) -> We have night
             */
            
            if 5 <= currentHour && currentHour < 22 {
//              --A--
                var filterdLines = [Int]()
                lines.forEach { (line) in
                    if line < 200 || line >= 300{
                        filterdLines.append(line)
                    }
                }
                return filterdLines
                
            } else if 0 <= currentHour && currentHour < 4 {
//              --B--
                var filterdLines = [Int]()
                lines.forEach { (line) in
                    if line >= 200 && line < 300{
                        filterdLines.append(line)
                    }
                }
                return filterdLines
        
            } else {
//              --C--
                return lines
            }

        } else {
            print("Could not get device's current hour -> Night Lines")
            return lines // If there is a problem loading the time
        }
    }
    
//--- ReportControllerTwo Variables and Methods
    var linesList: [Int]?
    var stopName: String?
    var selectedLine: Int?
    
    //## - Function takes full lines list and converts it into a two-dimensional matrix to provide suit functionality for two-column table ([1,2,3,4] -> [[1,2],[3,4]])
    func adjustLinesList(list: [Int]) -> [[Int]]{
        var workingList = list
        var adjustedList = [[Int]]()
        
        if workingList.count % 2 == 0 {
            for index in filterEvenIndices(list: workingList){
                let item = [workingList[index],workingList[index+1]]
                adjustedList.append(item)
            }
        } else {
            workingList.append(0)
            for index in filterEvenIndices(list: workingList){
                let item = [workingList[index],workingList[index+1]]
                adjustedList.append(item)
            }
        }
        
        
        
        return adjustedList
    }
    
    //## - Function takes a list [Int] and provides a list of only the evenIndices (0,2,4,...) -> to allow creation of two-dimensional matrix
    func filterEvenIndices(list:[Int]) -> [Int]{
        var evenIndices = [Int]()
        for (index, _) in list.enumerated() {
            if index.isMultiple(of: 2) {
                evenIndices.append(index)
            }
        }
        return evenIndices
    }
    
//--- ReportControllerThree Variables
    var chosenStopName: String?
    var lineNr: Int?
    var directionIndex: Int?
    
//--- MainController Variables
    var startLocationLoaded = false
    var hiddenLocationButton = true
    var currentLocation: CLLocation?
    var defaultLocation: CLLocation?//If the user choses the city from the pop-up and did not allow location services
    
    
}

