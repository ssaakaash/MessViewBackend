//
//  File.swift
//  MessViewBackend
//
//  Created by Aakaash SS on 11/07/25.
//

import Fluent
import Foundation

final class Menu: Model, @unchecked Sendable {
    static let schema = "menus"
    
    @ID(key: .id)
    var id: UUID?

    @Field(key: "date")
    var date: Date
    
    @Enum(key: "type")
    var type: MealType
    
    @Field(key: "items")
    var items: String
    
    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?
    
    @Timestamp(key: "updated_at", on: .update)
    var updatedAt: Date?

    init() { }

    init(id: UUID? = nil, date: Date, type: MealType, items: String) {
        self.id = id
        self.date = date
        self.type = type
        self.items = items
    }
    
    func toDTO() -> MenuDTO {
        .init(
            id: self.id,
            date: self.$date.value,
            type: self.$type.value,
            items: self.$items.value
        )
    }
}
