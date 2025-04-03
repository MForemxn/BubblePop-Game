//
//  GameManager.swift
//  BubblePop Game
//
//  Created by Mason Foreman on 28/3/2025.
//

import Foundation
import SwiftUI
import Combine

@MainActor
class GameManager: ObservableObject {
    @Published var currentView: AppView = .nameEntry
    
    let gameState: GameState
    let bubbleManager: BubbleManager
    let scoreManager: ScoreManager
    let leaderboardManager: LeaderboardManager
    let soundManager: SoundManager
    let animationManager: AnimationManager
    
    private var gameTimer: Timer?
    
    init(gameState: GameState, gameSettings: GameSettings) {
        self.gameState = gameState
        self.animationManager = AnimationManager()
        self.soundManager = SoundManager(gameSettings: gameSettings)
        self.scoreManager = ScoreManager(gameState: gameState, animationManager: animationManager)
        self.bubbleManager = BubbleManager(gameSettings: gameSettings, gameState: gameState)
        self.leaderboardManager = LeaderboardManager()
        
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
        // Reset game state
        gameState.resetGame()
        
        // Initialize game
        gameState.gameRunning = true
        gameState.timeRemaining = gameState.gameSettings.gameTime
        
        // Create initial bubbles
        bubbleManager.createBubbles()
        
        // Start bubble movement for extra functionality
        bubbleManager.startBubbleMovement()
        
        // Play background music
        soundManager.playBackgroundMusic()
    }
    
    func updateGame() {
        // Update game timer
        if gameState.timeRemaining > 0 {
            gameState.timeRemaining -= 1
        }
        
        // Refresh bubbles every second
        bubbleManager.updateBubbles()
        
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
        animationManager.animateBubblePop(at: bubble.position)
    }
    
    func endGame() {
        gameState.gameRunning = false
        
        // Stop bubble movement
        bubbleManager.stopBubbleMovement()
        
        // Stop background music
        soundManager.stopBackgroundMusic()
        
        // Save score
        leaderboardManager.addScore(player: gameState.player.name, score: gameState.score)
        
        // Clear bubbles
        bubbleManager.clearBubbles()
    }
    
    func showHighScores() {
        currentView = .highScores
    }
    
    func resetGame() {
        gameState.resetGame()
        scoreManager.resetScore()
        bubbleManager.clearBubbles()
    }
    
    enum AppView {
        case nameEntry
        case game
        case settings
        case highScores
    }
}
