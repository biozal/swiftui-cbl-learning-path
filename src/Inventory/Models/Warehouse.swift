//
//  Warehouse.swift
//  Inventory
//
//  Created by Aaron LaBeau on 8/29/23.

import Foundation

// To ensure that properties' names align with JSON keys when encoding and decoding
struct WarehouseDao: Codable {
    var item: Warehouse
}

struct Warehouse: Codable {
    let warehouseId: String
    let name: String
    let address1: String
    let address2: String?
    let city: String
    let state: String
    let postalCode: String
    let salesTax: Double
    let yearToDateBalance: Double
    let latitude: Double
    let longitude: Double
    let shippingTo: [String]?

    init(
        warehouseId: String,
        name: String,
        address1: String,
        address2: String? = "",
        city: String,
        state: String,
        postalCode: String,
        salesTax: Double,
        yearToDateBalance: Double,
        latitude: Double,
        longitude: Double,
        shippingTo: [String]? = nil
    ) {
        self.warehouseId = warehouseId
        self.name = name
        self.address1 = address1
        self.address2 = address2
        self.city = city
        self.state = state
        self.postalCode = postalCode
        self.salesTax = salesTax
        self.yearToDateBalance = yearToDateBalance
        self.latitude = latitude
        self.longitude = longitude
        self.shippingTo = shippingTo
    }
}
