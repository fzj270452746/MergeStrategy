//
//  AmethystGameScene.swift
//  MergeStrategy
//
//  Created by Assistant on 12/27/25.
//

import SpriteKit

/// Main gameplay scene
final class AmethystGameScene: SKScene {

    // MARK: - Properties

    var eliminationThreshold: Int = 4

    private var gameSession: QuartzGameSession!
    private var boardNode: MalachiteBoardNode!

    private var scoreLabel: SKLabelNode!
    private var highScoreLabel: SKLabelNode!
    private var nextTilePreview: PorcelainTileNode?
    private var nextTileContainer: SKNode!
    private var comboLabel: SKLabelNode!

    private var pauseButton: AzureButtonNode!
    private var isSessionSuspended: Bool = false

    private let gridDimension: Int = 5

    // MARK: - Lifecycle

    override func didMove(to view: SKView) {
        setupBackground()
        setupHeader()
        setupBoard()
        setupNextTileArea()
        setupComboDisplay()

        initializeGameSession()
    }

    // MARK: - Background Setup

    private func setupBackground() {
        backgroundColor = VelvetColorPalette.skObsidianBackdrop

        // Background image
        let bgImage = SKSpriteNode(imageNamed: "m-game-back")
        bgImage.position = CGPoint(x: size.width / 2, y: size.height / 2)
        bgImage.zPosition = -20
        let scaleX = size.width / bgImage.size.width
        let scaleY = size.height / bgImage.size.height
        let bgScale = max(scaleX, scaleY)
        bgImage.setScale(bgScale)
        addChild(bgImage)

        // Subtle gradient overlay
        let gradientNode = SKShapeNode(rectOf: size)
        gradientNode.fillColor = VelvetColorPalette.skSlatePanel.withAlphaComponent(0.2)
        gradientNode.strokeColor = .clear
        gradientNode.position = CGPoint(x: size.width / 2, y: size.height / 2)
        gradientNode.zPosition = -10
        addChild(gradientNode)

        // Decorative corners
        createCornerDecorations()
    }

    private func createCornerDecorations() {
        let cornerSize: CGFloat = 60
        let cornerPositions = [
            CGPoint(x: 20, y: size.height - 20),
            CGPoint(x: size.width - 20, y: size.height - 20),
            CGPoint(x: 20, y: 20),
            CGPoint(x: size.width - 20, y: 20)
        ]

        for (index, position) in cornerPositions.enumerated() {
            let corner = SKShapeNode()
            let path = CGMutablePath()

            switch index {
            case 0: // Top-left
                path.move(to: CGPoint(x: 0, y: -cornerSize))
                path.addLine(to: CGPoint(x: 0, y: 0))
                path.addLine(to: CGPoint(x: cornerSize, y: 0))
            case 1: // Top-right
                path.move(to: CGPoint(x: 0, y: 0))
                path.addLine(to: CGPoint(x: -cornerSize, y: 0))
                path.move(to: CGPoint(x: 0, y: 0))
                path.addLine(to: CGPoint(x: 0, y: -cornerSize))
            case 2: // Bottom-left
                path.move(to: CGPoint(x: 0, y: cornerSize))
                path.addLine(to: CGPoint(x: 0, y: 0))
                path.addLine(to: CGPoint(x: cornerSize, y: 0))
            case 3: // Bottom-right
                path.move(to: CGPoint(x: -cornerSize, y: 0))
                path.addLine(to: CGPoint(x: 0, y: 0))
                path.addLine(to: CGPoint(x: 0, y: cornerSize))
            default:
                break
            }

            corner.path = path
            corner.strokeColor = VelvetColorPalette.skJadePrimary.withAlphaComponent(0.3)
            corner.lineWidth = 2
            corner.position = position
            corner.zPosition = -5
            addChild(corner)
        }
    }

    // MARK: - Header Setup

