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
            self.gameState.updateScreenSize(CGSize(width: self.screenWidth, height: self.screenHeight))
        }
    }

    func createBubbles() {
            let numberOfBubbles = Int.random(in: 1...max(1, gameSettings.maxBubbles))
            var newBubbles: [Bubble] = []
            for _ in 0..<numberOfBubbles {
                if let bubble = createBubble() {
                    newBubbles.append(bubble)
                    print("Bubble created at \(bubble.position)") // Debug log
                }
            }
            bubbles = newBubbles
            gameState.bubbles = newBubbles
        }
    
    func refreshBubbles() {
        // Clear old bubbles that are beyond the refresh threshold
        // Add new bubbles as needed
        updateBubbles()  // Assuming you already have this method
    }

    func updateBubbles() {
        gameState.refreshBubbles() // Delegate to GameState
        bubbles = gameState.bubbles // Sync with GameState
    }

    private func createBubble() -> Bubble? {
        guard screenWidth > 0, screenHeight > 0 else {
                    print("Invalid screen dimensions: \(screenWidth)x\(screenHeight)")
                    return nil
                }
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

        let position = CGPoint(x: CGFloat.random(in: safeArea.left...screenWidth - safeArea.right),
                                      y: CGFloat.random(in: safeArea.top...screenHeight - safeArea.bottom))
        if isPositionOverlapping(position, size: bubbleSize) {
            return nil
        }

        let dx = CGFloat.random(in: -2...2)
        let dy = CGFloat.random(in: -2...2)
        

        return Bubble(
            id: UUID(),
            color: bubbleColor,
            size: bubbleSize,
            position: position,
            velocity: CGPoint(x: dx, y: dy)
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
        gameState.bubbles = bubbles // Sync with GameState
    }

    func startBubbleMovement() {
        // Movement is handled by GameState, so this can be empty or removed
    }

    func stopBubbleMovement() {
        // Movement is handled by GameState, so this can be empty or removed
    }

    func moveBubbles() {
        gameState.updateBubblePositions(deltaTime: 0.05) // Delegate to GameState
        bubbles = gameState.bubbles // Sync with GameState
    }

    func clearBubbles() {
        bubbles.removeAll()
        gameState.bubbles = bubbles // Sync with GameState
    }
}
