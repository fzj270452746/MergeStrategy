//
//  SapphireMenuScene.swift
//  MergeStrategy
//
//  Created by Assistant on 12/27/25.
//

import SpriteKit

/// Main menu scene with stylish design
final class SapphireMenuScene: SKScene {

    // MARK: - Properties

    private var titleContainer: SKNode!
    private var menuContainer: SKNode!
    private var difficultyButtons: [AzureButtonNode] = []
    private var selectedDifficulty: Int = 4

    private var decorativeParticles: SKEmitterNode?

    // MARK: - Lifecycle

    override func didMove(to view: SKView) {
        setupBackground()
        setupDecorativeElements()
        setupTitle()
        setupMenuButtons()
        setupFooter()

        animateEntrance()
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

        // Gradient overlay
        let gradientNode = SKShapeNode(rectOf: size)
        gradientNode.fillColor = VelvetColorPalette.skSlatePanel.withAlphaComponent(0.3)
        gradientNode.strokeColor = .clear
        gradientNode.position = CGPoint(x: size.width / 2, y: size.height / 2)
        gradientNode.zPosition = -10
        addChild(gradientNode)

        // Decorative pattern
        createPatternOverlay()
    }

    private func createPatternOverlay() {
        let patternContainer = SKNode()
        patternContainer.zPosition = -5
        patternContainer.alpha = 0.03

        let spacing: CGFloat = 80
        let dotRadius: CGFloat = 3

        for x in stride(from: 0, to: size.width + spacing, by: spacing) {
            for y in stride(from: 0, to: size.height + spacing, by: spacing) {
                let dot = SKShapeNode(circleOfRadius: dotRadius)
                dot.fillColor = VelvetColorPalette.skJadePrimary
                dot.strokeColor = .clear
                dot.position = CGPoint(x: x, y: y)
                patternContainer.addChild(dot)
            }
        }

        addChild(patternContainer)
    }

    private func setupDecorativeElements() {
        // Top accent line
        let topAccent = SKShapeNode(rectOf: CGSize(width: size.width * 0.4, height: 3), cornerRadius: 1.5)
        topAccent.fillColor = VelvetColorPalette.skAmberHighlight
        topAccent.strokeColor = .clear
        topAccent.position = CGPoint(x: size.width / 2, y: size.height - CrystalLayoutMetrics.safeAreaInsets.top - 20)
        topAccent.zPosition = 1
        addChild(topAccent)

        // Floating particle effect
        createFloatingParticles()
    }

    private func createFloatingParticles() {
        let particleContainer = SKNode()
        particleContainer.zPosition = -3

        for _ in 0..<15 {
            let particle = SKShapeNode(circleOfRadius: CGFloat.random(in: 2...5))
            particle.fillColor = VelvetColorPalette.skJadePrimary.withAlphaComponent(0.2)
            particle.strokeColor = .clear
            particle.position = CGPoint(
                x: CGFloat.random(in: 0...size.width),
                y: CGFloat.random(in: 0...size.height)
            )

            let floatUp = SKAction.moveBy(x: 0, y: 30, duration: Double.random(in: 3...5))
            let floatDown = SKAction.moveBy(x: 0, y: -30, duration: Double.random(in: 3...5))
            let drift = SKAction.moveBy(x: CGFloat.random(in: -20...20), y: 0, duration: Double.random(in: 4...6))
            let driftBack = drift.reversed()

            let floatSequence = SKAction.repeatForever(SKAction.sequence([floatUp, floatDown]))
            let driftSequence = SKAction.repeatForever(SKAction.sequence([drift, driftBack]))

            particle.run(SKAction.group([floatSequence, driftSequence]))
            particleContainer.addChild(particle)
        }

        addChild(particleContainer)
    }

    // MARK: - Title Setup

    private func setupTitle() {
        titleContainer = SKNode()
        titleContainer.position = CGPoint(x: size.width / 2, y: size.height - CrystalLayoutMetrics.safeAreaInsets.top - 130)
        titleContainer.zPosition = 10
        addChild(titleContainer)

        // Main title
        let titleLabel = SKLabelNode(fontNamed: "AvenirNext-Heavy")
        titleLabel.text = "MERGE"
        titleLabel.fontSize = CrystalLayoutMetrics.titleFontMagnitude + 8
        titleLabel.fontColor = VelvetColorPalette.skPearlText
        titleLabel.verticalAlignmentMode = .center
        titleLabel.position = CGPoint(x: 0, y: 30)
        titleContainer.addChild(titleLabel)

        let subtitleLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        subtitleLabel.text = "STRATEGY"
        subtitleLabel.fontSize = CrystalLayoutMetrics.titleFontMagnitude - 4
        subtitleLabel.fontColor = VelvetColorPalette.skAmberHighlight
        subtitleLabel.verticalAlignmentMode = .center
        subtitleLabel.position = CGPoint(x: 0, y: -20)
        titleContainer.addChild(subtitleLabel)

        // Decorative mahjong tile preview
        createTilePreview()
    }