    private func setupHeader() {
        let headerY = size.height - CrystalLayoutMetrics.safeAreaInsets.top - 50

        // Header backdrop for readability
        let headerBg = SKShapeNode(rectOf: CGSize(width: size.width, height: 100), cornerRadius: 0)
        headerBg.fillColor = SKColor.black.withAlphaComponent(0.4)
        headerBg.strokeColor = .clear
        headerBg.position = CGPoint(x: size.width / 2, y: headerY - 10)
        headerBg.zPosition = 8
        addChild(headerBg)

        // Score section
        let scoreContainer = SKNode()
        scoreContainer.position = CGPoint(x: size.width / 2, y: headerY)
        scoreContainer.zPosition = 10
        addChild(scoreContainer)

        let scoreTitleLabel = SKLabelNode(fontNamed: "AvenirNext-DemiBold")
        scoreTitleLabel.text = "SCORE"
        scoreTitleLabel.fontSize = 12
        scoreTitleLabel.fontColor = .white
        scoreTitleLabel.verticalAlignmentMode = .center
        scoreTitleLabel.position = CGPoint(x: 0, y: 15)
        scoreContainer.addChild(scoreTitleLabel)

        scoreLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        scoreLabel.text = "0"
        scoreLabel.fontSize = 36
        scoreLabel.fontColor = VelvetColorPalette.skAmberHighlight
        scoreLabel.verticalAlignmentMode = .center
        scoreLabel.position = CGPoint(x: 0, y: -15)
        scoreContainer.addChild(scoreLabel)

        // High score
        highScoreLabel = SKLabelNode(fontNamed: "AvenirNext-Medium")
        highScoreLabel.text = "Best: \(NebulaPersistence.shared.pinnacleScore)"
        highScoreLabel.fontSize = 14
        highScoreLabel.fontColor = .white.withAlphaComponent(0.85)
        highScoreLabel.verticalAlignmentMode = .center
        highScoreLabel.position = CGPoint(x: size.width / 2, y: headerY - 50)
        highScoreLabel.zPosition = 10
        addChild(highScoreLabel)

        // Pause button
        pauseButton = AzureButtonNode(text: "⏸", size: CGSize(width: 44, height: 44), style: .secondary)
        pauseButton.position = CGPoint(x: size.width - 42, y: headerY)
        pauseButton.zPosition = 10
        pauseButton.tapHandler = { [weak self] in
            self?.showPauseMenu()
        }
        addChild(pauseButton)

        // Target indicator
        let targetLabel = SKLabelNode(fontNamed: "AvenirNext-DemiBold")
        targetLabel.text = "Target: \(eliminationThreshold)"
        targetLabel.fontSize = 14
        targetLabel.fontColor = .white
        targetLabel.verticalAlignmentMode = .center
        targetLabel.horizontalAlignmentMode = .left
        targetLabel.position = CGPoint(x: 20, y: headerY)
        targetLabel.zPosition = 10
        addChild(targetLabel)
    }

    // MARK: - Board Setup

    private func setupBoard() {
        // Use actual scene size for tile dimension calculation (important for iPad compatibility mode)
        let tileSize = CrystalLayoutMetrics.calculateTileDimension(forGridSize: gridDimension, sceneWidth: size.width)

        boardNode = MalachiteBoardNode(dimension: gridDimension, cellSize: tileSize)
        // Position board higher up to leave room for NEXT tile area below
        // Calculate board center position based on available space
        let safeTop = size.height - CrystalLayoutMetrics.safeAreaInsets.top - 120 // Below header
        let safeBottom = CrystalLayoutMetrics.safeAreaInsets.bottom + 140 // Above NEXT area
        let boardCenterY = safeBottom + (safeTop - safeBottom) / 2
        boardNode.position = CGPoint(x: size.width / 2, y: boardCenterY)
        boardNode.zPosition = 5
        boardNode.interactionDelegate = self
        addChild(boardNode)
    }

    // MARK: - Next Tile Area

    private func setupNextTileArea() {
        nextTileContainer = SKNode()
        // Position NEXT area at the bottom with safe area consideration
        let bottomY = CrystalLayoutMetrics.safeAreaInsets.bottom + 70
        nextTileContainer.position = CGPoint(x: size.width / 2, y: bottomY)
        nextTileContainer.zPosition = 10
        addChild(nextTileContainer)

        // Background panel
        let panelWidth: CGFloat = 140
        let panelHeight: CGFloat = 100
        let panel = SKShapeNode(rectOf: CGSize(width: panelWidth, height: panelHeight), cornerRadius: 16)
        panel.fillColor = VelvetColorPalette.skSlatePanel.withAlphaComponent(0.6)
        panel.strokeColor = VelvetColorPalette.skJadePrimary.withAlphaComponent(0.3)
        panel.lineWidth = 1.5
        panel.zPosition = 0
        nextTileContainer.addChild(panel)

        // Label
        let nextLabel = SKLabelNode(fontNamed: "AvenirNext-DemiBold")
        nextLabel.text = "NEXT"
        nextLabel.fontSize = 14
        nextLabel.fontColor = VelvetColorPalette.skPearlText.withAlphaComponent(0.7)
        nextLabel.verticalAlignmentMode = .center
        nextLabel.position = CGPoint(x: 0, y: 35)
        nextLabel.zPosition = 1
        nextTileContainer.addChild(nextLabel)
    }

