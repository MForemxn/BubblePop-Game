//
//  GameState.swift
//  BubblePop Game
//
//  Created by Mason Foreman on 28/3/2025.
//

import Foundation
import SwiftUI
import Combine

/// Stores and manages the current state of the game
class GameState: ObservableObject {
    // MARK: - Properties
    
    /// Whether the game is currently running
    @Published var gameRunning: Bool = false
    
    /// Time remaining in seconds
    @Published var timeRemaining: Int = 0
    
    /// List of active bubbles in the game
    @Published var bubbles: [Bubble] = []
    
    /// Name of the current player
    @Published var playerName: String = ""
    
    /// Current score for this game
    @Published var currentScore: Int = 0
    
    /// Whether the game is active (used for timers)
    @Published var isGameActive: Bool = false
    
    /// Whether the game is over
    @Published var gameOver: Bool = false
    
    /// Color of the last bubble that was popped (for combo tracking)
    @Published var lastPoppedColor: BubbleColor? = nil
    
    /// Counter for consecutive pops of the same color
    @Published var consecutiveSameColorPops: Int = 0
    
    /// Highest score achieved across all games
    @Published var highestScore: Int = 0

    /// Timer for game countdown
    private var timer: Timer?
    
    /// Timer for refreshing bubbles
    private var bubbleRefreshTimer: Timer?
    
    /// Game settings (difficulty, duration, etc.)
    let gameSettings: GameSettings
    
    /// Current screen size for bubble positioning
    @Published var screenSize: CGSize = .zero
    
    /// Current device orientation
    @Published var isLandscape: Bool = false
    
    /// Playable area accounting for layout in different orientations
    @Published var playableArea: CGRect = .zero

    /// Combine cancellables for managing subscriptions
    private var cancellables = Set<AnyCancellable>()

    // References to game managers
    var bubbleManager: BubbleManager!
    var scoreManager: ScoreManager!
    var leaderboardManager: LeaderboardManager!
    var soundManager: SoundManager!
    var animationManager: AnimationManager!
    
    /// Current player record
    var player = Player(name: "", score: 0, date: Date())

    // MARK: - Initialization
    
    /// Initialize game state with dependencies
    init(gameSettings: GameSettings, animationManager: AnimationManager, soundManager: SoundManager) {
        self.gameSettings = gameSettings
        self.animationManager = animationManager
        self.soundManager = soundManager
        self.timeRemaining = gameSettings.gameTime
        loadHighestScore()
    }

    // MARK: - Game Management
    
    /// Reset the game state to default values
    func resetGame() {
        currentScore = 0
        timeRemaining = gameSettings.gameTime
        isGameActive = false
        gameOver = false
        bubbles = []
        lastPoppedColor = nil
        consecutiveSameColorPops = 0

        // Stop timers
        timer?.invalidate()
        timer = nil

        bubbleRefreshTimer?.invalidate()
        bubbleRefreshTimer = nil
    }
    
    /// Score multiplier for consecutive same-color pops
    var comboMultiplier: Double {
        return consecutiveSameColorPops > 0 ? 1.5 : 1.0
    }

    /// Load the highest score from saved data
    func loadHighestScore() {
        let players = Player.loadPlayers()
        highestScore = players.map { $0.score }.max() ?? 0
    }

    /// Start the game timers and mechanics
    func startGame() {
        resetGame()
        isGameActive = true
        gameRunning = true
        timeRemaining = gameSettings.gameTime

        // Set up the game countdown timer
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self, self.isGameActive else { return }
            
            if self.timeRemaining > 0 {
                self.timeRemaining -= 1
                self.updateBubbleVelocities()
            } else {
                self.endGame()
            }
        }
        
        // Ensure timer runs even during scrolling
        RunLoop.main.add(timer!, forMode: .common)

        // Set up bubble refresh timer
        bubbleRefreshTimer?.invalidate()
        bubbleRefreshTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self, self.isGameActive else { return }
            
