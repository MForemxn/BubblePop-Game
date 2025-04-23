//
//  Bubble.swift
//  BubblePop Game
//
//  Created by Mason Foreman on 28/3/2025.
//

import SwiftUI

/// Different types of bubbles with their own colors and point values
enum BubbleColor: String, CaseIterable {
    case red, pink, green, blue, black
    
    /// The actual SwiftUI color to display
    var color: Color {
        switch self {
        case .red: return .red
        case .pink: return .pink
        case .green: return .green
        case .blue: return .blue
        case .black: return .black
        }
    }
    
    /// Points earned when popping this bubble
    var pointValue: Int {
        switch self {
        case .red: return 1    // Most common, lowest points
        case .pink: return 2
        case .green: return 5
        case .blue: return 8
        case .black: return 10 // Rarest, highest points
        }
    }
    
    /// Probability of this bubble appearing (must add up to 1.0)
    var probability: Double {
        switch self {
        case .red: return 0.4  // 40% chance
        case .pink: return 0.3 // 30% chance
        case .green: return 0.15 // 15% chance
        case .blue: return 0.1  // 10% chance
        case .black: return 0.05 // 5% chance
        }
    }
    
    /// Get a random bubble color based on probability distribution
    static func randomBubbleColor() -> BubbleColor {
        let random = Double.random(in: 0...1)
        var cumulativeProbability = 0.0
        
        for color in BubbleColor.allCases {
            cumulativeProbability += color.probability
            if random < cumulativeProbability {
                return color
            }
        }
        
        return .red // Default fallback
    }
}

/// Represents a bubble in the game
struct Bubble: Identifiable {
    /// Unique identifier for the bubble
    let id: UUID
    
    /// Color of the bubble
    let color: BubbleColor
    
    /// Size of the bubble in points
    let size: CGFloat
    
    /// Current position on screen
    var position: CGPoint
    
    /// Current movement velocity (speed and direction)
    var velocity: CGPoint
    
    /// Whether the bubble is active in the game
    var isActive: Bool
    
    /// Points earned when this bubble is popped
    var pointValue: Int {
        return color.pointValue
    }
    
    /// Create a new bubble
    init(
        id: UUID = UUID(),
        color: BubbleColor,
        size: CGFloat,
        position: CGPoint,
        velocity: CGPoint = CGPoint(x: Double.random(in: -50...50), y: Double.random(in: -50...50)),
        isActive: Bool = true
    ) {
        self.id = id
        self.color = color
        self.size = size
        self.position = position
        self.velocity = velocity
        self.isActive = isActive
    }
    
    /// Try to generate a random bubble that doesn't overlap with existing bubbles
    static func generateRandomBubble(in size: CGSize, existingBubbles: [Bubble], bubbleSize: CGFloat) -> Bubble? {
        let maxAttempts = 100
        var attempts = 0
        
        while attempts < maxAttempts {
            attempts += 1
            
            // Generate random position ensuring entire bubble is on screen
            let padding = bubbleSize / 2
            let xPosition = CGFloat.random(in: padding...(size.width - padding))
            let yPosition = CGFloat.random(in: padding...(size.height - padding))
            let position = CGPoint(x: xPosition, y: yPosition)
            
            // Check for overlaps with existing bubbles
            let hasOverlap = existingBubbles.contains { existingBubble in
                let distance = hypot(existingBubble.position.x - position.x,
                                     existingBubble.position.y - position.y)
                return distance < (bubbleSize + existingBubble.size) / 2
            }
            
            if !hasOverlap {
                // Create the bubble with random color and velocity
                return Bubble(
                    color: BubbleColor.randomBubbleColor(),
                    size: bubbleSize,
                    position: position
                )
            }
        }
        
        return nil // Could not find non-overlapping position
    }
}