    // MARK: - Combo Display

    private func setupComboDisplay() {
        comboLabel = SKLabelNode(fontNamed: "AvenirNext-Heavy")
        comboLabel.text = ""
        comboLabel.fontSize = 32
        comboLabel.fontColor = VelvetColorPalette.skAmberHighlight
        comboLabel.verticalAlignmentMode = .center
        comboLabel.position = CGPoint(x: size.width / 2, y: size.height * 0.62)
        comboLabel.zPosition = 100
        comboLabel.alpha = 0
        addChild(comboLabel)
    }

    // MARK: - Game Session

    private func initializeGameSession() {
        gameSession = QuartzGameSession(gridDimension: gridDimension, eliminationThreshold: eliminationThreshold)
        gameSession.eventDispatcher = self
        gameSession.commenceSession()
    }

    // MARK: - UI Updates

    private func updateScoreDisplay() {
        scoreLabel.text = "\(gameSession.currentScore)"

        // Animate score change
        let scaleUp = SKAction.scale(to: 1.2, duration: 0.1)
        let scaleDown = SKAction.scale(to: 1.0, duration: 0.15)
        scaleDown.timingMode = .easeOut
        scoreLabel.run(SKAction.sequence([scaleUp, scaleDown]))
    }

    private func updateNextTilePreview() {
        // Remove existing preview
        nextTilePreview?.removeFromParent()

        guard let pendingTile = gameSession.pendingTile else { return }

        let tileSize: CGFloat = 56
        let previewNode = PorcelainTileNode(entity: pendingTile, dimension: tileSize)
        previewNode.position = CGPoint(x: 0, y: -8)
        previewNode.zPosition = 2
        nextTileContainer.addChild(previewNode)
        nextTilePreview = previewNode

        // Entrance animation
        previewNode.setScale(0)
        previewNode.alpha = 0
        let scaleIn = SKAction.scale(to: 1.0, duration: 0.2)
        scaleIn.timingMode = .easeOut
        let fadeIn = SKAction.fadeIn(withDuration: 0.15)
        previewNode.run(SKAction.group([scaleIn, fadeIn]))

        // Gentle pulse
        previewNode.playSelectionHighlight()
    }

    private func showComboEffect(level: Int) {
        guard level > 1 else { return }

        comboLabel.text = "COMBO x\(level)"
        comboLabel.alpha = 0
        comboLabel.setScale(0.5)

        let fadeIn = SKAction.fadeIn(withDuration: 0.15)
        let scaleUp = SKAction.scale(to: 1.2, duration: 0.15)
        let hold = SKAction.wait(forDuration: 0.5)
        let fadeOut = SKAction.fadeOut(withDuration: 0.3)
        let scaleDown = SKAction.scale(to: 1.0, duration: 0.15)

        let sequence = SKAction.sequence([
            SKAction.group([fadeIn, scaleUp]),
            scaleDown,
            hold,
            fadeOut
        ])

        comboLabel.run(sequence)
        ZephyrSoundManager.shared.triggerSuccessNotification()
    }

    // MARK: - Pause Menu

    private func showPauseMenu() {
        guard !isSessionSuspended else { return }
        isSessionSuspended = true

        let dialog = CelestialDialogNode.createPauseDialog(
            sceneSize: size,
            resumeHandler: { [weak self] in
                self?.isSessionSuspended = false
            },
            restartHandler: { [weak self] in
                self?.restartGame()
            },
            menuHandler: { [weak self] in
                self?.returnToMenu()
            }
        )
        dialog.position = CGPoint(x: size.width / 2, y: size.height / 2)
        addChild(dialog)
        dialog.presentWithAnimation()
    }

    // MARK: - Game Over

    private func showGameOverDialog(isNewRecord: Bool) {
        let dialog = CelestialDialogNode.createGameOverDialog(
            score: gameSession.currentScore,
            highScore: NebulaPersistence.shared.pinnacleScore,
            isNewRecord: isNewRecord,
            sceneSize: size,
            playAgainHandler: { [weak self] in
                self?.restartGame()
            },
            menuHandler: { [weak self] in
                self?.returnToMenu()
            }
        )
        dialog.position = CGPoint(x: size.width / 2, y: size.height / 2)
        addChild(dialog)
        dialog.presentWithAnimation()
    }

    // MARK: - Navigation

    private func restartGame() {
        isSessionSuspended = false
        boardNode.clearAllTiles()
        initializeGameSession()
    }

