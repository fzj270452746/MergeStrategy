//
//  ObsidianBoardState.swift
//  MergeStrategy
//
//  Created by Assistant on 12/27/25.
//

import Foundation

/// Represents the current state of the game board
final class ObsidianBoardState {

    // MARK: - Properties

    /// Grid size (N x N)
    let dimension: Int

    /// Maximum tile value that triggers elimination
    let eliminationThreshold: Int

    /// 2D array storing tiles (nil = empty cell)
    private(set) var cellMatrix: [[TerracottaTileEntity?]]

    /// Current score
    private(set) var accumulatedScore: Int = 0

    /// Current combo count
    private(set) var cascadeMultiplier: Int = 0

    /// Total merges this game
    private(set) var mergesExecuted: Int = 0

    // MARK: - Initialization

    init(dimension: Int = 5, eliminationThreshold: Int = 4) {
        self.dimension = dimension
        self.eliminationThreshold = eliminationThreshold
        self.cellMatrix = Array(repeating: Array(repeating: nil, count: dimension), count: dimension)
    }

    // MARK: - Board Queries

    /// Check if a cell is empty
    func isCellVacant(at coordinate: GridCoordinate) -> Bool {
        guard coordinate.isWithinBounds(gridSize: dimension) else { return false }
        return cellMatrix[coordinate.column][coordinate.row] == nil
    }

    /// Get tile at coordinate
    func retrieveTile(at coordinate: GridCoordinate) -> TerracottaTileEntity? {
        guard coordinate.isWithinBounds(gridSize: dimension) else { return nil }
        return cellMatrix[coordinate.column][coordinate.row]
    }

    /// Count empty cells
    func vacantCellCount() -> Int {
        var count = 0
        for column in cellMatrix {
            for cell in column {
                if cell == nil { count += 1 }
            }
        }
        return count
    }

    /// Check if board is full
    func isBoardSaturated() -> Bool {
        return vacantCellCount() == 0
    }

    /// Get all vacant coordinates
    func allVacantCoordinates() -> [GridCoordinate] {
        var coordinates: [GridCoordinate] = []
        for col in 0..<dimension {
            for row in 0..<dimension {
                let coord = GridCoordinate(col, row)
                if isCellVacant(at: coord) {
                    coordinates.append(coord)
                }
            }
        }
        return coordinates
    }

    // MARK: - Board Mutations

    /// Place a tile on the board
    @discardableResult
    func depositTile(_ tile: TerracottaTileEntity) -> Bool {
        guard isCellVacant(at: tile.gridCoordinate) else { return false }
        cellMatrix[tile.gridCoordinate.column][tile.gridCoordinate.row] = tile
        return true
    }

    /// Remove a tile from the board
    func extractTile(at coordinate: GridCoordinate) -> TerracottaTileEntity? {
        guard coordinate.isWithinBounds(gridSize: dimension) else { return nil }
        let tile = cellMatrix[coordinate.column][coordinate.row]
        cellMatrix[coordinate.column][coordinate.row] = nil
        return tile
    }

    /// Clear all tiles
    func purgeAllTiles() {
        cellMatrix = Array(repeating: Array(repeating: nil, count: dimension), count: dimension)
        accumulatedScore = 0
        cascadeMultiplier = 0
        mergesExecuted = 0
    }

    // MARK: - Merge Detection

    /// Find all connected tiles of same magnitude starting from coordinate
    func discoverConnectedCluster(from origin: GridCoordinate) -> Set<GridCoordinate> {
        guard let originTile = retrieveTile(at: origin) else { return [] }

        var visitedCells = Set<GridCoordinate>()
        var clusterMembers = Set<GridCoordinate>()
        var explorationQueue = [origin]

        while !explorationQueue.isEmpty {
            let current = explorationQueue.removeFirst()

            guard !visitedCells.contains(current) else { continue }
            visitedCells.insert(current)

            guard let currentTile = retrieveTile(at: current),
                  currentTile.hasSameMagnitude(as: originTile) else { continue }

            clusterMembers.insert(current)

            for adjacent in current.adjacentCoordinates() {
                if adjacent.isWithinBounds(gridSize: dimension) && !visitedCells.contains(adjacent) {
                    explorationQueue.append(adjacent)
                }
            }
        }

        return clusterMembers
    }

    /// Check if a merge is possible from the given coordinate
    func canInitiateMerge(from coordinate: GridCoordinate) -> Bool {
        let cluster = discoverConnectedCluster(from: coordinate)
        return cluster.count >= 3
    }

    // MARK: - Merge Execution

    /// Execute merge and return result
    func executeMerge(from coordinate: GridCoordinate) -> MergeOutcome? {
        let cluster = discoverConnectedCluster(from: coordinate)

        guard cluster.count >= 3,
              let primaryTile = retrieveTile(at: coordinate) else { return nil }

        let tileMagnitude = primaryTile.magnitude
        let clusterSize = cluster.count

        // Calculate score
        let basePoints = tileMagnitude * 10 * clusterSize
        let comboBonus = cascadeMultiplier * 50
        let totalPoints = basePoints + comboBonus

        // Remove all tiles in cluster
        var removedCoordinates: [GridCoordinate] = []
        for coord in cluster {
            _ = extractTile(at: coord)
            removedCoordinates.append(coord)
        }

        // Determine if we create an upgraded tile or just clear
        var upgradedTile: TerracottaTileEntity? = nil

        if tileMagnitude < eliminationThreshold {
            // Create upgraded tile at original position
            let newMagnitude = tileMagnitude + 1
            let newTile = TerracottaTileEntity(magnitude: newMagnitude, gridCoordinate: coordinate)
            depositTile(newTile)
            upgradedTile = newTile
        }
        // If magnitude >= eliminationThreshold, tiles are just cleared (no upgrade)

        // Update state
        accumulatedScore += totalPoints
        mergesExecuted += 1
        cascadeMultiplier += 1

        return MergeOutcome(
            originCoordinate: coordinate,
            dissolvedCoordinates: removedCoordinates,
            ascendedTile: upgradedTile,
            pointsAwarded: totalPoints,
            cascadeLevel: cascadeMultiplier,
            priorMagnitude: tileMagnitude
        )
    }

    /// Reset combo counter
    func resetCascadeMultiplier() {
        cascadeMultiplier = 0
    }

    // MARK: - Score Management

    func appendScore(_ points: Int) {
        accumulatedScore += points
    }
}

// MARK: - Merge Outcome

struct MergeOutcome {
    let originCoordinate: GridCoordinate
    let dissolvedCoordinates: [GridCoordinate]
    let ascendedTile: TerracottaTileEntity?
    let pointsAwarded: Int
    let cascadeLevel: Int
    let priorMagnitude: Int

    var wasElimination: Bool {
        return ascendedTile == nil
    }

    var clusterSize: Int {
        return dissolvedCoordinates.count
    }
}
