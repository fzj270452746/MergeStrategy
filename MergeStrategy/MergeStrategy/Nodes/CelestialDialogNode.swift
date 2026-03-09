//
//  CelestialDialogNode.swift
//  MergeStrategy
//
//  Created by Assistant on 12/27/25.
//

import SpriteKit

/// Custom stylish dialog overlay node
final class CelestialDialogNode: SKNode {

    // MARK: - Properties

    private let dialogSize: CGSize
    private let sceneSize: CGSize

    private var backdropNode: SKShapeNode!
    private var panelNode: SKShapeNode!
    private var contentContainer: SKNode!

    var dismissHandler: (() -> Void)?

    // MARK: - Initialization

    init(size: CGSize, sceneSize: CGSize) {
        self.dialogSize = size
        self.sceneSize = sceneSize
        super.init()

        zPosition = 1000
        constructDialogVisuals()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Visual Construction

    private func constructDialogVisuals() {
        // Semi-transparent backdrop
        backdropNode = SKShapeNode(rectOf: sceneSize)
        backdropNode.fillColor = SKColor.black.withAlphaComponent(0.7)
        backdropNode.strokeColor = .clear
        backdropNode.zPosition = 0
        backdropNode.alpha = 0
        addChild(backdropNode)

        // Dialog panel
        let cornerRadius: CGFloat = 24

        // Panel shadow
        let shadowNode = SKShapeNode(rectOf: CGSize(width: dialogSize.width + 4, height: dialogSize.height + 4), cornerRadius: cornerRadius + 2)
        shadowNode.fillColor = SKColor.black.withAlphaComponent(0.4)
        shadowNode.strokeColor = .clear
        shadowNode.position = CGPoint(x: 4, y: -6)
        shadowNode.zPosition = 0.5

        // Main panel
        panelNode = SKShapeNode(rectOf: dialogSize, cornerRadius: cornerRadius)
        panelNode.fillColor = VelvetColorPalette.skSlatePanel
        panelNode.strokeColor = VelvetColorPalette.skJadePrimary.withAlphaComponent(0.5)
        panelNode.lineWidth = 2
        panelNode.zPosition = 1
        panelNode.setScale(0.8)
        panelNode.alpha = 0

        panelNode.addChild(shadowNode)
        addChild(panelNode)

        // Decorative top accent
        let accentBar = SKShapeNode(rectOf: CGSize(width: dialogSize.width * 0.6, height: 4), cornerRadius: 2)
        accentBar.fillColor = VelvetColorPalette.skAmberHighlight
        accentBar.strokeColor = .clear
        accentBar.position = CGPoint(x: 0, y: dialogSize.height / 2 - 16)
        panelNode.addChild(accentBar)

        // Content container
        contentContainer = SKNode()
        contentContainer.zPosition = 2
        panelNode.addChild(contentContainer)
    }

    // MARK: - Content Management

    func setTitle(_ text: String) {
        let titleLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        titleLabel.text = text
        titleLabel.fontSize = 28
        titleLabel.fontColor = VelvetColorPalette.skPearlText
        titleLabel.verticalAlignmentMode = .center
        titleLabel.position = CGPoint(x: 0, y: dialogSize.height / 2 - 50)
        titleLabel.name = "titleLabel"
        contentContainer.addChild(titleLabel)
    }

    func setMessage(_ text: String) {
        let messageLabel = SKLabelNode(fontNamed: "AvenirNext-Medium")
        messageLabel.text = text
        messageLabel.fontSize = 18
        messageLabel.fontColor = VelvetColorPalette.skPearlText.withAlphaComponent(0.85)
        messageLabel.verticalAlignmentMode = .center
        messageLabel.position = CGPoint(x: 0, y: 20)
        messageLabel.preferredMaxLayoutWidth = dialogSize.width - 48
        messageLabel.numberOfLines = 0
        messageLabel.name = "messageLabel"
        contentContainer.addChild(messageLabel)
    }

    func addButton(text: String, style: AzureButtonNode.ButtonStyle = .primary, action: @escaping () -> Void) -> AzureButtonNode {
        let buttonWidth = dialogSize.width - 64
        let button = AzureButtonNode(text: text, size: CGSize(width: buttonWidth, height: 50), style: style)
        button.tapHandler = action
        contentContainer.addChild(button)
        return button
    }

    func addContentNode(_ node: SKNode) {
        contentContainer.addChild(node)
    }

    // MARK: - Presentation

    func presentWithAnimation() {
        let fadeIn = SKAction.fadeIn(withDuration: 0.25)
        backdropNode.run(fadeIn)

        let scaleUp = SKAction.scale(to: 1.0, duration: 0.3)
        scaleUp.timingMode = .easeOut
        let fadeInPanel = SKAction.fadeIn(withDuration: 0.25)

        panelNode.run(SKAction.group([scaleUp, fadeInPanel]))

        ZephyrSoundManager.shared.triggerMediumImpact()
    }

    func dismissWithAnimation(completion: (() -> Void)? = nil) {
        let fadeOut = SKAction.fadeOut(withDuration: 0.2)
        backdropNode.run(fadeOut)

        let scaleDown = SKAction.scale(to: 0.8, duration: 0.2)
        let fadeOutPanel = SKAction.fadeOut(withDuration: 0.2)

        panelNode.run(SKAction.group([scaleDown, fadeOutPanel])) {
            self.removeFromParent()
            completion?()
            self.dismissHandler?()
        }
    }
}

// MARK: - Factory Methods

extension CelestialDialogNode {

