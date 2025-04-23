//
//  GameState.swift
//  BubblePop Game
//
//  Created by Mason Foreman on 28/3/2025.
//

import Foundation
import SwiftUI
import Combine

class GameState: ObservableObject {
    
    @Published var gameRunning: Bool = false
    @Published var timeRemaining: Int = 0
    @Published var bubbles: [Bubble] = []
    @Published var playerName: String = ""
    @Published var currentScore: Int = 0
    @Published var isGameActive: Bool = false
    @Published var gameOver: Bool = false
    @Published var lastPoppedColor: BubbleColor? = nil
    @Published var consecutiveSameColorPops: Int = 0
    @Published var highestScore: Int = 0

    private var timer: Timer?
    private var bubbleRefreshTimer: Timer?
    let gameSettings: GameSettings // Made public
    private var screenSize: CGSize = .zero
    private var cancellables = Set<AnyCancellable>()

    var bubbleManager: BubbleManager!
    var scoreManager: ScoreManager!
    var leaderboardManager: LeaderboardManager!
    var soundManager: SoundManager!
    var animationManager: AnimationManager!
    var player = Player(name: "", score: 0, date: Date())

    init(gameSettings: GameSettings, animationManager: AnimationManager, soundManager: SoundManager) {
        self.gameSettings = gameSettings
        self.animationManager = animationManager
        self.soundManager = soundManager
        self.timeRemaining = gameSettings.gameTime // Initialize with gameSettings
        loadHighestScore()
    }

    func resetGame() {
        currentScore = 0
        timeRemaining = gameSettings.gameTime
        isGameActive = false
        gameOver = false
        bubbles = []
        lastPoppedColor = nil
        consecutiveSameColorPops = 0

        timer?.invalidate()
        timer = nil

        bubbleRefreshTimer?.invalidate()
        bubbleRefreshTimer = nil
    }

    
    var comboMultiplier: Double {
        return consecutiveSameColorPops > 0 ? 1.5 : 1.0
    }

    func loadHighestScore() {
        let players = Player.loadPlayers()
        highestScore = players.map { $0.score }.max() ?? 0
    }

    func startGame() {
        resetGame()
        isGameActive = true
        gameRunning = true
        timeRemaining = gameSettings.gameTime

        // Set up the game timer
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self, self.isGameActive else { return }
            
            if self.timeRemaining > 0 {
                self.timeRemaining -= 1
                print("GameState timer tick: \(self.timeRemaining) seconds left")
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
    
    func refreshBubbles() {
        Task { @MainActor in
            self.bubbleManager.refreshBubbles()
        }
    }

    func updateScreenSize(_ size: CGSize) {
            screenSize = size
        }

    func refreshments() {
        guard isGameActive else { return }

        // Remove some random bubbles
        let numberOfBubblesToRemove = Int.random(in: 0...min(3, bubbles.count))
        if numberOfBubblesToRemove > 0 {
            let indicesToRemove = (0..<bubbles.count).shuffled().prefix(numberOfBubblesToRemove)
            bubbles = bubbles.enumerated().filter { !indicesToRemove.contains($0.offset) }.map { $0.element }
        }

        // Add new bubbles
        let currentBubbleCount = bubbles.count
        let numberOfBubblesToAdd = Int.random(in: 0...(gameSettings.maxBubbles - currentBubbleCount))

        for _ in 0..<numberOfBubblesToAdd {
            if let newBubble = Bubble.generateRandomBubble(
                in: screenSize,
                existingBubbles: bubbles,
                bubbleSize: 60
            ) {
                bubbles.append(newBubble)
            }
        }
    }

    func updateBubblePositions(deltaTime: TimeInterval) {
        bubbles = bubbles.map { bubble in
            var newBubble = bubble

            // Update position based on velocity
            var newX = bubble.position.x + bubble.velocity.x * CGFloat(deltaTime)
            var newY = bubble.position.y + bubble.velocity.y * CGFloat(deltaTime)

            // Simple boundary checking and bounce physics
            if newX < bubble.size/2 || newX > screenSize.width - bubble.size/2 {
                newBubble.velocity.x = -bubble.velocity.x
            }

            if newY < bubble.size/2 || newY > screenSize.height - bubble.size/2 {
                newBubble.velocity.y = -bubble.velocity.y
            }

            // Apply the new position
            newBubble.position = CGPoint(
                x: max(bubble.size/2, min(newX, screenSize.width - bubble.size/2)),
                y: max(bubble.size/2, min(newY, screenSize.height - bubble.size/2))
            )

            return newBubble
        }
    }

    func updateBubbleVelocities() {
        let timeRatio = Double(timeRemaining) / Double(gameSettings.gameTime)
        let speedFactor = 1.0 + (1.0 - timeRatio) * 2.0 // Speed increases as time decreases

        bubbles = bubbles.map { bubble in
            var newBubble = bubble
            let originalSpeed = hypot(bubble.velocity.x, bubble.velocity.y)

            if originalSpeed > 0 {
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

    func endGame() {
        isGameActive = false
        gameRunning = false
        gameOver = true

        timer?.invalidate()
        timer = nil

        bubbleRefreshTimer?.invalidate()
        bubbleRefreshTimer = nil

        // Save the player's score - this is now handled by GameManager
        let player = Player(name: playerName, score: currentScore, date: Date())
        Player.savePlayer(player)

        // Score is reported to Game Center in LeaderboardManager

        // Update highest score if needed
        if currentScore > highestScore {
            highestScore = currentScore
        }
    }
    
}
