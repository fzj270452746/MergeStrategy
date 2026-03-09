//
//  QuartzGameSession.swift
//  MergeStrategy
//
//  Created by Assistant on 12/27/25.
//

import Foundation

/// Manages the overall game session and logic
final class QuartzGameSession {

    // MARK: - Properties

    /// The game board
    let boardState: ObsidianBoardState

    /// Current tile waiting to be placed
    private(set) var pendingTile: TerracottaTileEntity?

    /// Maximum tile value that can be generated
    let generationCeiling: Int

    /// Game state
    private(set) var sessionPhase: SessionPhase = .awaiting

    /// Delegate for game events
    weak var eventDispatcher: QuartzSessionDelegate?

    // MARK: - Initialization

    init(gridDimension: Int = 5, eliminationThreshold: Int = 4) {
        self.generationCeiling = eliminationThreshold
        self.boardState = ObsidianBoardState(dimension: gridDimension, eliminationThreshold: eliminationThreshold)
    }

    // MARK: - Game Flow

    /// Start a new game
    func commenceSession() {
        boardState.purgeAllTiles()
        sessionPhase = .active
        generatePendingTile()
        eventDispatcher?.sessionDidCommence(self)
    }

    /// End the current game
    func terminateSession() {
        sessionPhase = .concluded
        NebulaPersistence.shared.incrementSessionCount()
        let isNewRecord = NebulaPersistence.shared.updatePinnacleIfNeeded(boardState.accumulatedScore)
        NebulaPersistence.shared.incrementMergeCount(by: boardState.mergesExecuted)
        eventDispatcher?.sessionDidConclude(self, isNewHighScore: isNewRecord)
    }

    // MARK: - Tile Generation

    /// Generate the next tile to be placed
    func generatePendingTile() {
        guard sessionPhase == .active else { return }

        // Weighted random generation - lower values more common
        let weights = calculateGenerationWeights()
        let magnitude = selectWeightedMagnitude(weights: weights)

        // Create tile with temporary position (will be set on placement)
        pendingTile = TerracottaTileEntity(magnitude: magnitude, gridCoordinate: GridCoordinate(-1, -1))
        eventDispatcher?.sessionDidGenerateTile(self, tile: pendingTile!)
    }

    private func calculateGenerationWeights() -> [Int: Double] {
        var weights: [Int: Double] = [:]
        // Generate tiles from 1 to (generationCeiling - 1)
        // Target value tiles can only be created through merging
        let maxGeneratedValue = generationCeiling - 1
        for i in 1...maxGeneratedValue {
            // Lower values have higher weights
            weights[i] = Double(maxGeneratedValue - i + 1) * 1.5
        }
        return weights
    }

    private func selectWeightedMagnitude(weights: [Int: Double]) -> Int {
        let totalWeight = weights.values.reduce(0, +)
        var randomValue = Double.random(in: 0..<totalWeight)

        for (magnitude, weight) in weights.sorted(by: { $0.key < $1.key }) {
            randomValue -= weight
            if randomValue <= 0 {
                return magnitude
            }
        }

        return 1
    }

    // MARK: - Tile Placement

    /// Attempt to place the pending tile at the given coordinate
    func attemptPlacement(at coordinate: GridCoordinate) -> PlacementResult {
        guard sessionPhase == .active else {
            return .rejected(reason: .sessionInactive)
        }

        guard var tile = pendingTile else {
            return .rejected(reason: .noTilePending)
        }

        guard boardState.isCellVacant(at: coordinate) else {
            return .rejected(reason: .cellOccupied)
        }

        // Update tile position and place
        tile.gridCoordinate = coordinate
        boardState.depositTile(tile)
        pendingTile = nil

        // Reset combo before checking merges
        boardState.resetCascadeMultiplier()

        // Check for merges
        let mergeResults = processAllMerges(startingFrom: coordinate)

        // Check for game over
        if boardState.isBoardSaturated() {
            terminateSession()
            return .accepted(merges: mergeResults, gameEnded: true)
        }

        // Generate next tile
        generatePendingTile()

        return .accepted(merges: mergeResults, gameEnded: false)
    }

    // MARK: - Merge Processing

    /// Process all merges starting from placed tile (handles chains)
    private func processAllMerges(startingFrom origin: GridCoordinate) -> [MergeOutcome] {
        var allOutcomes: [MergeOutcome] = []
        var coordinatesToCheck = [origin]

        while !coordinatesToCheck.isEmpty {
            let currentCoord = coordinatesToCheck.removeFirst()

            guard boardState.canInitiateMerge(from: currentCoord),
                  let outcome = boardState.executeMerge(from: currentCoord) else {
                continue
            }

            allOutcomes.append(outcome)
            eventDispatcher?.sessionDidExecuteMerge(self, outcome: outcome)

            // If an upgraded tile was created, check if it can merge
            if let upgradedTile = outcome.ascendedTile {
                coordinatesToCheck.append(upgradedTile.gridCoordinate)
            }
        }

        return allOutcomes
    }

    // MARK: - Queries

    var currentScore: Int {
        return boardState.accumulatedScore
    }

    var highestTileValue: Int {
        var highest = 0
        for col in 0..<boardState.dimension {
            for row in 0..<boardState.dimension {
                if let tile = boardState.retrieveTile(at: GridCoordinate(col, row)) {
                    highest = max(highest, tile.magnitude)
                }
            }
        }
        return highest
    }

    var emptySpacesRemaining: Int {
        return boardState.vacantCellCount()
    }
}

// MARK: - Session Phase

enum SessionPhase {
    case awaiting
    case active
    case concluded
}

// MARK: - Placement Result

enum PlacementResult {
    case accepted(merges: [MergeOutcome], gameEnded: Bool)
    case rejected(reason: PlacementRejection)
}

enum PlacementRejection {
    case sessionInactive
    case noTilePending
    case cellOccupied
}

// MARK: - Session Delegate

protocol QuartzSessionDelegate: AnyObject {
    func sessionDidCommence(_ session: QuartzGameSession)
    func sessionDidGenerateTile(_ session: QuartzGameSession, tile: TerracottaTileEntity)
    func sessionDidExecuteMerge(_ session: QuartzGameSession, outcome: MergeOutcome)
    func sessionDidConclude(_ session: QuartzGameSession, isNewHighScore: Bool)
}
