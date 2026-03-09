//
//  VelvetColorPalette.swift
//  MergeStrategy
//
//  Created by Assistant on 12/27/25.
//

import UIKit
import SpriteKit

/// Harmonious color palette for the Mahjong merge game
struct VelvetColorPalette {

    // MARK: - Primary Colors

    /// Deep jade green - primary accent
    static let jadePrimary = UIColor(red: 0.18, green: 0.55, blue: 0.45, alpha: 1.0)

    /// Rich burgundy - secondary accent
    static let burgundyAccent = UIColor(red: 0.55, green: 0.15, blue: 0.22, alpha: 1.0)

    /// Golden amber - highlights and scores
    static let amberHighlight = UIColor(red: 0.92, green: 0.75, blue: 0.30, alpha: 1.0)

    // MARK: - Background Colors

    /// Deep navy backdrop
    static let obsidianBackdrop = UIColor(red: 0.08, green: 0.10, blue: 0.18, alpha: 1.0)

    /// Slightly lighter panel background
    static let slatePanel = UIColor(red: 0.12, green: 0.15, blue: 0.25, alpha: 1.0)

    /// Card/tile background
    static let ivoryTile = UIColor(red: 0.96, green: 0.94, blue: 0.88, alpha: 1.0)

    /// Cream white for tile faces
    static let creamWhite = UIColor(red: 0.98, green: 0.96, blue: 0.92, alpha: 1.0)

    // MARK: - Tile Circle Colors (Mahjong Dots)

    /// Teal circle color for mahjong dots
    static let tealCircle = UIColor(red: 0.15, green: 0.65, blue: 0.60, alpha: 1.0)

    /// Deep red for center dot
    static let vermilionCore = UIColor(red: 0.78, green: 0.22, blue: 0.18, alpha: 1.0)

    // MARK: - UI Colors

    /// Button gradient start
    static let emeraldGlow = UIColor(red: 0.22, green: 0.70, blue: 0.55, alpha: 1.0)

    /// Button gradient end
    static let forestDepth = UIColor(red: 0.12, green: 0.45, blue: 0.38, alpha: 1.0)

    /// Warning/alert color
    static let coralAlert = UIColor(red: 0.90, green: 0.40, blue: 0.35, alpha: 1.0)

    /// Success color
    static let mintSuccess = UIColor(red: 0.35, green: 0.80, blue: 0.55, alpha: 1.0)

    /// Disabled/inactive state
    static let fogInactive = UIColor(red: 0.45, green: 0.48, blue: 0.55, alpha: 1.0)

    // MARK: - Text Colors

    /// Primary text on dark backgrounds
    static let pearlText = UIColor(red: 0.95, green: 0.93, blue: 0.90, alpha: 1.0)

    /// Secondary/subtitle text
    static let silverSubtext = UIColor(red: 0.70, green: 0.72, blue: 0.78, alpha: 1.0)

    /// Text on light backgrounds
    static let inkText = UIColor(red: 0.15, green: 0.15, blue: 0.20, alpha: 1.0)

    // MARK: - Gradient Definitions

    static var obsidianGradientColors: [CGColor] {
        [
            UIColor(red: 0.06, green: 0.08, blue: 0.14, alpha: 1.0).cgColor,
            UIColor(red: 0.12, green: 0.15, blue: 0.25, alpha: 1.0).cgColor
        ]
    }

    static var jadeButtonGradientColors: [CGColor] {
        [emeraldGlow.cgColor, forestDepth.cgColor]
    }

    static var amberGradientColors: [CGColor] {
        [
            UIColor(red: 0.95, green: 0.80, blue: 0.35, alpha: 1.0).cgColor,
            UIColor(red: 0.85, green: 0.65, blue: 0.25, alpha: 1.0).cgColor
        ]
    }

    // MARK: - SKColor Conversions (SKColor is UIColor on iOS)

    static var skJadePrimary: SKColor { jadePrimary }
    static var skBurgundyAccent: SKColor { burgundyAccent }
    static var skAmberHighlight: SKColor { amberHighlight }
    static var skObsidianBackdrop: SKColor { obsidianBackdrop }
    static var skSlatePanel: SKColor { slatePanel }
    static var skIvoryTile: SKColor { ivoryTile }
    static var skCreamWhite: SKColor { creamWhite }
    static var skTealCircle: SKColor { tealCircle }
    static var skVermilionCore: SKColor { vermilionCore }
    static var skPearlText: SKColor { pearlText }
    static var skInkText: SKColor { inkText }
    static var skCoralAlert: SKColor { coralAlert }
    static var skMintSuccess: SKColor { mintSuccess }
}