    private func createTilePreview() {
        let previewContainer = SKNode()
        previewContainer.position = CGPoint(x: 0, y: -90)
        titleContainer.addChild(previewContainer)

        let tileSize: CGFloat = 50
        let spacing: CGFloat = 8

        for i in 0..<3 {
            let tileEntity = TerracottaTileEntity(magnitude: i + 1, gridCoordinate: GridCoordinate(i, 0))
            let tileNode = PorcelainTileNode(entity: tileEntity, dimension: tileSize)
            tileNode.position = CGPoint(x: CGFloat(i - 1) * (tileSize + spacing), y: 0)
            tileNode.setScale(0.9)

            // Gentle floating animation
            let floatUp = SKAction.moveBy(x: 0, y: 5, duration: 1.5 + Double(i) * 0.2)
            let floatDown = SKAction.moveBy(x: 0, y: -5, duration: 1.5 + Double(i) * 0.2)
            floatUp.timingMode = .easeInEaseOut
            floatDown.timingMode = .easeInEaseOut
            tileNode.run(SKAction.repeatForever(SKAction.sequence([floatUp, floatDown])))

            previewContainer.addChild(tileNode)
        }
    }

    // MARK: - Menu Setup

    private func setupMenuButtons() {
        menuContainer = SKNode()
        menuContainer.position = CGPoint(x: size.width / 2, y: size.height * 0.45)
        menuContainer.zPosition = 10
        addChild(menuContainer)

        // Difficulty selection label
        let difficultyLabel = SKLabelNode(fontNamed: "AvenirNext-DemiBold")
        difficultyLabel.text = "Select Target Value"
        difficultyLabel.fontSize = 18
        difficultyLabel.fontColor = VelvetColorPalette.skPearlText.withAlphaComponent(0.8)
        difficultyLabel.verticalAlignmentMode = .center
        difficultyLabel.position = CGPoint(x: 0, y: 80)
        menuContainer.addChild(difficultyLabel)

        // Difficulty buttons (4-9)
        setupDifficultySelector()

        // Start button
        let buttonWidth = min(size.width - 64, 280)
        let startButton = AzureButtonNode(text: "START GAME", size: CGSize(width: buttonWidth, height: 56), style: .primary)
        startButton.position = CGPoint(x: 0, y: -60)
        startButton.tapHandler = { [weak self] in
            self?.startGame()
        }
        menuContainer.addChild(startButton)

        // How to play button
        let howToPlayButton = AzureButtonNode(text: "How to Play", size: CGSize(width: buttonWidth, height: 48), style: .secondary)
        howToPlayButton.position = CGPoint(x: 0, y: -125)
        howToPlayButton.tapHandler = { [weak self] in
            self?.showHowToPlay()
        }
        menuContainer.addChild(howToPlayButton)

        // Rate app button
        let rateButton = AzureButtonNode(text: "Rate App ★", size: CGSize(width: buttonWidth, height: 48), style: .secondary)
        rateButton.position = CGPoint(x: 0, y: -185)
        rateButton.tapHandler = { [weak self] in
            self?.requestAppRating()
        }
        menuContainer.addChild(rateButton)
    }

    private func setupDifficultySelector() {
        let difficulties = [4, 5, 6, 7, 8, 9]
        let buttonSize: CGFloat = 44
        let spacing: CGFloat = 8
        let totalWidth = CGFloat(difficulties.count) * buttonSize + CGFloat(difficulties.count - 1) * spacing
        let startX = -totalWidth / 2 + buttonSize / 2

        // Load saved difficulty
        selectedDifficulty = NebulaPersistence.shared.lastChosenThreshold
        if selectedDifficulty < 4 || selectedDifficulty > 9 {
            selectedDifficulty = 4
        }

        for (index, difficulty) in difficulties.enumerated() {
            let button = createDifficultyButton(value: difficulty, size: buttonSize)
            button.position = CGPoint(x: startX + CGFloat(index) * (buttonSize + spacing), y: 20)
            button.name = "difficulty_\(difficulty)"
            menuContainer.addChild(button)
            difficultyButtons.append(button)

            if difficulty == selectedDifficulty {
                highlightDifficultyButton(button)
            }
        }
    }

    private func createDifficultyButton(value: Int, size: CGFloat) -> AzureButtonNode {
        let button = AzureButtonNode(text: "\(value)", size: CGSize(width: size, height: size), style: .secondary)
        button.tapHandler = { [weak self] in
            self?.selectDifficulty(value)
        }
        return button
    }

    private func selectDifficulty(_ value: Int) {
        selectedDifficulty = value
        NebulaPersistence.shared.lastChosenThreshold = value

        // Update button visuals
        for button in difficultyButtons {
            if let name = button.name, name == "difficulty_\(value)" {
                highlightDifficultyButton(button)
            } else {
                unhighlightDifficultyButton(button)
            }
        }

        ZephyrSoundManager.shared.triggerLightImpact()
    }

