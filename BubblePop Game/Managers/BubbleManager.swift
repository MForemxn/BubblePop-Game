//
//  BubbleManager.swift
//  BubblePop Game
//
//  Created by Mason Foreman on 28/3/2025.
//

import Foundation
import SwiftUI
import Combine

@MainActor
class BubbleManager: ObservableObject {
    @Published var bubbles: [Bubble] = []

    private let gameSettings: GameSettings
    private let gameState: GameState
    private var screenWidth: CGFloat = UIScreen.main.bounds.width
    private var screenHeight: CGFloat = UIScreen.main.bounds.height
    private var safeArea: UIEdgeInsets = .zero // Safe area insets

    // Bubble movement timer
    private var bubbleMovementTimer: Timer?
    private var bubbleSpeedMultiplier: CGFloat {
        switch gameSettings.bubbleSpeed {
        case .slow: return 0.5
        case .medium: return 1.0
        case .fast: return 1.5
        }
    }

    init(gameSettings: GameSettings, gameState: GameState) {
        self.gameSettings = gameSettings
        self.gameState = gameState

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(updateScreenDimensions),
            name: UIDevice.orientationDidChangeNotification,
            object: nil
        )
        updateScreenDimensions()
    }
    

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    @objc private func updateScreenDimensions() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.screenWidth = UIScreen.main.bounds.width
            self.screenHeight = UIScreen.main.bounds.height
            self.safeArea = UIApplication.shared.connectedScenes
                .compactMap { ($0 as? UIWindowScene)?.keyWindow?.safeAreaInsets }
                .first ?? .zero
        }
    }

    func createBubbles() {
        let numberOfBubbles = Int.random(in: 1...gameSettings.maxBubbles)
        var newBubbles: [Bubble] = []

        for _ in 0..<numberOfBubbles {
            if let bubble = createBubble() {
                newBubbles.append(bubble)
            }
        }

        bubbles = newBubbles
    }

    func updateBubbles() {
        let removalCount = Int.random(in: 0...bubbles.count / 2)
        if removalCount > 0 {
            bubbles.shuffle()
            bubbles.removeFirst(removalCount)
        }

        let addCount = Int.random(in: 1...max(1, gameSettings.maxBubbles - bubbles.count))
        for _ in 0..<addCount {
            if let bubble = createBubble() {
                bubbles.append(bubble)
            }
        }
    }

    private func createBubble() -> Bubble? {
        let bubbleColor = determineBubbleColor()
        let bubbleSize: CGFloat = 60
        let padding: CGFloat = 20

        let topSafeArea = safeArea.top + padding + 80
        let bottomSafeArea = safeArea.bottom + padding
        let leftSafeArea = safeArea.left + padding
        let rightSafeArea = safeArea.right + padding

        let availableWidth = screenWidth - bubbleSize - leftSafeArea - rightSafeArea
        let availableHeight = screenHeight - bubbleSize - topSafeArea - bottomSafeArea

        if availableWidth <= 0 || availableHeight <= 0 {
            return nil
        }

        let xPosition = CGFloat.random(in: leftSafeArea...(leftSafeArea + availableWidth))
        let yPosition = CGFloat.random(in: topSafeArea...(topSafeArea + availableHeight))

        let position = CGPoint(x: xPosition, y: yPosition)
        if isPositionOverlapping(position, size: bubbleSize) {
            return nil
        }

        let dx = CGFloat.random(in: -2...2)
        let dy = CGFloat.random(in: -2...2)

        return Bubble(
            id: UUID(),
            color: bubbleColor, // Corrected parameter name
            size: bubbleSize,
            position: position,
            velocity: CGPoint(x: dx, y: dy) // Fixed movement logic
        )
    }

    private func determineBubbleColor() -> BubbleColor {
        let random = Double.random(in: 0...1)

        switch random {
        case 0..<0.40: return .red
        case 0.40..<0.70: return .pink
        case 0.70..<0.85: return .green
        case 0.85..<0.95: return .blue
        default: return .black
        }
    }

    private func isPositionOverlapping(_ position: CGPoint, size: CGFloat) -> Bool {
        for bubble in bubbles {
            let distance = hypot(position.x - bubble.position.x, position.y - bubble.position.y)
            if distance < (size + bubble.size) / 2 {
                return true
            }
        }
        return false
    }

    func removeBubble(_ bubble: Bubble) {
        bubbles.removeAll { $0.id == bubble.id }
    }

    func startBubbleMovement() {
        bubbleMovementTimer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.moveBubbles()
            }
        }
    }

    func stopBubbleMovement() {
        bubbleMovementTimer?.invalidate()
        bubbleMovementTimer = nil
    }

    func moveBubbles() {
        guard !bubbles.isEmpty else { return }

        let timeRatio = CGFloat(gameState.timeRemaining) / CGFloat(gameSettings.gameTime)
        let speedFactor = 1.0 + (1.0 - timeRatio) * bubbleSpeedMultiplier

        for i in bubbles.indices {
            var bubble = bubbles[i]

            let dx = bubble.velocity.x * speedFactor
            let dy = bubble.velocity.y * speedFactor
            var newPosition = CGPoint(x: bubble.position.x + dx, y: bubble.position.y + dy)

            let radius = bubble.size / 2

            if newPosition.x - radius < 0 || newPosition.x + radius > screenWidth {
                bubble.velocity.x *= -1
                newPosition.x = bubble.position.x + bubble.velocity.x * speedFactor
            }

            if newPosition.y - radius < 0 || newPosition.y + radius > screenHeight {
                bubble.velocity.y *= -1
                newPosition.y = bubble.position.y + bubble.velocity.y * speedFactor
            }

            bubbles[i].position = newPosition // Corrected mutation issue
        }
    }

    func clearBubbles() {
        bubbles.removeAll()
    }
}
