//
//  StockItem.swift
//  Inventory
//
//  Created by Aaron LaBeau on 8/29/23.
//

import Foundation

struct StockItemDao: Codable {
    var item: StockItem
}

struct StockItem: Codable {
    var itemId: String
    var name: String
    var price: Float
    var description: String
    var style: String

    init(
        itemId: String = "",
        name: String = "",
        price: Float,
        description: String = "",
        style: String = ""
    ) {
        self.itemId = itemId
        self.name = name
        self.price = price
        self.description = description
        self.style = style
    }
    
    func toJson() throws -> String {
        let encoder = JSONEncoder()
        let data = try encoder.encode(self)
        return String(data: data, encoding: .utf8) ?? ""
    }
}
