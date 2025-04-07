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
        // Remove some random existing bubbles
        let bubblesCount = bubbles.count
        let removeCount = min(Int.random(in: 0...3), bubblesCount)
        
        if removeCount > 0 && bubblesCount > 0 {
            let indicesToRemove = (0..<bubblesCount).shuffled().prefix(removeCount)
            bubbles = bubbles.enumerated().filter { !indicesToRemove.contains($0.offset) }.map { $0.element }
        }
        
        // Add new bubbles up to max allowed
        let remainingSlots = gameSettings.maxBubbles - bubbles.count
        if remainingSlots > 0 {
            let newBubbleCount = Int.random(in: 1...remainingSlots)
            for _ in 0..<newBubbleCount {
                if let bubble = createBubble() {
                    bubbles.append(bubble)
                }
            }
        }
        
        gameState.bubbles = bubbles // Sync with GameState
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
        
        let bubbleColor = BubbleColor.randomBubbleColor()
        let bubbleSize: CGFloat = 60
        
        // Calculate available space within screen bounds
        let topPadding = 100.0 // For navigation bar and status bar
        let padding: CGFloat = 10
        
        // Calculate boundaries ensuring bubble stays fully on screen
        let minX = bubbleSize/2 + padding
        let maxX = screenWidth - bubbleSize/2 - padding
        let minY = bubbleSize/2 + topPadding
        let maxY = screenHeight - bubbleSize/2 - padding
        
        // Check if we have valid screen space
        if maxX <= minX || maxY <= minY {
            return nil
        }
        
        // Try to find a non-overlapping position (max 20 attempts)
        for _ in 0..<20 {
            let xPosition = CGFloat.random(in: minX...maxX)
            let yPosition = CGFloat.random(in: minY...maxY)
            let position = CGPoint(x: xPosition, y: yPosition)
            
            if !isPositionOverlapping(position, size: bubbleSize) {
                // Create velocity based on selected speed setting
                let baseSpeed = getBaseSpeedMultiplier()
                let speedMultiplier: CGFloat = baseSpeed
                let dx = CGFloat.random(in: -1...1) * speedMultiplier
                let dy = CGFloat.random(in: -1...1) * speedMultiplier
                
                return Bubble(
                    id: UUID(),
                    color: bubbleColor,
                    size: bubbleSize,
                    position: position,
                    velocity: CGPoint(x: dx, y: dy)
                )
            }
        }
        
        return nil // Could not find non-overlapping position
    }
    
    // Helper method to get the appropriate speed multiplier based on settings
    private func getBaseSpeedMultiplier() -> CGFloat {
        switch gameSettings.bubbleSpeed {
        case .slow:
            return 30
        case .medium:
            return 60
        case .fast:
            return 90
        }
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
        // Start a timer to move bubbles
        Timer.scheduledTimer(withTimeInterval: 0.016, repeats: true) { [weak self] timer in
            guard let self = self, self.gameState.gameRunning else {
                timer.invalidate()
                return
            }
            
            self.moveBubbles()
        }
    }

    func stopBubbleMovement() {
        // Movement is handled by timer invalidation in startBubbleMovement
    }

    func updateBubbleSpeed() {
        // Calculate speed factor based on remaining time
        let timeRatio = Double(gameState.timeRemaining) / Double(gameSettings.gameTime)
        let timeSpeedFactor = max(1.0, 1.0 + (1.0 - timeRatio) * 1.5) // Speed increases as time decreases
        
        // Apply speed factor to all bubbles
        for i in 0..<bubbles.count {
            var bubble = bubbles[i]
            let currentSpeed = hypot(bubble.velocity.x, bubble.velocity.y)
            
            if currentSpeed > 0 {
                // Normalize direction vector
                let directionX = bubble.velocity.x / currentSpeed
                let directionY = bubble.velocity.y / currentSpeed
                
                // Apply speed factors while maintaining direction
                let baseSpeed = getBaseSpeedMultiplier()
                let newSpeed = baseSpeed * CGFloat(timeSpeedFactor)
                
                bubble.velocity = CGPoint(
                    x: directionX * newSpeed,
                    y: directionY * newSpeed
                )
                
                bubbles[i] = bubble
            }
        }
        
        gameState.bubbles = bubbles // Sync with GameState
    }

    func moveBubbles() {
        let deltaTime: CGFloat = 0.016 // Approximately 60fps
        
        // Update bubble positions based on their velocities
        var updatedBubbles: [Bubble] = []
        
        for bubble in bubbles {
            var newBubble = bubble
            
            // Calculate new position
            let newX = bubble.position.x + bubble.velocity.x * deltaTime
            let newY = bubble.position.y + bubble.velocity.y * deltaTime
            
            // Check for boundary collisions and bounce
            let radius = bubble.size / 2
            var newVelocityX = bubble.velocity.x
            var newVelocityY = bubble.velocity.y
            
            // Horizontal bounds check
            if newX - radius < 0 || newX + radius > screenWidth {
                newVelocityX = -newVelocityX
            }
            
            // Vertical bounds check
            if newY - radius < 0 || newY + radius > screenHeight {
                newVelocityY = -newVelocityY
            }
            
            // Apply updated position and velocity
            newBubble.velocity = CGPoint(x: newVelocityX, y: newVelocityY)
            newBubble.position = CGPoint(
                x: min(max(radius, newX), screenWidth - radius),
                y: min(max(radius, newY), screenHeight - radius)
            )
            
            updatedBubbles.append(newBubble)
        }
        
        bubbles = updatedBubbles
        gameState.bubbles = bubbles // Sync with GameState
    }

    func clearBubbles() {
        bubbles.removeAll()
        gameState.bubbles = bubbles // Sync with GameState
    }
}
