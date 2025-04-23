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
    
    /// Playable area bounds accounting for orientation and safe areas
    private var playableArea: CGRect = .zero

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
            // Get the current screen bounds and safe area
            self.screenWidth = UIScreen.main.bounds.width
            self.screenHeight = UIScreen.main.bounds.height
            self.safeArea = UIApplication.shared.connectedScenes
                .compactMap { ($0 as? UIWindowScene)?.keyWindow?.safeAreaInsets }
                .first ?? .zero
            
            // Calculate playable area based on orientation
            let isLandscape = self.screenWidth > self.screenHeight
            if isLandscape {
                // In landscape, account for side panel (25% of width) and safe areas
                let leftInset = max(self.safeArea.left, 0)
                let rightInset = max(self.safeArea.right, 0)
                let topInset = max(self.safeArea.top, 0)
                let bottomInset = max(self.safeArea.bottom, 0)
                
                // Side panel takes 25% of width from the left
                let sidePanel = self.screenWidth * 0.25
                
                self.playableArea = CGRect(
                    x: sidePanel + leftInset,
                    y: topInset,
                    width: self.screenWidth - sidePanel - leftInset - rightInset,
                    height: self.screenHeight - topInset - bottomInset
                )
            } else {
                // In portrait, just account for the safe areas and header
                let leftInset = max(self.safeArea.left, 0)
                let rightInset = max(self.safeArea.right, 0)
                let topInset = max(self.safeArea.top, 0) + 120 // Header height
                let bottomInset = max(self.safeArea.bottom, 0)
                
                self.playableArea = CGRect(
                    x: leftInset,
                    y: topInset,
                    width: self.screenWidth - leftInset - rightInset,
                    height: self.screenHeight - topInset - bottomInset
                )
            }
            
            // Update game state with new dimensions
            self.gameState.updateScreenSize(CGSize(width: self.screenWidth, height: self.screenHeight))
            
            // Adjust existing bubbles to fit within new playable area
            self.adjustBubblesToPlayableArea()
        }
    }
    
    /// Adjust existing bubbles to fit within the current playable area
    private func adjustBubblesToPlayableArea() {
        var updatedBubbles: [Bubble] = []
        
        for bubble in bubbles {
            var newBubble = bubble
            let radius = bubble.size / 2
            
            // Ensure bubble position is within playable area
            let newX = min(max(playableArea.minX + radius, bubble.position.x), playableArea.maxX - radius)
            let newY = min(max(playableArea.minY + radius, bubble.position.y), playableArea.maxY - radius)
            
            newBubble.position = CGPoint(x: newX, y: newY)
            updatedBubbles.append(newBubble)
        }
        
        bubbles = updatedBubbles
        gameState.bubbles = bubbles
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
        // Generate a random size based on settings
        let minSize: CGFloat = gameSettings.minBubbleSize
        let maxSize: CGFloat = gameSettings.maxBubbleSize
        let bubbleSize = CGFloat.random(in: minSize...maxSize)
        let radius = bubbleSize / 2
        
        // Generate random position within playable area
        let randomX = CGFloat.random(in: (playableArea.minX + radius)...(playableArea.maxX - radius))
        let randomY = CGFloat.random(in: (playableArea.minY + radius)...(playableArea.maxY - radius))
        let position = CGPoint(x: randomX, y: randomY)
        
        // Check for overlap with existing bubbles
        for existingBubble in bubbles {
            let distance = hypot(position.x - existingBubble.position.x, position.y - existingBubble.position.y)
            let minDistance = radius + existingBubble.size / 2
            
            // If bubbles overlap, try again later
            if distance < minDistance {
                return nil
            }
        }
        
        // Generate random color
        let bubbleColors: [BubbleColor] = [.red, .orange, .yellow, .green, .blue, .purple, .pink, .teal]
        let randomColor = bubbleColors.randomElement() ?? .red
        
        // Generate random velocity based on difficulty
        let speedMultiplier = gameSettings.bubbleSpeed
        let angle = CGFloat.random(in: 0...(2 * .pi))
        let speed = CGFloat.random(in: 50...150) * speedMultiplier
        let velocityX = cos(angle) * speed
        let velocityY = sin(angle) * speed
        
        // Create the bubble
        return Bubble(
            id: UUID(),
            position: position,
            size: bubbleSize,
            color: randomColor,
            velocity: CGPoint(x: velocityX, y: velocityY),
            creationTime: Date()
        )
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
            Task { @MainActor in
                guard let self = self, self.gameState.gameRunning else {
                    timer.invalidate()
                    return
                }
                
                self.moveBubbles()
            }
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
            
            // Check for boundary collisions within playable area
            let radius = bubble.size / 2
            var newVelocityX = bubble.velocity.x
            var newVelocityY = bubble.velocity.y
            
            // Horizontal bounds check
            if newX - radius < playableArea.minX || newX + radius > playableArea.maxX {
                newVelocityX = -newVelocityX
            }
            
            // Vertical bounds check
            if newY - radius < playableArea.minY || newY + radius > playableArea.maxY {
                newVelocityY = -newVelocityY
            }
            
            // Apply updated position and velocity
            newBubble.velocity = CGPoint(x: newVelocityX, y: newVelocityY)
            newBubble.position = CGPoint(
                x: min(max(playableArea.minX + radius, newX), playableArea.maxX - radius),
                y: min(max(playableArea.minY + radius, newY), playableArea.maxY - radius)
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
