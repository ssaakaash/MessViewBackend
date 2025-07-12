//
//  File.swift
//  MessViewBackend
//
//  Created by Aakaash SS on 11/07/25.
//

import Foundation
import Fluent
import Vapor

struct MenuController: RouteCollection {
    func boot(routes: any RoutesBuilder) throws {
        let menus = routes.grouped("menus")

        menus.group(":date") { date in
            date.get(use: self.index)
        }
        menus.post(use: self.create)
        menus.group(":menuID") { menu in
            menu.delete(use: self.delete)
            menu.patch(use: self.update)
        }
    }

    @Sendable
    func index(req: Request) async throws -> [MenuDTO] {
        guard let date = readDate(for: req.parameters.get("date")!) else {
            throw Abort(.badRequest, reason: "Could not parse date: use YYYY-MM-DD format")
        }
        
        let bounds = dayBounds(for: date)
        let items = try await Menu.query(on: req.db)
            .filter(\.$date >= bounds.start)
            .filter((\.$date < bounds.end))
            .all()
        return items.map { item in
            item.toDTO()
        }
    }

    @Sendable
    func create(req: Request) async throws -> MenuDTO {
        try MenuDTO.validate(content: req)
        let menu = try req.content.decode(MenuDTO.self).toModel()
        
        let bounds = dayBounds(for: menu.date)
        // Check for existing menu
        let existingMenu = try await Menu.query(on: req.db)
            .filter(\.$date >= bounds.start)
            .filter(\.$date < bounds.end)
            .filter(\.$type == menu.type)
            .first()
        if existingMenu != nil {
            throw Abort(.conflict, reason: "Menu with the same date and type already exists.")
        }
        
        try await menu.save(on: req.db)
        return try await Menu.find(menu.id, on: req.db)!.toDTO()
    }

    @Sendable
    func delete(req: Request) async throws -> HTTPStatus {
        guard let menu = try await Menu.find(req.parameters.get("menuID"), on: req.db) else {
            throw Abort(.notFound)
        }

        try await menu.delete(on: req.db)
        return .noContent
    }
    
    @Sendable
    func update(req: Request) async throws -> MenuDTO {
        let updatedMenu = try req.content.decode(MenuDTO.self)
        
        guard let menu = try await Menu.find(req.parameters.get("menuID"), on: req.db) else {
            throw Abort(.notFound)
        }
        guard let items = updatedMenu.items else {
            throw Abort(.badRequest, reason: "Items cannot be empty")
        }

        menu.items = items
        try await menu.update(on: req.db)
        return menu.toDTO()
    }
}

// Find the start and end of the day
private func dayBounds(for date: Date, calendar: Calendar = .current) -> (start: Date, end: Date) {
    let startOfDay = calendar.startOfDay(for: date)
    let nextDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) ?? startOfDay
    return (start: startOfDay, end: nextDay)
}

// Read date
private func readDate(for date: String) -> Date? {
    try? Date(date, strategy: .iso8601.year().month().day())
}
