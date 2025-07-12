//
//  File.swift
//  MessViewBackend
//
//  Created by Aakaash SS on 11/07/25.
//

import Foundation
import Fluent

struct CreateMenu: AsyncMigration {
    func prepare(on database: any Database) async throws {
        
        let mealType = try await database.enum("meal_type")
            .case("breakfast")
            .case("lunch")
            .case("snacks")
            .case("dinner")
            .create()
        
        try await database.schema("menus")
            .id()
            .field("date", .date, .required)
            .field("type", mealType, .required)
            .field("items", .string, .required)
            .field("created_at", .date, .required)
            .field("updated_at", .date)
            .create()
    }

    func revert(on database: any Database) async throws {
        try await database.schema("menus").delete()
        try await database.enum("meal_type").delete()
    }
}
