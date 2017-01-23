//
//  venue.swift
//  IronbitExam
//
//  Created by Alan Escobar Martínez on 1/22/17.
//  Copyright © 2017 Alan Escobar. All rights reserved.
//

import Foundation

class Venue {
    var name: String? = ""
    var location: (latitude: Double? , longitude: Double?, formattedAddress: [String]?, distance: Int?) = (0.0, 0.0, [""], 0)
    var category: (name: String?, icon: String?)  = ("","")
    var stats: (checkinsCount: Int?, usersCount: Int?, tipCount: Int?) = (0,0,0)
    var id: String? = ""
    
    init?(name: String, latitude: Double, longitude: Double, formattedAddress: [String], distance: Int, categoryName: String, icon: String, checkinsCount: Int, usersCount: Int, tipCount: Int, id: String){
        self.name = name
        self.location = (latitude, longitude, formattedAddress, distance)
        self.stats = (checkinsCount, usersCount, tipCount)
        self.id = id
        self.category = (categoryName, icon)
    }
}
