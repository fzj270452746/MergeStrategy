//
//  AzureButtonNode.swift
//  MergeStrategy
//
//  Created by Assistant on 12/27/25.
//

import SpriteKit

/// Stylish button node for the game UI
final class AzureButtonNode: SKNode {

    // MARK: - Types

    enum ButtonStyle {
        case primary
        case secondary
        case accent
        case danger
    }

    // MARK: - Properties

    private let buttonSize: CGSize
    private let buttonStyle: ButtonStyle
    private let labelText: String

    private var backgroundShape: SKShapeNode!
    private var highlightShape: SKShapeNode!
    private var labelNode: SKLabelNode!
    private var iconNode: SKSpriteNode?

    var tapHandler: (() -> Void)?

    private var isPressed: Bool = false

    // MARK: - Initialization

    init(text: String, size: CGSize, style: ButtonStyle = .primary) {
        self.labelText = text
        self.buttonSize = size
        self.buttonStyle = style
        super.init()

        isUserInteractionEnabled = true
        constructButtonVisuals()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Visual Construction

    private func constructButtonVisuals() {
        let cornerRadius = buttonSize.height / 2

        // Shadow
        let shadowShape = SKShapeNode(rectOf: CGSize(width: buttonSize.width, height: buttonSize.height), cornerRadius: cornerRadius)
        shadowShape.fillColor = SKColor.black.withAlphaComponent(0.3)
        shadowShape.strokeColor = .clear
        shadowShape.position = CGPoint(x: 2, y: -3)
        shadowShape.zPosition = -1
        addChild(shadowShape)

        // Main background
        backgroundShape = SKShapeNode(rectOf: buttonSize, cornerRadius: cornerRadius)
        backgroundShape.fillColor = primaryColorForStyle()
        backgroundShape.strokeColor = strokeColorForStyle()
        backgroundShape.lineWidth = 2
        backgroundShape.zPosition = 0
        addChild(backgroundShape)

        // Inner highlight
        highlightShape = SKShapeNode(rectOf: CGSize(width: buttonSize.width - 8, height: buttonSize.height * 0.4), cornerRadius: cornerRadius - 4)
        highlightShape.fillColor = SKColor.white.withAlphaComponent(0.15)
        highlightShape.strokeColor = .clear
        highlightShape.position = CGPoint(x: 0, y: buttonSize.height * 0.15)
        highlightShape.zPosition = 0.5
        addChild(highlightShape)

        // Label
        labelNode = SKLabelNode(fontNamed: "AvenirNext-Bold")
        labelNode.text = labelText
        labelNode.fontSize = buttonSize.height * 0.38
        labelNode.fontColor = textColorForStyle()
        labelNode.verticalAlignmentMode = .center
        labelNode.horizontalAlignmentMode = .center
        labelNode.zPosition = 1
        addChild(labelNode)
    }

    // MARK: - Style Colors

    private func primaryColorForStyle() -> SKColor {
        switch buttonStyle {
        case .primary:
            return VelvetColorPalette.skJadePrimary
        case .secondary:
            return VelvetColorPalette.skSlatePanel
        case .accent:
            return VelvetColorPalette.skAmberHighlight
        case .danger:
            return VelvetColorPalette.skCoralAlert
        }
    }

    private func strokeColorForStyle() -> SKColor {
        switch buttonStyle {
        case .primary:
            return SKColor(red: 0.25, green: 0.65, blue: 0.55, alpha: 1.0)
        case .secondary:
            return VelvetColorPalette.skJadePrimary.withAlphaComponent(0.5)
        case .accent:
            return SKColor(red: 0.85, green: 0.65, blue: 0.20, alpha: 1.0)
        case .danger:
            return SKColor(red: 0.75, green: 0.30, blue: 0.25, alpha: 1.0)
        }
    }

    private func textColorForStyle() -> SKColor {
        switch buttonStyle {
        case .accent:
            return VelvetColorPalette.skInkText
        default:
            return VelvetColorPalette.skPearlText
        }
    }

    // MARK: - Touch Handling

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        isPressed = true
        animatePressDown()
        ZephyrSoundManager.shared.triggerLightImpact()
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard isPressed else { return }
        isPressed = false

        guard let touch = touches.first else {
            animatePressUp()
            return
        }

        let location = touch.location(in: self)
        let bounds = CGRect(x: -buttonSize.width / 2, y: -buttonSize.height / 2, width: buttonSize.width, height: buttonSize.height)

        if bounds.contains(location) {
            animatePressUp {
                self.tapHandler?()
            }
        } else {
            animatePressUp()
        }
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        isPressed = false
        animatePressUp()
    }

    // MARK: - Animations

    private func animatePressDown() {
        let scaleDown = SKAction.scale(to: 0.95, duration: 0.08)
        scaleDown.timingMode = .easeOut
        run(scaleDown)

        backgroundShape.fillColor = primaryColorForStyle().withAlphaComponent(0.8)
    }

    private func animatePressUp(completion: (() -> Void)? = nil) {
        let scaleUp = SKAction.scale(to: 1.0, duration: 0.12)
        scaleUp.timingMode = .easeOut

        run(scaleUp) {
            completion?()
        }

        backgroundShape.fillColor = primaryColorForStyle()
    }

    // MARK: - State Management

    func setEnabled(_ enabled: Bool) {
        isUserInteractionEnabled = enabled
        alpha = enabled ? 1.0 : 0.5
    }

    func updateLabel(_ text: String) {
        labelNode.text = text
    }
}
