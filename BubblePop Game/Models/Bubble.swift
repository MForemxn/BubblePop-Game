//
//  Bubble.swift
//  BubblePop Game
//
//  Created by Mason Foreman on 28/3/2025.
//


import SwiftUI

enum BubbleColor: String, CaseIterable {
    case red, pink, green, blue, black
    
    var color: Color {
        switch self {
        case .red: return .red
        case .pink: return .pink
        case .green: return .green
        case .blue: return .blue
        case .black: return .black
        }
    }
    
    var pointValue: Int {
        switch self {
        case .red: return 1
        case .pink: return 2
        case .green: return 5
        case .blue: return 8
        case .black: return 10
        }
    }
    
    var probability: Double {
        switch self {
        case .red: return 0.4
        case .pink: return 0.3
        case .green: return 0.15
        case .blue: return 0.1
        case .black: return 0.05
        }
    }
    
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

struct Bubble: Identifiable {
    let id = UUID()
    let color: BubbleColor
    let size: CGFloat
    let position: CGPoint
    var velocity: CGPoint = CGPoint(x: Double.random(in: -50...50), y: Double.random(in: -50...50))
    var isActive: Bool = true
    
    var pointValue: Int {
        return color.pointValue
    }
    
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
