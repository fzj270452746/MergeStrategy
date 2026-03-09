//
//  TerracottaTileEntity.swift
//  MergeStrategy
//
//  Created by Assistant on 12/27/25.
//

import Foundation
import SpriteKit

/// Represents a single Mahjong tile with its value and position
struct TerracottaTileEntity: Equatable, Hashable {

    // MARK: - Properties

    /// The numeric value of the tile (1-9 for dots/circles)
    let magnitude: Int

    /// Grid position in the board
    var gridCoordinate: GridCoordinate

    /// Unique identifier for this tile instance
    let instanceIdentifier: UUID

    // MARK: - Initialization

    init(magnitude: Int, gridCoordinate: GridCoordinate) {
        self.magnitude = max(1, min(9, magnitude))
        self.gridCoordinate = gridCoordinate
        self.instanceIdentifier = UUID()
    }

    // MARK: - Computed Properties

    /// Score value for this tile based on its magnitude
    var scoreContribution: Int {
        return magnitude * 10
    }

    /// Display name for the tile
    var displayName: String {
        return "\(magnitude) Dot"
    }

    // MARK: - Equatable

    static func == (lhs: TerracottaTileEntity, rhs: TerracottaTileEntity) -> Bool {
        return lhs.instanceIdentifier == rhs.instanceIdentifier
    }

    // MARK: - Hashable

    func hash(into hasher: inout Hasher) {
        hasher.combine(instanceIdentifier)
    }

    // MARK: - Magnitude Matching

    func hasSameMagnitude(as other: TerracottaTileEntity) -> Bool {
        return self.magnitude == other.magnitude
    }
}

// MARK: - Grid Coordinate

struct GridCoordinate: Equatable, Hashable {
    let column: Int
    let row: Int

    init(_ column: Int, _ row: Int) {
        self.column = column
        self.row = row
    }

    /// Returns adjacent coordinates (up, down, left, right)
    func adjacentCoordinates() -> [GridCoordinate] {
        return [
            GridCoordinate(column, row + 1),     // Up
            GridCoordinate(column, row - 1),     // Down
            GridCoordinate(column - 1, row),     // Left
            GridCoordinate(column + 1, row)      // Right
        ]
    }

    /// Check if coordinate is within bounds
    func isWithinBounds(gridSize: Int) -> Bool {
        return column >= 0 && column < gridSize && row >= 0 && row < gridSize
    }
}
