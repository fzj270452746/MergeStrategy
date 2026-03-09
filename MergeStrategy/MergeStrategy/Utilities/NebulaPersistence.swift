//
//  NebulaPersistence.swift
//  MergeStrategy
//
//  Created by Assistant on 12/27/25.
//

import Foundation

/// Persistence manager for game data using UserDefaults
final class NebulaPersistence {

    // MARK: - Singleton

    static let shared = NebulaPersistence()

    // MARK: - Keys

    private enum StorageKey: String {
        case pinnacleScore = "nebula_pinnacle_score"
        case totalMerges = "nebula_total_merges"
        case totalGamesPlayed = "nebula_games_played"
        case soundEnabled = "nebula_sound_enabled"
        case hapticEnabled = "nebula_haptic_enabled"
        case lastSelectedDifficulty = "nebula_difficulty"
    }

    // MARK: - Properties

    private let defaults = UserDefaults.standard

    // MARK: - Initialization

    private init() {
        registerDefaults()
    }

    private func registerDefaults() {
        defaults.register(defaults: [
            StorageKey.pinnacleScore.rawValue: 0,
            StorageKey.totalMerges.rawValue: 0,
            StorageKey.totalGamesPlayed.rawValue: 0,
            StorageKey.soundEnabled.rawValue: true,
            StorageKey.hapticEnabled.rawValue: true,
            StorageKey.lastSelectedDifficulty.rawValue: 4
        ])
    }

    // MARK: - High Score

    var pinnacleScore: Int {
        get { defaults.integer(forKey: StorageKey.pinnacleScore.rawValue) }
        set { defaults.set(newValue, forKey: StorageKey.pinnacleScore.rawValue) }
    }

    func updatePinnacleIfNeeded(_ score: Int) -> Bool {
        if score > pinnacleScore {
            pinnacleScore = score
            return true
        }
        return false
    }

    // MARK: - Statistics

    var cumulativeMerges: Int {
        get { defaults.integer(forKey: StorageKey.totalMerges.rawValue) }
        set { defaults.set(newValue, forKey: StorageKey.totalMerges.rawValue) }
    }

    var sessionsCompleted: Int {
        get { defaults.integer(forKey: StorageKey.totalGamesPlayed.rawValue) }
        set { defaults.set(newValue, forKey: StorageKey.totalGamesPlayed.rawValue) }
    }

    func incrementMergeCount(by amount: Int = 1) {
        cumulativeMerges += amount
    }

    func incrementSessionCount() {
        sessionsCompleted += 1
    }

    // MARK: - Settings

    var melodiesEnabled: Bool {
        get { defaults.bool(forKey: StorageKey.soundEnabled.rawValue) }
        set { defaults.set(newValue, forKey: StorageKey.soundEnabled.rawValue) }
    }

    var vibrationsEnabled: Bool {
        get { defaults.bool(forKey: StorageKey.hapticEnabled.rawValue) }
        set { defaults.set(newValue, forKey: StorageKey.hapticEnabled.rawValue) }
    }

    var lastChosenThreshold: Int {
        get { defaults.integer(forKey: StorageKey.lastSelectedDifficulty.rawValue) }
        set { defaults.set(newValue, forKey: StorageKey.lastSelectedDifficulty.rawValue) }
    }

    // MARK: - Reset

    func purgeAllRecords() {
        let keys = [
            StorageKey.pinnacleScore,
            StorageKey.totalMerges,
            StorageKey.totalGamesPlayed
        ]
        keys.forEach { defaults.removeObject(forKey: $0.rawValue) }
    }
}
