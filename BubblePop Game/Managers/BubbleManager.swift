//
//  BubbleManager.swift
//  BubblePop Game
//
//  Created by Mason Foreman on 28/3/2025.
//

import Foundation
import SwiftUI
import Combine

class BubbleManager: ObservableObject {
    @Published var bubbles: [Bubble] = []
    
    private let gameSettings: GameSettings
    private let gameState: GameState
    private var screenWidth: CGFloat = UIScreen.main.bounds.width
    private var screenHeight: CGFloat = UIScreen.main.bounds.height
    private var safeArea: UIEdgeInsets = UIApplication.shared.windows.first?.safeAreaInsets ?? .zero
    
    // For bubble movement
    private var bubbleMovementTimer: Timer?
    private let bubbleSpeedMultiplier = 1.0
    
    init(gameSettings: GameSettings, gameState: GameState) {
        self.gameSettings = gameSettings
        self.gameState = gameState
        
        // Update screen dimensions when orientation changes
        NotificationCenter.default.addObserver(self, selector: #selector(updateScreenDimensions), name: UIDevice.orientationDidChangeNotification, object: nil)
        updateScreenDimensions()
    }
    
    @objc private func updateScreenDimensions() {
        // Give time for screen to rotate
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.screenWidth = UIScreen.main.bounds.width
            self.screenHeight = UIScreen.main.bounds.height
            self.safeArea = UIApplication.shared.windows.first?.safeAreaInsets ?? .zero
        }
    }
    
    func createBubbles() {
        // Determine how many bubbles to create (random up to max)
        let numberOfBubbles = Int.random(in: 1...gameSettings.maxBubbles)
        
        // Create new bubbles
        var newBubbles: [Bubble] = []
        
        for _ in 0..<numberOfBubbles {
            if let bubble = createBubble() {
                newBubbles.append(bubble)
            }
        }
        
        // Replace old bubbles with new ones
        bubbles = newBubbles
    }
    
    func updateBubbles() {
        // Remove some existing bubbles randomly
        let removalCount = Int.random(in: 0...bubbles.count/2)
        if removalCount > 0 && !bubbles.isEmpty {
            bubbles.shuffle()
            bubbles = Array(bubbles.dropFirst(removalCount))
        }
        
        // Add new bubbles
        let addCount = Int.random(in: 1...max(1, gameSettings.maxBubbles - bubbles.count))
        for _ in 0..<addCount {
            if let bubble = createBubble() {
                bubbles.append(bubble)
            }
        }
    }
    
    func createBubble() -> Bubble? {
        // Determine bubble color based on probability
        let bubbleColor = determineBubbleColor()
        
        // Calculate safe area for bubble placement
        let bubbleSize: CGFloat = 60
        let padding: CGFloat = 20
        
        // Calculate safe area to place bubble
        let topSafeArea = safeArea.top + padding + 80 // Extra room for score display
        let bottomSafeArea = safeArea.bottom + padding
        let leftSafeArea = safeArea.left + padding
        let rightSafeArea = safeArea.right + padding
        
        // Available area for bubble placement
        let availableWidth = screenWidth - bubbleSize - leftSafeArea - rightSafeArea
        let availableHeight = screenHeight - bubbleSize - topSafeArea - bottomSafeArea
        
        // If there's no space, don't create a bubble
        if availableWidth <= 0 || availableHeight <= 0 {
            return nil
        }
        
        // Generate random position within safe area
        let xPosition = CGFloat.random(in: leftSafeArea...(leftSafeArea + availableWidth))
        let yPosition = CGFloat.random(in: topSafeArea...(topSafeArea + availableHeight))
        
        // Check if position overlaps with any existing bubbles
        let position = CGPoint(x: xPosition, y: yPosition)
        if isPositionOverlapping(position, size: bubbleSize) {
            return nil // Position is not valid
        }
        
        // Create bubble with random movement direction
        let dx = CGFloat.random(in: -2...2)
        let dy = CGFloat.random(in: -2...2)
        let direction = CGVector(dx: dx, dy: dy)
        
        // Create the bubble
        return Bubble(
            bubbleColor: bubbleColor,
            position: position,
            size: bubbleSize,
            direction: direction
        )
    }
    
    private func determineBubbleColor() -> BubbleColor {
        let random = Double.random(in: 0...1)
        
        // Determine bubble color based on probability
        if random < 0.40 {
            return .red
        } else if random < 0.70 {
            return .pink
        } else if random < 0.85 {
            return .green
        } else if random < 0.95 {
            return .blue
        } else {
            return .black
        }
    }
    
    private func isPositionOverlapping(_ position: CGPoint, size: CGFloat) -> Bool {
        for bubble in bubbles {
            let distance = sqrt(pow(position.x - bubble.position.x, 2) + pow(position.y - bubble.position.y, 2))
            if distance < (size + bubble.size) / 2 {
                return true // Overlap detected
            }
        }
        return false
    }
    
    func removeBubble(_ bubble: Bubble) {
        bubbles.removeAll { $0.id == bubble.id }
    }
    
    func startBubbleMovement() {
        bubbleMovementTimer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { [weak self] _ in
            self?.moveBubbles()
        }
    }
    
    func stopBubbleMovement() {
        bubbleMovementTimer?.invalidate()
        bubbleMovementTimer = nil
    }
    
    func moveBubbles() {
        guard !bubbles.isEmpty else { return }
        
        // Calculate speed based on remaining time
        let timeRatio = Double(gameState.timeRemaining) / Double(gameSettings.gameTime)
        let speedFactor = 1.0 + (1.0 - timeRatio) * bubbleSpeedMultiplier
        
        // Move each bubble
        for i in 0..<bubbles.count {
            var bubble = bubbles[i]
            
            // Calculate new position
            let dx = bubble.direction.dx * speedFactor
            let dy = bubble.direction.dy * speedFactor
            var newPosition = CGPoint(x: bubble.position.x + dx, y: bubble.position.y + dy)
            
            // Check if bubble hits the edge of the screen
            let radius = bubble.size / 2
            
            // Bounce off walls
            if newPosition.x - radius < 0 || newPosition.x + radius > screenWidth {
                bubble.direction.dx *= -1
                newPosition.x = bubble.position.x + bubble.direction.dx * speedFactor
            }
            
            if newPosition.y - radius < 0 || newPosition.y + radius > screenHeight {
                bubble.direction.dy *= -1
                newPosition.y = bubble.position.y + bubble.direction.dy * speedFactor
            }
            
            // Update bubble position
            bubble.position = newPosition
            bubbles[i] = bubble
        }
    }
    
    func clearBubbles() {
        bubbles = []
    }
}