            Task { @MainActor in
                self.bubbleManager.refreshBubbles()
            }
        }
        
        // Ensure refresh timer runs even during scrolling
        RunLoop.main.add(bubbleRefreshTimer!, forMode: .common)

        // Initial bubble setup
        refreshBubbles()
    }
    
    /// Initialize game state before countdown
    func initializeGame() {
        resetGame()
        isGameActive = false
        gameRunning = false
        timeRemaining = gameSettings.gameTime
    }

    /// Refresh bubbles via bubble manager
    func refreshBubbles() {
        Task { @MainActor in
            self.bubbleManager.refreshBubbles()
        }
    }

    /// Update the screen size when device rotates or view appears
    func updateScreenSize(_ size: CGSize) {
        screenSize = size
        isLandscape = size.width > size.height
        
        // Calculate playable area based on orientation
        if isLandscape {
            // In landscape mode, account for side panel and safe areas
            let safeArea = UIApplication.shared.connectedScenes
                .compactMap { ($0 as? UIWindowScene)?.keyWindow?.safeAreaInsets }
                .first ?? .zero
            
            let leftInset = max(safeArea.left, 0)
            let rightInset = max(safeArea.right, 0)
            let topInset = max(safeArea.top, 0)
            let bottomInset = max(safeArea.bottom, 0)
            
            // Side panel takes 25% of width in landscape
            let sidePanel = size.width * 0.25
            
            playableArea = CGRect(
                x: sidePanel + leftInset,
                y: topInset,
                width: size.width - sidePanel - leftInset - rightInset,
                height: size.height - topInset - bottomInset
            )
        } else {
            // In portrait mode, account for header height and safe areas
            let safeArea = UIApplication.shared.connectedScenes
                .compactMap { ($0 as? UIWindowScene)?.keyWindow?.safeAreaInsets }
                .first ?? .zero
            
            let leftInset = max(safeArea.left, 0)
            let rightInset = max(safeArea.right, 0)
            let topInset = max(safeArea.top, 0) + 120 // Header height
            let bottomInset = max(safeArea.bottom, 0)
            
            playableArea = CGRect(
                x: leftInset,
                y: topInset,
                width: size.width - leftInset - rightInset,
                height: size.height - topInset - bottomInset
            )
        }
    }

    /// Update bubble positions based on velocity
    func updateBubblePositions(deltaTime: TimeInterval) {
        bubbles = bubbles.map { bubble in
            var newBubble = bubble

            // Update position based on velocity
            let newX = bubble.position.x + bubble.velocity.x * CGFloat(deltaTime)
            let newY = bubble.position.y + bubble.velocity.y * CGFloat(deltaTime)

            // Simple boundary checking and bounce physics
            let radius = bubble.size/2
            
            // Check for boundary collisions within playable area
            if newX - radius < playableArea.minX || newX + radius > playableArea.maxX {
                newBubble.velocity.x = -bubble.velocity.x
            }

            if newY - radius < playableArea.minY || newY + radius > playableArea.maxY {
                newBubble.velocity.y = -bubble.velocity.y
            }

            // Apply the new position, constrained to playable area
            newBubble.position = CGPoint(
                x: max(playableArea.minX + radius, min(newX, playableArea.maxX - radius)),
                y: max(playableArea.minY + radius, min(newY, playableArea.maxY - radius))
            )

            return newBubble
        }
    }

    /// Update bubble velocities based on remaining time
    func updateBubbleVelocities() {
        let timeRatio = Double(timeRemaining) / Double(gameSettings.gameTime)
        let speedFactor = 1.0 + (1.0 - timeRatio) * 2.0 // Speed increases as time decreases

        bubbles = bubbles.map { bubble in
            var newBubble = bubble
            let originalSpeed = hypot(bubble.velocity.x, bubble.velocity.y)

            if originalSpeed > 0 {
                // Maintain direction but increase speed
                let direction = CGVector(
                    dx: bubble.velocity.x / originalSpeed,
                    dy: bubble.velocity.y / originalSpeed
                )

                let newSpeed = originalSpeed * speedFactor
                newBubble.velocity = CGPoint(
                    x: direction.dx * newSpeed,
                    y: direction.dy * newSpeed
                )
            }

            return newBubble
        }
    }

    /// Pop a bubble at the specified index
    func popBubble(at index: Int) {
        guard index < bubbles.count else { return }

        let bubble = bubbles[index]

        // Handle combo bonus
        if let lastColor = lastPoppedColor, lastColor == bubble.color {
            consecutiveSameColorPops += 1
        } else {
            consecutiveSameColorPops = 0
        }

        // Update last popped color
        lastPoppedColor = bubble.color

        // Calculate points with combo
        let points = consecutiveSameColorPops > 0 ?
            Int(Double(bubble.pointValue) * comboMultiplier) :
            bubble.pointValue

        // Update score
        currentScore += points

        // Remove the bubble
        bubbles.remove(at: index)
    }

    /// End the game and handle cleanup
    func endGame() {
        isGameActive = false
        gameRunning = false
        gameOver = true

        // Stop timers
        timer?.invalidate()
        timer = nil

        bubbleRefreshTimer?.invalidate()
        bubbleRefreshTimer = nil

        // Save the player's score
        let player = Player(name: playerName, score: currentScore, date: Date())
        Player.savePlayer(player)

        // Update highest score if needed
        if currentScore > highestScore {
            highestScore = currentScore
        }
    }
}
