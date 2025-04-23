//
//  GameManager.swift
//  BubblePop Game
//
//  Created by Mason Foreman on 28/3/2025.
//

import Foundation
import SwiftUI
import Combine
import GameKit

@MainActor
// Create a class that doesn't require GameState during initialization
class GameManager: ObservableObject {
    @Published var navigationPath: [AppView] = []
    @Published var gameState: GameState! // Make it implicitly unwrapped optional
    
    // Other managers
    let soundManager: SoundManager
    let animationManager: AnimationManager
    let leaderboardManager: LeaderboardManager
    var scoreManager: ScoreManager!
    var bubbleManager: BubbleManager!
    
    init(gameSettings: GameSettings) {
        // Create managers that don't depend on gameState first
        let animationManager = AnimationManager()
        self.animationManager = animationManager
        
        let soundManager = SoundManager(gameSettings: gameSettings)
        self.soundManager = SoundManager(gameSettings: gameSettings)
        self.leaderboardManager = LeaderboardManager()
        
        // Create gameState
        self.gameState = GameState(
            gameSettings: gameSettings,
            animationManager: animationManager,
            soundManager: soundManager
        )
        
        // Now initialize managers that depend on gameState
        self.scoreManager = ScoreManager(gameState: gameState, animationManager: animationManager)
        self.bubbleManager = BubbleManager(gameSettings: gameSettings, gameState: gameState)
        
        // Link all managers to the game state
        gameState.bubbleManager = bubbleManager
        gameState.scoreManager = scoreManager
        gameState.leaderboardManager = leaderboardManager
        gameState.soundManager = soundManager
        gameState.animationManager = animationManager
        
        // Update highest score on init
        gameState.highestScore = leaderboardManager.getHighestScore()
    }
    
    func startGame() {
        // Set the current view to game view
        navigationPath.append(.game)
        
        // Reset game state
        gameState.resetGame()
        
        // Initialize game
        gameState.gameRunning = true
        gameState.timeRemaining = gameState.gameSettings.gameTime
        gameState.isGameActive = true
        
        // Create initial bubbles
        bubbleManager.createBubbles()
        
        // Start bubble movement
        bubbleManager.startBubbleMovement()
        
        // Start the game's internal timer
        gameState.startGame()
        
        // Play background music
        soundManager.playBackgroundMusic()
        
        print("Game started: timeRemaining = \(gameState.timeRemaining), bubbles = \(gameState.bubbles.count)")
    }
    
    func updateGame() {
        // Update game timer
        if gameState.timeRemaining > 0 {
            gameState.timeRemaining -= 1
        }
        
        // Refresh bubbles every second
        bubbleManager.refreshBubbles()
        
        // Update bubble speed based on remaining time
        bubbleManager.updateBubbleSpeed()
        
        // Update animation states
        animationManager.updateAnimations()
    }
    
    func popBubble(_ bubble: Bubble) {
        // Add points
        scoreManager.addPoints(for: bubble)
        
        // Remove bubble
        bubbleManager.removeBubble(bubble)
        
        // Play sound
        soundManager.playPopSound()
        
        // Show animation
        animationManager.animateBubblePop(
            at: bubble.position,
            color: bubble.color.color,
            size: bubble.size
        )
        
        // Check if all bubbles are gone
        if gameState.bubbles.isEmpty {
            // Generate new bubbles
            bubbleManager.refreshBubbles()
            
            // If we still couldn't create any bubbles after refresh, end the game
            if gameState.bubbles.isEmpty && gameState.timeRemaining > 0 {
                endGame()
            }
        }
    }
    
    func endGame() {
        gameState.gameRunning = false
        gameState.isGameActive = false
        
        // Stop bubble movement
        bubbleManager.stopBubbleMovement()
        
        // Stop background music
        soundManager.stopBackgroundMusic()
        
        // Save score with game settings
        leaderboardManager.addScore(
            player: gameState.player.name,
            score: gameState.currentScore,
            gameSettings: gameState.gameSettings
        )
        
        // If GameKit is authenticated, we've already reported the score in leaderboardManager.addScore
        
        // Clear bubbles
        bubbleManager.clearBubbles()
    }
    
    func showHighScores() {
        navigationPath.append(.highScores)
    }
    
    func showSettings() {
        navigationPath.append(.settings)
    }
    
    func goBack() {
        navigationPath.removeLast()
    }
    
    func resetGame() {
        gameState.resetGame()
        scoreManager.resetScore()
        bubbleManager.clearBubbles()
    }
}
