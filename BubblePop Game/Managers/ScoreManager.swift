//
//  ScoreManager.swift
//  BubblePop Game
//
//  Created by Mason Foreman on 28/3/2025.
//

import Foundation
import Combine
import SwiftUI

class ScoreManager: ObservableObject {
    @Published var currentScore: Int = 0
    @Published var comboCount: Int = 0
    @Published var lastPoppedColor: BubbleColor?
    
    let gameState: GameState
    let animationManager: AnimationManager
    
    init(gameState: GameState, animationManager: AnimationManager) {
        self.gameState = gameState
        self.animationManager = animationManager
    }
    
    func resetScore() {
        currentScore = 0
        comboCount = 0
        lastPoppedColor = nil
    }
    
    func calculatePoints(for bubble: Bubble) -> Int {
        // Get base points based on bubble color
        let basePoints = bubble.pointValue
        
        // Check for combo (same color bubbles popped consecutively)
        if let lastColor = lastPoppedColor, lastColor == bubble.color {
            // Increment combo count for same color
            comboCount += 1
            
            // Apply 1.5x multiplier for consecutive bubbles of same color
            let comboPoints = Int(Double(basePoints) * 1.5)
            
            // Animate combo
            if comboCount > 1 {
                let comboText = "x\(comboCount) COMBO!"
                animationManager.showScorePopup(
                    text: comboText,
                    position: CGPoint(x: bubble.position.x, y: bubble.position.y - 30),
                    color: .orange
                )
            }
            
            // Show score popup with bonus indication
            animationManager.showScorePopup(
                text: "+\(comboPoints)",
                position: bubble.position,
                color: .yellow
            )
            
            return comboPoints
        } else {
            // Reset combo count for new color
            comboCount = 1
            
            // Show regular score popup
            animationManager.showScorePopup(
                text: "+\(basePoints)",
                position: bubble.position,
                color: convertToUIColour(bubble.color)
            )
            
            return basePoints
        }
    }

    // Helper method to convert BubbleColor to SwiftUI Color
    private func convertToUIColour(_ bubbleColour: BubbleColor) -> Color {
        return bubbleColour.color // Use BubbleColor's color property
    }

    func addPoints(for bubble: Bubble) {
        // Update last popped color before calculating points
        lastPoppedColor = bubble.color
        
        // Calculate points (with combo if applicable)
        let points = calculatePoints(for: bubble)
        
        // Update scores
        currentScore += points
        gameState.currentScore = currentScore
        
        // Update last popped color in game state for persistence
        gameState.lastPoppedColor = bubble.color
    }
}
