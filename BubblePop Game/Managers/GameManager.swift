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

/// Main manager class that coordinates the game flow and state
@MainActor
class GameManager: ObservableObject {
    // MARK: - Properties
    
    // Define a local enum for navigation to avoid ambiguity
    enum NavDestination {
        case game
        case highScores
        case settings
    }
    
    /// Navigation path for app navigation
    @Published var navigationPath: [AppView] = []
    
    /// Main game state object that holds all game data
    @Published var gameState: GameState!
    
    // Managers for different game aspects
    
    /// Manager for game sound effects and music
    let soundManager: SoundManager
    
    /// Manager for animations (bubble pops, score popups)
    let animationManager: AnimationManager
    
    /// Manager for high scores and leaderboard
    let leaderboardManager: LeaderboardManager
    
    /// Manager for scoring logic
    var scoreManager: ScoreManager!
    
    /// Manager for bubble creation and movement
    var bubbleManager: BubbleManager!
    
    // MARK: - Initialization
    
    /// Initialize the game manager with game settings
    init(gameSettings: GameSettings) {
        // Create managers that don't depend on gameState first
        let animationManager = AnimationManager()
        self.animationManager = animationManager
        
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
    
    // MARK: - Game Flow Methods
    
    /// Start the game by initializing state and navigating to game screen
    func startGame() {
        // Set the current view to game view
        navigationPath.append(toAppView(.game))
        
        // Initialize game state but don't start running yet
        gameState.initializeGame()
        
        // Create initial bubbles but don't start movement yet
        bubbleManager.createBubbles()
        
        // Don't start the game's internal timer yet
        // gameState.startGame() will be called after countdown
        
        // Don't play background music yet
        // soundManager.playBackgroundMusic() will be called after countdown
        
        print("Game initialized: timeRemaining = \(gameState.timeRemaining), bubbles = \(gameState.bubbles.count)")
    }
    
    /// Begin the actual gameplay after countdown finishes
    func beginActualGame() {
        // Start the game's internal timer
        gameState.startGame()
        
        // Start bubble movement
        bubbleManager.startBubbleMovement()
        
        // Play background music
        soundManager.playBackgroundMusic()
        
        print("Game actually started: timeRemaining = \(gameState.timeRemaining), bubbles = \(gameState.bubbles.count)")
    }
    
    /// Update game state every second
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
    
    /// Handle popping a bubble when player taps it
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
    
    /// End the game and clean up resources
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
    
    // MARK: - Navigation Methods
    
    /// Navigate to high scores screen
    func showHighScores() {
        navigationPath.append(toAppView(.highScores))
    }
    
    /// Navigate to settings screen
    func showSettings() {
        navigationPath.append(toAppView(.settings))
    }
    
    /// Go back to previous screen
    func goBack() {
        navigationPath.removeLast()
    }
    
    /// Reset the game state to start a new game
    func resetGame() {
        gameState.resetGame()
        scoreManager.resetScore()
        bubbleManager.clearBubbles()
    }
    
    // Method to convert our NavDestination to AppView
    private func toAppView(_ dest: NavDestination) -> AppView {
        switch dest {
        case .game: return .game
        case .highScores: return .highScores
        case .settings: return .settings
        }
    }
}
