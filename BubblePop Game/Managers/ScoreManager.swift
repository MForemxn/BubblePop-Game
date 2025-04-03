//
//  ScoreManager.swift
//  BubblePop Game
//
//  Created by Mason Foreman on 28/3/2025.
//

import Foundation
import Combine

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
        let basePoints = bubble.points
        
        // Check for combo (same color bubbles popped consecutively)
        if let lastColor = lastPoppedColor, lastColor == bubble.bubbleColor {
            comboCount += 1
            
            // Apply combo multiplier
            let comboPoints = Int(Double(basePoints) * 1.5)
            
            // Animate combo
            if comboCount > 1 {
                animationManager.showScorePopup(text: "x\(comboCount) COMBO!", position: bubble.position, color: .orange)
            }
            
            return comboPoints
        } else {
            // Reset combo count
            comboCount = 1
            return basePoints
        }
    }
    
    func addPoints(for bubble: Bubble) {
        let points = calculatePoints(for: bubble)
        currentScore += points
        gameState.score = currentScore
        
        // Update last popped color
        lastPoppedColor = bubble.bubbleColor
        
        // Show score popup animation
        animationManager.showScorePopup(text: "+\(points)", position: bubble.position, color: bubble.color)
    }
}
