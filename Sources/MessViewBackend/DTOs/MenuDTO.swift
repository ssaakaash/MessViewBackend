//
//  File.swift
//  MessViewBackend
//
//  Created by Aakaash SS on 11/07/25.
//

import Fluent
import Vapor
import Foundation

struct MenuDTO: Content {
    var id: UUID?
    var date: Date?
    var type: MealType?
    var items: String?
    
    func toModel() -> Menu {
        let menu = Menu()
        
        menu.id = self.id
        if let date = self.date {
            menu.date = date
        }
        if let type = self.type {
            menu.type = type
        }
        if let items = self.items {
            menu.items = items
        }
        return menu
    }
}

extension MenuDTO: Validatable {
    static func validations(_ validations: inout Vapor.Validations) {
        validations.add("type", as: String.self, is: .in("breakfast", "lunch", "snacks", "dinner"))
    }
}