    private func returnToMenu() {
        let menuScene = SapphireMenuScene(size: size)
        menuScene.scaleMode = .aspectFill

        let transition = SKTransition.fade(withDuration: 0.4)
        view?.presentScene(menuScene, transition: transition)
    }
}

// MARK: - Board Delegate

extension AmethystGameScene: MalachiteBoardDelegate {

    func boardDidReceiveTouch(_ board: MalachiteBoardNode, at coordinate: GridCoordinate) {
        guard !isSessionSuspended else { return }

        let result = gameSession.attemptPlacement(at: coordinate)

        switch result {
        case .accepted(let merges, let gameEnded):
            // Place tile visually
            if let tile = gameSession.boardState.retrieveTile(at: coordinate) ?? findRecentlyPlacedTile(at: coordinate) {
                let tileNode = PorcelainTileNode(entity: tile, dimension: boardNode.cellSize)
                boardNode.placeTileNode(tileNode, at: coordinate)
            }

            // Process merges with animations
            processMergeAnimations(merges) {
                if gameEnded {
                    // Delay to show final state
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        let isNewRecord = NebulaPersistence.shared.pinnacleScore == self.gameSession.currentScore
                        self.showGameOverDialog(isNewRecord: isNewRecord)
                    }
                }
            }

            ZephyrSoundManager.shared.triggerLightImpact()

        case .rejected(let reason):
            switch reason {
            case .cellOccupied:
                ZephyrSoundManager.shared.triggerWarningNotification()
                // Shake animation on board
                let shake = SKAction.sequence([
                    SKAction.moveBy(x: -5, y: 0, duration: 0.05),
                    SKAction.moveBy(x: 10, y: 0, duration: 0.05),
                    SKAction.moveBy(x: -10, y: 0, duration: 0.05),
                    SKAction.moveBy(x: 5, y: 0, duration: 0.05)
                ])
                boardNode.run(shake)
            default:
                break
            }
        }
    }

    private func findRecentlyPlacedTile(at coordinate: GridCoordinate) -> TerracottaTileEntity? {
        return gameSession.boardState.retrieveTile(at: coordinate)
    }

    private func processMergeAnimations(_ merges: [MergeOutcome], completion: @escaping () -> Void) {
        guard !merges.isEmpty else {
            completion()
            return
        }

        var delay: TimeInterval = 0

        for merge in merges {
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                // Highlight merging tiles
                self.boardNode.highlightMergeCluster(Set(merge.dissolvedCoordinates))

                // Remove tiles with animation
                let group = DispatchGroup()

                for coord in merge.dissolvedCoordinates {
                    group.enter()
                    self.boardNode.removeTileNode(at: coord, animated: true) {
                        group.leave()
                    }
                }

                group.notify(queue: .main) {
                    self.boardNode.clearAllHighlights()

                    // Add upgraded tile if applicable
                    if let upgradedTile = merge.ascendedTile {
                        let upgradedNode = PorcelainTileNode(entity: upgradedTile, dimension: self.boardNode.cellSize)
                        self.boardNode.placeTileNode(upgradedNode, at: upgradedTile.gridCoordinate)
                        upgradedNode.playUpgradeAnimation()
                    }

                    // Update score
                    self.updateScoreDisplay()

                    // Show combo
                    if merge.cascadeLevel > 1 {
                        self.showComboEffect(level: merge.cascadeLevel)
                    }
                }

                ZephyrSoundManager.shared.triggerMediumImpact()
            }

            delay += CrystalLayoutMetrics.chainDelayInterval + 0.2
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            completion()
        }
    }
}

// MARK: - Session Delegate

extension AmethystGameScene: QuartzSessionDelegate {

    func sessionDidCommence(_ session: QuartzGameSession) {
        updateScoreDisplay()
        updateNextTilePreview()
    }

    func sessionDidGenerateTile(_ session: QuartzGameSession, tile: TerracottaTileEntity) {
        updateNextTilePreview()
    }

    func sessionDidExecuteMerge(_ session: QuartzGameSession, outcome: MergeOutcome) {
        // Handled in processMergeAnimations
    }

    func sessionDidConclude(_ session: QuartzGameSession, isNewHighScore: Bool) {
        highScoreLabel.text = "Best: \(NebulaPersistence.shared.pinnacleScore)"

        if isNewHighScore {
            // Celebrate new high score
            highScoreLabel.fontColor = VelvetColorPalette.skAmberHighlight
            let pulse = SKAction.sequence([
                SKAction.scale(to: 1.2, duration: 0.2),
                SKAction.scale(to: 1.0, duration: 0.2)
            ])
            highScoreLabel.run(SKAction.repeat(pulse, count: 3))
        }
    }
}
