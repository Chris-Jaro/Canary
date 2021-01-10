//
//  StopModel.swift
//  Kanarek
//
//  Created by Chris Yarosh on 07/01/2021.
//

import Foundation
import CoreLocation

struct Stop {
    let stopName: String
    let status: Bool
    let location: CLLocationCoordinate2D
    let lines: [Int]
    let direction: String
}
