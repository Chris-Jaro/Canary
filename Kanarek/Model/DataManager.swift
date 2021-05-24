//
//  DataManager.swift
//  Kanarek
//
//  Created by Chris Yarosh on 25/01/2021.
//

import Foundation
import CoreLocation

struct DataManager{
//_____ReportControllerOne Variables and Methods_____________
    var stopsInTheArea: [Stop]?
    var chosenStopIndex: Int?
    
//_____ReportControllerTwo Variables_____________
    var linesList: [Int]?
    var chosenStopType: String?
    var stopName: String?
    var selectedLine: Int?
    var stopMessage: String?
    
//_____ReportControllerThree Variables______________
    var chosenStopName: String?
    var lineNr: Int?
    var directionIndex: Int?
    
//_____MainController Variables______________
    var startLocationLoaded = false
    var hiddenLocationButton = true
    var currentLocation: CLLocation?
    var defaultLocation: CLLocation?//If the user choses the city from the pop-up and did not allow location services
}

//MARK: - ReportControllerOne Methods
extension DataManager {
    ///# - Function is triggered by ReportOneController when preparing for segue and performs action:
        // -> filters the list of lineNumbers for of the chosen stop depending on the time of the day (night/day lines)
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
                var filteredLines = [Int]()
                lines.forEach { (line) in
                    if line >= 200 && line < 300{
                        filteredLines.append(line)
                    }
                }
                return filteredLines
        
            } else {
//              --C--
                return lines
            }

        } else {
            print("Could not get device's current hour -> Night Lines")
            return lines // If there is a problem loading the time
        }
    }
}

//MARK: - ReportControllerTwo Methods
extension DataManager{
    ///# - Function is triggered by ReportControllerTwo (when loading tableView) and performs action:
        // -> converts the one-dimensional array of lineNumbers into a two-dimensional array to be suitable for two-column table ([1,2,3,4] -> [[1,2],[3,4]])
        // -> if lines list.count is odd zero is appended and then adjusted (and if a button.title == "0" it gets disabled)
    func adjustLinesList(list: [Int]) -> [[Int]]{
        var workingList = list
        var adjustedList = [[Int]]()
        
        ///# - Function is triggered by adjustLinesList and performs action:
            // -> takes a list [Int]
            // -> returns a list of only the even indices (0,2,4,...) -> to allow creation of two-dimensional matrix
        func filterEvenIndices(list:[Int]) -> [Int]{
            var evenIndices = [Int]()
            for (index, _) in list.enumerated() {
                if index.isMultiple(of: 2) {
                    evenIndices.append(index)
                }
            }
            return evenIndices
        }
        
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
}
