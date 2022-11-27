//
//  File.swift
//  
//
//  Created by Robinson Cartagena on 10/11/22.
//

import Vapor
import Foundation

struct CheckPoint: Content {
  let lat: Double
  let lng: Double
}

func arePointsNear(_ checkPoint: CheckPoint, _ centerPoint: CheckPoint, _ km: Double) -> Bool {
    var ky = Double(40000 / 360);
    var kx = cos(Double.pi * centerPoint.lat / Double(180.0)) * ky;
    var dx = abs(centerPoint.lng - checkPoint.lng) * kx;
    var dy = abs(centerPoint.lat - checkPoint.lat) * ky;
  
    return sqrt(dx * dx + dy * dy) <= km;
}
