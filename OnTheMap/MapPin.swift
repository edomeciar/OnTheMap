//
//  MapPin.swift
//  OnTheMap
//
//  Created by Eduard Meciar on 11/10/2016.
//  Copyright © 2016 Eduard Meciar. All rights reserved.
//

import Foundation

class MapPin {
    var latitude: Double = 0.0
    var longitude: Double = 0.0
    var locationName: String?
    var mediaURL: String?
    
    init(latitude: Double, longitude: Double, locationName: String?) {
        self.latitude = latitude
        self.longitude = longitude
        self.locationName = locationName
    }
    
}