    private func highlightDifficultyButton(_ button: AzureButtonNode) {
        button.run(SKAction.scale(to: 1.1, duration: 0.15))
        button.alpha = 1.0
    }

    private func unhighlightDifficultyButton(_ button: AzureButtonNode) {
        button.run(SKAction.scale(to: 1.0, duration: 0.15))
        button.alpha = 0.6
    }

    // MARK: - Footer Setup

    private func setupFooter() {
        // High score display
        let highScore = NebulaPersistence.shared.pinnacleScore

        let highScoreLabel = SKLabelNode(fontNamed: "AvenirNext-Medium")
        highScoreLabel.text = "Best Score: \(highScore)"
        highScoreLabel.fontSize = 16
        highScoreLabel.fontColor = VelvetColorPalette.skPearlText.withAlphaComponent(0.6)
        highScoreLabel.verticalAlignmentMode = .center
        highScoreLabel.position = CGPoint(x: size.width / 2, y: CrystalLayoutMetrics.safeAreaInsets.bottom + 60)
        highScoreLabel.zPosition = 10
        addChild(highScoreLabel)

        // Games played
        let gamesPlayed = NebulaPersistence.shared.sessionsCompleted

        let statsLabel = SKLabelNode(fontNamed: "AvenirNext-Regular")
        statsLabel.text = "Games Played: \(gamesPlayed)"
        statsLabel.fontSize = 14
        statsLabel.fontColor = VelvetColorPalette.skPearlText.withAlphaComponent(0.4)
        statsLabel.verticalAlignmentMode = .center
        statsLabel.position = CGPoint(x: size.width / 2, y: CrystalLayoutMetrics.safeAreaInsets.bottom + 35)
        statsLabel.zPosition = 10
        addChild(statsLabel)
    }

    // MARK: - Animations

    private func animateEntrance() {
        titleContainer.alpha = 0
        titleContainer.position.y += 30
        menuContainer.alpha = 0
        menuContainer.position.y -= 30

        let titleFadeIn = SKAction.group([
            SKAction.fadeIn(withDuration: 0.5),
            SKAction.moveBy(x: 0, y: -30, duration: 0.5)
        ])
        titleFadeIn.timingMode = .easeOut

        let menuFadeIn = SKAction.group([
            SKAction.fadeIn(withDuration: 0.5),
            SKAction.moveBy(x: 0, y: 30, duration: 0.5)
        ])
        menuFadeIn.timingMode = .easeOut

        titleContainer.run(titleFadeIn)
        menuContainer.run(SKAction.sequence([SKAction.wait(forDuration: 0.2), menuFadeIn]))
    }

    // MARK: - Actions

    private func startGame() {
        ZephyrSoundManager.shared.triggerMediumImpact()

        let gameScene = AmethystGameScene(size: size)
        gameScene.eliminationThreshold = selectedDifficulty
        gameScene.scaleMode = .aspectFill

        let transition = SKTransition.fade(withDuration: 0.4)
        view?.presentScene(gameScene, transition: transition)
    }

    private func showHowToPlay() {
        let dialog = CelestialDialogNode.createHowToPlayDialog(sceneSize: size) {
            // Dialog dismissed
        }
        dialog.position = CGPoint(x: size.width / 2, y: size.height / 2)
        addChild(dialog)
        dialog.presentWithAnimation()
    }

    private func requestAppRating() {
        ZephyrSoundManager.shared.triggerLightImpact()

        // Show a custom dialog for rating
        let dialogWidth = min(size.width - 48, 300)
        let dialog = CelestialDialogNode(size: CGSize(width: dialogWidth, height: 220), sceneSize: size)
        dialog.position = CGPoint(x: size.width / 2, y: size.height / 2)

        dialog.setTitle("Enjoying the Game?")

        let messageLabel = SKLabelNode(fontNamed: "AvenirNext-Regular")
        messageLabel.text = "Please rate us on the App Store!"
        messageLabel.fontSize = 15
        messageLabel.fontColor = VelvetColorPalette.skPearlText.withAlphaComponent(0.8)
        messageLabel.verticalAlignmentMode = .center
        messageLabel.position = CGPoint(x: 0, y: 20)
        dialog.addContentNode(messageLabel)

        let rateButton = dialog.addButton(text: "Rate Now", style: .accent) {
            // In production, this would open the App Store
            dialog.dismissWithAnimation()
        }
        rateButton.position = CGPoint(x: 0, y: -40)

        let laterButton = dialog.addButton(text: "Maybe Later", style: .secondary) {
            dialog.dismissWithAnimation()
        }
        laterButton.position = CGPoint(x: 0, y: -100)

        addChild(dialog)
        dialog.presentWithAnimation()
    }
}
