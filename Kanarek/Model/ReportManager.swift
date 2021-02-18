//
//  ReportManager.swift
//  Kanarek
//
//  Created by Chris Yarosh on 25/01/2021.
//

import Foundation
import CoreLocation

struct ReportManager{
//#### ReportControllerOne Variables
    var stopsInTheArea: [Stop]?
    var chosenStopIndex: Int?
    
//#### ReportControllerTwo Variables
    var linesList: [Int]?
    var stopName: String?
    var selectedLine: Int?
    
    //#### - Function takes full lines list and converts it into a two-dimensional matrix to provide suit functionality for two-column table
    func adjustLinesList(list: [Int]) -> [[Int]]{
        var workingList = list
        var adjustedList = [[Int]]()
        
        if workingList.count % 2 == 0 {
            for index in filter(list: workingList){
                let item = [workingList[index],workingList[index+1]]
                adjustedList.append(item)
            }
        } else {
            workingList.append(0)
            for index in filter(list: workingList){
                let item = [workingList[index],workingList[index+1]]
                adjustedList.append(item)
            }
        }
        
        
        
        return adjustedList
    }
    
    //#### - Function takes a list of Ints and provides a list of only the evenIndices (0,2,4,...) -> to allow creation of two-dimensional matrix
    func filter(list:[Int]) -> [Int]{
        var evenIndices = [Int]()
        for (index, _) in list.enumerated() {
            if index.isMultiple(of: 2) {
                evenIndices.append(index)
            }
        }
        return evenIndices
    }
    
//#### ReportControllerThree Variables
    var chosenStopName: String?
    var lineNr: Int?
    var directionIndex: Int?
    
//#### MainController Variables
    var startLocationLoaded = false
    var hiddenLocationButton = true
    var currentLocation: CLLocation?
    
    
}

