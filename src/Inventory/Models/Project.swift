//
//  Project.swift
//  Inventory
//
//  Created by Aaron LaBeau on 8/29/23.
//

import Foundation

struct ProjectDao: Codable {
    var item: Project
}

struct Project: Codable {
    var projectId: String
    var name: String
    var description: String
    var isComplete: Bool
    var dueDate: Date?
    var warehouse: Warehouse?
    var team: String
    var createdBy: String
    var modifiedBy: String
    var createdOn: Date?
    var modifiedOn: Date?

    init(
        projectId: String = "",
        name: String = "",
        description: String = "",
        isComplete: Bool = false,
        dueDate: Date? = nil,
        warehouse: Warehouse? = nil,
        team: String = "",
        createdBy: String = "",
        modifiedBy: String = "",
        createdOn: Date? = nil,
        modifiedOn: Date? = nil
    ) {
        self.projectId = projectId
        self.name = name
        self.description = description
        self.isComplete = isComplete
        self.dueDate = dueDate
        self.warehouse = warehouse
        self.team = team
        self.createdBy = createdBy
        self.modifiedBy = modifiedBy
        self.createdOn = createdOn
        self.modifiedOn = modifiedOn
    }
    
    func isOverDue() -> Bool {
        guard let dueDate = self.dueDate else {
            return false
        }
        return Date() > dueDate
    }

    func getDueDateString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yyyy"
        if let dueDate = self.dueDate {
            return formatter.string(from: dueDate)
        }
        return ""
    }

    func toJson() throws -> String {
        let encoder = JSONEncoder()
        // You can also configure the encoder for date serialization
        encoder.dateEncodingStrategy = .iso8601 // Or any other format you prefer
        let data = try encoder.encode(self)
        return String(data: data, encoding: .utf8) ?? ""
    }
}

