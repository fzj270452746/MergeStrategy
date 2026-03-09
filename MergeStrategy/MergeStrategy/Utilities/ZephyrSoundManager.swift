//
//  ZephyrSoundManager.swift
//  MergeStrategy
//
//  Created by Assistant on 12/27/25.
//

import AVFoundation
import SpriteKit

/// Audio manager for game sound effects and feedback
final class ZephyrSoundManager {

    // MARK: - Singleton

    static let shared = ZephyrSoundManager()

    // MARK: - Properties

    private var isMuted: Bool = false

    // MARK: - Sound Actions for SpriteKit

    private(set) lazy var placementChime: SKAction = {
        createSynthesizedSound(frequency: 523.25, duration: 0.1) // C5
    }()

    private(set) lazy var mergeHarmony: SKAction = {
        let note1 = createSynthesizedSound(frequency: 659.25, duration: 0.15) // E5
        let note2 = createSynthesizedSound(frequency: 783.99, duration: 0.15) // G5
        return SKAction.sequence([note1, note2])
    }()

    private(set) lazy var chainResonance: SKAction = {
        let note1 = createSynthesizedSound(frequency: 783.99, duration: 0.1) // G5
        let note2 = createSynthesizedSound(frequency: 987.77, duration: 0.1) // B5
        let note3 = createSynthesizedSound(frequency: 1174.66, duration: 0.15) // D6
        return SKAction.sequence([note1, note2, note3])
    }()

    private(set) lazy var buttonTap: SKAction = {
        createSynthesizedSound(frequency: 440.0, duration: 0.08) // A4
    }()

    private(set) lazy var gameOverKnell: SKAction = {
        let note1 = createSynthesizedSound(frequency: 392.0, duration: 0.2) // G4
        let note2 = createSynthesizedSound(frequency: 329.63, duration: 0.3) // E4
        return SKAction.sequence([note1, note2])
    }()

    // MARK: - Initialization

    private init() {
        configureAudioSession()
    }

    // MARK: - Configuration

    private func configureAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Audio session configuration failed: \(error)")
        }
    }

    // MARK: - Public Methods

    func toggleMuteState() {
        isMuted.toggle()
    }

    func setMuteState(_ muted: Bool) {
        isMuted = muted
    }

    func currentMuteState() -> Bool {
        return isMuted
    }

    // MARK: - Sound Generation

    private func createSynthesizedSound(frequency: Double, duration: TimeInterval) -> SKAction {
        // Return a simple wait action as placeholder
        // In production, you'd generate actual audio
        return SKAction.wait(forDuration: duration * 0.5)
    }

    // MARK: - Haptic Feedback

    func triggerLightImpact() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }

    func triggerMediumImpact() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }

    func triggerHeavyImpact() {
        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.impactOccurred()
    }

    func triggerSuccessNotification() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }

    func triggerWarningNotification() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.warning)
    }

    func triggerErrorNotification() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.error)
    }
}