    static func createGameOverDialog(
        score: Int,
        highScore: Int,
        isNewRecord: Bool,
        sceneSize: CGSize,
        playAgainHandler: @escaping () -> Void,
        menuHandler: @escaping () -> Void
    ) -> CelestialDialogNode {

        let dialogWidth = min(sceneSize.width - 48, 320)
        let dialog = CelestialDialogNode(size: CGSize(width: dialogWidth, height: 340), sceneSize: sceneSize)

        dialog.setTitle(isNewRecord ? "New Record!" : "Game Over")

        // Score display
        let scoreLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        scoreLabel.text = "\(score)"
        scoreLabel.fontSize = 48
        scoreLabel.fontColor = VelvetColorPalette.skAmberHighlight
        scoreLabel.verticalAlignmentMode = .center
        scoreLabel.position = CGPoint(x: 0, y: 40)
        dialog.addContentNode(scoreLabel)

        let scoreCaption = SKLabelNode(fontNamed: "AvenirNext-Medium")
        scoreCaption.text = "SCORE"
        scoreCaption.fontSize = 14
        scoreCaption.fontColor = VelvetColorPalette.skPearlText.withAlphaComponent(0.6)
        scoreCaption.verticalAlignmentMode = .center
        scoreCaption.position = CGPoint(x: 0, y: 0)
        dialog.addContentNode(scoreCaption)

        // High score
        let highScoreLabel = SKLabelNode(fontNamed: "AvenirNext-Medium")
        highScoreLabel.text = "Best: \(highScore)"
        highScoreLabel.fontSize = 16
        highScoreLabel.fontColor = VelvetColorPalette.skPearlText.withAlphaComponent(0.7)
        highScoreLabel.verticalAlignmentMode = .center
        highScoreLabel.position = CGPoint(x: 0, y: -30)
        dialog.addContentNode(highScoreLabel)

        // Buttons
        let playAgainButton = dialog.addButton(text: "Play Again", style: .primary) {
            dialog.dismissWithAnimation {
                playAgainHandler()
            }
        }
        playAgainButton.position = CGPoint(x: 0, y: -90)

        let menuButton = dialog.addButton(text: "Main Menu", style: .secondary) {
            dialog.dismissWithAnimation {
                menuHandler()
            }
        }
        menuButton.position = CGPoint(x: 0, y: -150)

        return dialog
    }

    static func createPauseDialog(
        sceneSize: CGSize,
        resumeHandler: @escaping () -> Void,
        restartHandler: @escaping () -> Void,
        menuHandler: @escaping () -> Void
    ) -> CelestialDialogNode {

        let dialogWidth = min(sceneSize.width - 48, 300)
        let dialog = CelestialDialogNode(size: CGSize(width: dialogWidth, height: 300), sceneSize: sceneSize)

        dialog.setTitle("Paused")

        let resumeButton = dialog.addButton(text: "Resume", style: .primary) {
            dialog.dismissWithAnimation {
                resumeHandler()
            }
        }
        resumeButton.position = CGPoint(x: 0, y: 30)

        let restartButton = dialog.addButton(text: "Restart", style: .secondary) {
            dialog.dismissWithAnimation {
                restartHandler()
            }
        }
        restartButton.position = CGPoint(x: 0, y: -35)

        let menuButton = dialog.addButton(text: "Main Menu", style: .secondary) {
            dialog.dismissWithAnimation {
                menuHandler()
            }
        }
        menuButton.position = CGPoint(x: 0, y: -100)

        return dialog
    }

    static func createHowToPlayDialog(sceneSize: CGSize, dismissHandler: @escaping () -> Void) -> CelestialDialogNode {
        let dialogWidth = min(sceneSize.width - 32, 340)
        let dialog = CelestialDialogNode(size: CGSize(width: dialogWidth, height: 420), sceneSize: sceneSize)

        dialog.setTitle("How to Play")

        let instructions = [
            "• Tap empty cells to place tiles",
            "• Match 3+ same-value tiles",
            "• Connected tiles merge & upgrade",
            "• Reach target value to clear tiles",
            "• Chain merges for bonus points!",
            "• Game ends when board is full"
        ]

        var yOffset: CGFloat = 50
        for instruction in instructions {
            let label = SKLabelNode(fontNamed: "AvenirNext-Regular")
            label.text = instruction
            label.fontSize = 15
            label.fontColor = VelvetColorPalette.skPearlText.withAlphaComponent(0.9)
            label.horizontalAlignmentMode = .left
            label.verticalAlignmentMode = .center
            label.position = CGPoint(x: -dialogWidth / 2 + 24, y: yOffset)
            dialog.addContentNode(label)
            yOffset -= 32
        }

        let okButton = dialog.addButton(text: "Got It!", style: .primary) {
            dialog.dismissWithAnimation {
                dismissHandler()
            }
        }
        okButton.position = CGPoint(x: 0, y: -150)

        return dialog
    }
}
