//
//  Audit.swift
//  Inventory
//
//  Created by Aaron LaBeau on 8/29/23.
//

import Foundation

struct AuditDao: Codable {
    var item: Audit
}

struct Audit: Codable {
    var auditId: String
    var projectId: String
    var stockItem: StockItem?  // Assuming StockItem struct is already defined
    var auditCount: Int
    var notes: String
    // security tracking
    var team: String
    var createdBy: String
    var modifiedBy: String
    var createdOn: Date?
    var modifiedOn: Date?
    
    init(
        auditId: String = "",
        projectId: String = "",
        stockItem: StockItem? = nil,
        auditCount: Int = 0,
        notes: String = "",
        team: String = "",
        createdBy: String = "",
        modifiedBy: String = "",
        createdOn: Date? = nil,
        modifiedOn: Date? = nil
    ) {
        self.auditId = auditId
        self.projectId = projectId
        self.stockItem = stockItem
        self.auditCount = auditCount
        self.notes = notes
        self.team = team
        self.createdBy = createdBy
        self.modifiedBy = modifiedBy
        self.createdOn = createdOn
        self.modifiedOn = modifiedOn
    }
    
    func toJson() throws -> String {
        let encoder = JSONEncoder()
        // You can configure the encoder for date serialization
        encoder.dateEncodingStrategy = .iso8601  // Or any other format you prefer
        let data = try encoder.encode(self)
        return String(data: data, encoding: .utf8) ?? ""
    }
}

