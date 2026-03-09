//
//  PorcelainTileNode.swift
//  MergeStrategy
//
//  Created by Assistant on 12/27/25.
//

import SpriteKit

/// Visual representation of a Mahjong tile
final class PorcelainTileNode: SKNode {

    // MARK: - Properties

    let tileEntity: TerracottaTileEntity
    private let tileDimension: CGFloat

    private var backgroundPlate: SKShapeNode!
    private var shadowLayer: SKShapeNode!
    private var dotsContainer: SKNode!

    // MARK: - Initialization

    init(entity: TerracottaTileEntity, dimension: CGFloat) {
        self.tileEntity = entity
        self.tileDimension = dimension
        super.init()

        assembleTileVisuals()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Visual Assembly

    private func assembleTileVisuals() {
        let cornerRadius = tileDimension * 0.12

        // Shadow layer
        shadowLayer = SKShapeNode(rectOf: CGSize(width: tileDimension - 2, height: tileDimension - 2), cornerRadius: cornerRadius)
        shadowLayer.fillColor = SKColor.black.withAlphaComponent(0.3)
        shadowLayer.strokeColor = .clear
        shadowLayer.position = CGPoint(x: 2, y: -2)
        shadowLayer.zPosition = -1
        addChild(shadowLayer)

        // Main tile background
        backgroundPlate = SKShapeNode(rectOf: CGSize(width: tileDimension - 4, height: tileDimension - 4), cornerRadius: cornerRadius)
        backgroundPlate.fillColor = VelvetColorPalette.skIvoryTile
        backgroundPlate.strokeColor = SKColor(white: 0.85, alpha: 1.0)
        backgroundPlate.lineWidth = 1.5
        backgroundPlate.zPosition = 0

        // Add gradient effect using a child node
        let innerHighlight = SKShapeNode(rectOf: CGSize(width: tileDimension - 8, height: tileDimension - 8), cornerRadius: cornerRadius - 2)
        innerHighlight.fillColor = VelvetColorPalette.skCreamWhite
        innerHighlight.strokeColor = .clear
        innerHighlight.position = CGPoint(x: 0, y: 1)
        innerHighlight.zPosition = 0.1
        backgroundPlate.addChild(innerHighlight)

        addChild(backgroundPlate)

        // Dots container
        dotsContainer = SKNode()
        dotsContainer.zPosition = 1
        addChild(dotsContainer)

        renderDotsPattern()
    }

    // MARK: - Dot Patterns

    private func renderDotsPattern() {
        dotsContainer.removeAllChildren()

        let magnitude = tileEntity.magnitude
        let dotRadius = calculateDotRadius()
        let positions = calculateDotPositions(count: magnitude, dotRadius: dotRadius)

        for (index, position) in positions.enumerated() {
            let isCenter = (magnitude % 2 == 1) && (index == positions.count / 2)
            let dotNode = createDotNode(radius: dotRadius, isCenter: isCenter)
            dotNode.position = position
            dotsContainer.addChild(dotNode)
        }
    }

    private func calculateDotRadius() -> CGFloat {
        let magnitude = tileEntity.magnitude
        let baseSize = tileDimension * 0.12

        switch magnitude {
        case 1:
            return tileDimension * 0.22
        case 2, 3:
            return tileDimension * 0.14
        case 4, 5:
            return tileDimension * 0.11
        case 6, 7:
            return tileDimension * 0.09
        case 8, 9:
            return tileDimension * 0.08
        default:
            return baseSize
        }
    }

    private func calculateDotPositions(count: Int, dotRadius: CGFloat) -> [CGPoint] {
        // Calculate spacing based on dot radius to prevent overlap
        // Minimum spacing should be at least 2.2 * dotRadius to have gaps between dots
        let minGap = dotRadius * 2.4
        let availableSpace = tileDimension * 0.38

        switch count {
        case 1:
            return [.zero]

        case 2:
            // Diagonal arrangement
            let offset = max(availableSpace, minGap) * 0.7
            return [
                CGPoint(x: -offset, y: offset),
                CGPoint(x: offset, y: -offset)
            ]

        case 3:
            // Diagonal arrangement - spread further apart
            let offset = max(availableSpace, minGap) * 0.85
            return [
                CGPoint(x: -offset, y: offset),
                .zero,
                CGPoint(x: offset, y: -offset)
            ]

        case 4:
            // 2x2 grid
            let offset = max(availableSpace * 0.6, minGap * 0.55)
            return [
                CGPoint(x: -offset, y: offset),
                CGPoint(x: offset, y: offset),
                CGPoint(x: -offset, y: -offset),
                CGPoint(x: offset, y: -offset)
            ]

        case 5:
            // 2x2 grid with center
            let offset = max(availableSpace * 0.65, minGap * 0.6)
            return [
                CGPoint(x: -offset, y: offset),
                CGPoint(x: offset, y: offset),
                .zero,
                CGPoint(x: -offset, y: -offset),
                CGPoint(x: offset, y: -offset)
            ]

        case 6:
            // 2x3 grid
            let hOffset = max(availableSpace * 0.5, minGap * 0.5)
            let vOffset = max(availableSpace * 0.55, minGap * 0.55)
            return [
                CGPoint(x: -hOffset, y: vOffset),
                CGPoint(x: hOffset, y: vOffset),
                CGPoint(x: -hOffset, y: 0),
                CGPoint(x: hOffset, y: 0),
                CGPoint(x: -hOffset, y: -vOffset),
                CGPoint(x: hOffset, y: -vOffset)
            ]

        case 7:
            // 2x3 grid with center dot in middle row
            let hOffset = max(availableSpace * 0.5, minGap * 0.5)
            let vOffset = max(availableSpace * 0.55, minGap * 0.55)
            return [
                CGPoint(x: -hOffset, y: vOffset),
                CGPoint(x: hOffset, y: vOffset),
                CGPoint(x: -hOffset, y: 0),
                .zero,
                CGPoint(x: hOffset, y: 0),
                CGPoint(x: -hOffset, y: -vOffset),
                CGPoint(x: hOffset, y: -vOffset)
            ]

        case 8:
            // 2x4 grid
            let hOffset = max(availableSpace * 0.45, minGap * 0.45)
            let vStep = max(availableSpace * 0.36, minGap * 0.36)
            return [
                CGPoint(x: -hOffset, y: vStep * 1.5),
                CGPoint(x: hOffset, y: vStep * 1.5),
                CGPoint(x: -hOffset, y: vStep * 0.5),
                CGPoint(x: hOffset, y: vStep * 0.5),
                CGPoint(x: -hOffset, y: -vStep * 0.5),
                CGPoint(x: hOffset, y: -vStep * 0.5),
                CGPoint(x: -hOffset, y: -vStep * 1.5),
                CGPoint(x: hOffset, y: -vStep * 1.5)
            ]

        case 9:
            // 3x3 grid
            let gridOffset = max(availableSpace * 0.5, minGap * 0.5)
            return [
                CGPoint(x: -gridOffset, y: gridOffset),
                CGPoint(x: 0, y: gridOffset),
                CGPoint(x: gridOffset, y: gridOffset),
                CGPoint(x: -gridOffset, y: 0),
                .zero,
                CGPoint(x: gridOffset, y: 0),
                CGPoint(x: -gridOffset, y: -gridOffset),
                CGPoint(x: 0, y: -gridOffset),
                CGPoint(x: gridOffset, y: -gridOffset)
            ]

        default:
            return [.zero]
        }
    }

    private func createDotNode(radius: CGFloat, isCenter: Bool) -> SKNode {
        let container = SKNode()

        // Outer ring
        let outerCircle = SKShapeNode(circleOfRadius: radius)
        outerCircle.fillColor = VelvetColorPalette.skTealCircle
        outerCircle.strokeColor = SKColor(red: 0.1, green: 0.5, blue: 0.45, alpha: 1.0)
        outerCircle.lineWidth = 1
        container.addChild(outerCircle)

        // Inner circle (lighter)
        let innerRadius = radius * 0.6
        let innerCircle = SKShapeNode(circleOfRadius: innerRadius)
        innerCircle.fillColor = VelvetColorPalette.skCreamWhite
        innerCircle.strokeColor = .clear
        container.addChild(innerCircle)

        // Center dot for center position on odd-numbered tiles
        if isCenter && tileEntity.magnitude > 1 {
            let centerDot = SKShapeNode(circleOfRadius: radius * 0.25)
            centerDot.fillColor = VelvetColorPalette.skVermilionCore
            centerDot.strokeColor = .clear
            container.addChild(centerDot)
        }

        return container
    }

    // MARK: - Animations

    func playPlacementAnimation() {
        let scaleUp = SKAction.scale(to: 1.1, duration: 0.1)
        let scaleDown = SKAction.scale(to: 1.0, duration: 0.15)
        scaleDown.timingMode = .easeOut

        run(SKAction.sequence([scaleUp, scaleDown]))
    }

    func playMergeAnimation(completion: @escaping () -> Void) {
        let scaleUp = SKAction.scale(to: 1.3, duration: 0.15)
        let fadeOut = SKAction.fadeOut(withDuration: 0.2)
        let group = SKAction.group([scaleUp, fadeOut])

        run(group) {
            completion()
        }
    }

    func playUpgradeAnimation() {
        let pulseUp = SKAction.scale(to: 1.2, duration: 0.15)
        let pulseDown = SKAction.scale(to: 1.0, duration: 0.2)
        pulseDown.timingMode = .easeOut

        let flash = SKAction.sequence([
            SKAction.colorize(with: VelvetColorPalette.skAmberHighlight, colorBlendFactor: 0.5, duration: 0.1),
            SKAction.colorize(withColorBlendFactor: 0, duration: 0.2)
        ])

        run(SKAction.group([SKAction.sequence([pulseUp, pulseDown]), flash]))
    }

    func playSelectionHighlight() {
        let pulseUp = SKAction.scale(to: 1.08, duration: 0.3)
        let pulseDown = SKAction.scale(to: 1.0, duration: 0.3)
        let pulse = SKAction.sequence([pulseUp, pulseDown])

        run(SKAction.repeatForever(pulse), withKey: "selectionPulse")
    }

    func removeSelectionHighlight() {
        removeAction(forKey: "selectionPulse")
        run(SKAction.scale(to: 1.0, duration: 0.1))
    }
}
