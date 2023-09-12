//
//  Location.swift
//  Inventory
//
//  Created by Aaron LaBeau on 8/29/23.
//

import Foundation

struct LocationDao: Codable {
    var item: Location
}

struct Location: Codable {
    let locationId: String
    let name: String
    let address1: String
    let address2: String?
    let city: String
    let state: String?
    let country: String
    let postalCode: String
    let latitude: Double
    let longitude: Double

    init(
        locationId: String,
        name: String,
        address1: String,
        address2: String? = "",
        city: String,
        state: String? = "",
        country: String,
        postalCode: String,
        latitude: Double,
        longitude: Double
    ) {
        self.locationId = locationId
        self.name = name
        self.address1 = address1
        self.address2 = address2
        self.city = city
        self.state = state
        self.country = country
        self.postalCode = postalCode
        self.latitude = latitude
        self.longitude = longitude
    }
}
