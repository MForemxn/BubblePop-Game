//
//  ScoreManager.swift
//  BubblePop Game
//
//  Created by Mason Foreman on 28/3/2025.
//

import Foundation
import Combine
import SwiftUI // Added to use Color

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
        let basePoints = getBasePoints(for: bubble.color)
        
        // Check for combo (same color bubbles popped consecutively)
        if let lastColor = lastPoppedColor, lastColor == bubble.color {
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

    // Helper method to assign point values based on bubble color
    private func getBasePoints(for color: BubbleColor) -> Int {
        switch color {
        case .red:
            return 1
        case .pink:
            return 2
        case .green:
            return 5
        case .blue:
            return 8
        case .black:
            return 10
        }
    }

    func addPoints(for bubble: Bubble) {
        let points = calculatePoints(for: bubble)
        currentScore += points
        gameState.score = currentScore
        
        // Update last popped color
        lastPoppedColor = bubble.color
        
        // Show score popup animation
        // Convert BubbleColor to SwiftUI Color for the animation
        let uiColor = convertToUIColour(bubble.color)
        animationManager.showScorePopup(text: "+\(points)", position: bubble.position, color: uiColor)
    }

    // Helper method to convert BubbleColor to SwiftUI Color
    private func convertToUIColour(_ bubbleColour: BubbleColor) -> Color {
        switch bubbleColour { // Changed from bubbleColor to bubbleColour
        case .red:
            return .red
        case .pink:
            return .pink
        case .green:
            return .green
        case .blue:
            return .blue
        case .black:
            return .black
        }
    }
}
