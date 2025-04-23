//
//  BubbleManager.swift
//  BubblePop Game
//
//  Created by Mason Foreman on 28/3/2025.
//

import Foundation
import SwiftUI
import Combine

/// Manages the creation, movement, and lifecycle of bubbles in the game
@MainActor
class BubbleManager: ObservableObject {
    // MARK: - Properties
    
    /// List of active bubbles in the game
    @Published var bubbles: [Bubble] = []

    /// Reference to game settings
    private let gameSettings: GameSettings
    
    /// Reference to game state
    private let gameState: GameState
    
    /// Current screen width
    private var screenWidth: CGFloat = UIScreen.main.bounds.width
    
    /// Current screen height
    private var screenHeight: CGFloat = UIScreen.main.bounds.height
    
    /// Safe area insets from device
    private var safeArea: UIEdgeInsets = .zero

    // MARK: - Initialization
    
    /// Initialize the bubble manager
    init(gameSettings: GameSettings, gameState: GameState) {
        self.gameSettings = gameSettings
        self.gameState = gameState

        // Listen for screen rotation changes
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

    // MARK: - Screen Handling
    
    /// Update screen dimensions when device rotates
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

    // MARK: - Bubble Creation and Management
    
    /// Create initial set of bubbles for the game
    func createBubbles() {
        // Generate a random number of bubbles up to max setting
        let numberOfBubbles = Int.random(in: 1...max(1, gameSettings.maxBubbles))
        var newBubbles: [Bubble] = []
        
        // Try to create each bubble
        for _ in 0..<numberOfBubbles {
            if let bubble = createBubble() {
                newBubbles.append(bubble)
            }
        }
        
        // Update game state
        bubbles = newBubbles
        gameState.bubbles = newBubbles
    }
    
    /// Refresh bubbles by removing some and adding new ones
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
        
        // Sync with game state
        gameState.bubbles = bubbles
    }

    /// Update bubbles from game state
    func updateBubbles() {
        gameState.refreshBubbles()
        bubbles = gameState.bubbles
    }

    /// Create a single bubble with random properties
    private func createBubble() -> Bubble? {
        guard screenWidth > 0, screenHeight > 0 else {
            return nil
        }
        
        // Pick random color and set size
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
            // Generate random position
            let xPosition = CGFloat.random(in: minX...maxX)
            let yPosition = CGFloat.random(in: minY...maxY)
            let position = CGPoint(x: xPosition, y: yPosition)
            
            // Check if position overlaps with existing bubbles
            if !isPositionOverlapping(position, size: bubbleSize) {
                // Create velocity based on selected speed setting
                let baseSpeed = getBaseSpeedMultiplier()
                let dx = CGFloat.random(in: -1...1) * baseSpeed
                let dy = CGFloat.random(in: -1...1) * baseSpeed
                
                // Create and return the bubble
                return Bubble(
                    color: bubbleColor,
                    size: bubbleSize,
                    position: position,
                    velocity: CGPoint(x: dx, y: dy)
                )
            }
        }
        
        return nil // Could not find non-overlapping position
    }
    
    /// Get the speed multiplier based on game settings
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

    /// Check if a potential bubble position overlaps with existing bubbles
    private func isPositionOverlapping(_ position: CGPoint, size: CGFloat) -> Bool {
        for bubble in bubbles {
            let distance = hypot(position.x - bubble.position.x, position.y - bubble.position.y)
            if distance < (size + bubble.size) / 2 {
                return true
            }
        }
        return false
    }

    /// Remove a specific bubble from the game
    func removeBubble(_ bubble: Bubble) {
        bubbles.removeAll { $0.id == bubble.id }
        gameState.bubbles = bubbles
    }

    // MARK: - Bubble Movement
    
    /// Start the bubble movement timer
    func startBubbleMovement() {
        Timer.scheduledTimer(withTimeInterval: 0.016, repeats: true) { [weak self] timer in
            guard let self = self, self.gameState.gameRunning else {
                timer.invalidate()
                return
            }
            
            self.moveBubbles()
        }
    }

    /// Stop bubble movement (handled by timer invalidation)
    func stopBubbleMovement() {
        // Movement is handled by timer invalidation in startBubbleMovement
    }

    /// Update bubble speeds based on remaining time
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
        
        gameState.bubbles = bubbles
    }

    /// Move bubbles and handle wall collisions
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
        gameState.bubbles = bubbles
    }

    /// Remove all bubbles from the game
    func clearBubbles() {
        bubbles.removeAll()
        gameState.bubbles = bubbles
    }
}
