//
//  CrystalLayoutMetrics.swift
//  MergeStrategy
//
//  Created by Assistant on 12/27/25.
//

import UIKit
import SpriteKit

/// Layout metrics calculator for responsive design across devices
struct CrystalLayoutMetrics {

    // MARK: - Actual View Size (for iPad compatibility mode)

    /// Get the actual view bounds from the key window
    /// In iPad compatibility mode, UIScreen.main.bounds returns iPad size,
    /// but the actual view is smaller (iPhone-sized window)
    static var actualViewBounds: CGRect {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            return window.bounds
        }
        return UIScreen.main.bounds
    }

    // MARK: - Screen Properties

    static var portalBounds: CGRect {
        actualViewBounds
    }

    static var portalWidth: CGFloat {
        portalBounds.width
    }

    static var portalHeight: CGFloat {
        portalBounds.height
    }

    static var isCompactCanvas: Bool {
        portalWidth < 375
    }

    static var isExpandedCanvas: Bool {
        portalWidth >= 768
    }

    // MARK: - Safe Area

    static var safeAreaInsets: UIEdgeInsets {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else {
            return UIEdgeInsets(top: 44, left: 0, bottom: 34, right: 0)
        }
        return window.safeAreaInsets
    }

    // MARK: - Board Metrics

    /// Calculate tile dimension based on actual scene size (not screen size)
    static func calculateTileDimension(forGridSize gridSize: Int, sceneWidth: CGFloat? = nil) -> CGFloat {
        let width = sceneWidth ?? portalWidth
        let availableWidth = width - 40 // 20pt padding each side
        let spacing: CGFloat = 6
        let totalSpacing = spacing * CGFloat(gridSize - 1)
        let tileSize = (availableWidth - totalSpacing) / CGFloat(gridSize)
        return min(tileSize, 72) // Cap at 72pt for larger screens
    }

    static func calculateBoardOrigin(forGridSize gridSize: Int, tileSize: CGFloat, sceneSize: CGSize) -> CGPoint {
        let spacing: CGFloat = 6
        let boardWidth = CGFloat(gridSize) * tileSize + CGFloat(gridSize - 1) * spacing
        let boardHeight = boardWidth

        let xOrigin = (sceneSize.width - boardWidth) / 2 + tileSize / 2
        let yOrigin = sceneSize.height * 0.35 - boardHeight / 2 + tileSize / 2

        return CGPoint(x: xOrigin, y: yOrigin)
    }

    // MARK: - UI Element Sizes

    static var orchidButtonHeight: CGFloat {
        isCompactCanvas ? 50 : 56
    }

    static var petalButtonCornerRadius: CGFloat {
        orchidButtonHeight / 2
    }

    static var titleFontMagnitude: CGFloat {
        isCompactCanvas ? 32 : 42
    }

    static var headingFontMagnitude: CGFloat {
        isCompactCanvas ? 22 : 28
    }

    static var bodyFontMagnitude: CGFloat {
        isCompactCanvas ? 15 : 17
    }

    static var captionFontMagnitude: CGFloat {
        isCompactCanvas ? 12 : 14
    }

    // MARK: - Spacing

    static var sectionGap: CGFloat {
        isCompactCanvas ? 16 : 24
    }

    static var elementGap: CGFloat {
        isCompactCanvas ? 8 : 12
    }

    static var tileSpacing: CGFloat {
        6
    }

    // MARK: - Animation Durations

    static let quickTransition: TimeInterval = 0.2
    static let standardTransition: TimeInterval = 0.35
    static let elaborateTransition: TimeInterval = 0.5
    static let mergeAnimationDuration: TimeInterval = 0.4
    static let chainDelayInterval: TimeInterval = 0.25
}
