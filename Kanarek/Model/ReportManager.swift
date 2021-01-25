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
    var chosenLineIndex: Int?
    
    //#### ReportControllerThree Variables
    var chosenStopName: String?
    var lineNr: Int?
    var directionIndex: Int?
    
    //#### MainController Variables
    var startLocationLoaded = false
    var hiddenLocationButton = true
    var currentLocation: CLLocation?
}
