//
//  StopModel.swift
//  Kanarek
//
//  Created by Chris Yarosh on 07/01/2021.
//

import Foundation
import CoreLocation

// - Struct defines the Stop object and its variables
struct Stop {
    let stopName: String
    let status: Bool
    let location: CLLocationCoordinate2D
    let reportDetails: String
    let dateModified: Double
    let type: String
    let nightwork: Bool
}
