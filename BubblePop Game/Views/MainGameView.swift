//
//  MainGameView.swift
//  BubblePop Game
//
//  Created by Mason Foreman on 28/3/2025.
//

import SwiftUI

struct MainGameView: View {
    @ObservedObject var gameState: GameState
    @State private var showCountdown = true
    @State private var timeRemaining = 3
    @State private var gameOverPopup = false
    @State private var countdownTimer: Timer?
    
    @ObservedObject var gameManager: GameManager
    let gameTimer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color(UIColor.systemBackground)
                    .ignoresSafeArea()
                
                // Game information at the top
                VStack {
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Player: \(gameState.playerName)")
                                .font(.headline)
                            Text("Highest Score: \(gameState.highestScore)")
                                .font(.subheadline)
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .trailing) {
                            Text("Score: \(gameState.currentScore)")
                                .font(.headline)
                            Text("Time: \(gameState.timeRemaining)")
                                .font(.subheadline)
                                .foregroundColor(gameState.timeRemaining <= 10 ? .red : .primary)
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color(UIColor.secondarySystemBackground))
                    )
                    .padding([.horizontal, .top])
                    
                    Spacer()
                }
                
                // Bubbles
                ForEach(gameState.bubbles) { bubble in
                    BubbleView(bubble: bubble)
                        .position(bubble.position)
                        .onTapGesture {
                            if let index = gameState.bubbles.firstIndex(where: { $0.id == bubble.id }) {
                                gameManager.popBubble(bubble)
                            }
                        }
                }
                
                // Score popup animations
                ForEach(gameState.animationManager.scorePopups) { popup in
                    Text(popup.text)
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(popup.color)
                        .position(popup.position)
                        .opacity(popup.opacity)
                        .scaleEffect(popup.scale)
                }
                
                // Bubble pop animations
                ForEach(gameState.animationManager.bubblePopAnimations) { anim in
                    Circle()
                        .fill(anim.color)
                        .frame(width: anim.size, height: anim.size)
                        .position(anim.position)
                        .opacity(anim.opacity)
                        .scaleEffect(anim.scale)
                }
                
                // Countdown overlay
                if showCountdown {
                    CountdownView(timeRemaining: $timeRemaining)
                }
                
                // Game over popup
                if gameOverPopup {
                    VStack {
                        Text("Game Over!")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .padding()
                        
                        Text("Your score: \(gameState.currentScore)")
                            .font(.title2)
                            .padding()
                        
                        Button(action: {
                            gameOverPopup = false
                            gameManager.showHighScores()
                        }) {
                            Text("View High Scores")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.blue)
                                .cornerRadius(10)
                        }
                        .padding()
                    }
                    .frame(width: 300, height: 250)
                    .background(Color(UIColor.systemBackground))
                    .cornerRadius(20)
                    .shadow(radius: 10)
                }
            }
            .onAppear {
                gameManager.gameState.updateScreenSize(geometry.size)
                if !gameState.gameRunning {
                    DispatchQueue.main.async {
                        self.startCountdown()
                    }
                }
            }
            .onDisappear {
                countdownTimer?.invalidate()
                countdownTimer = nil
                gameManager.endGame()
            }
            .onReceive(gameTimer) { _ in
                if !showCountdown && gameState.gameRunning {
                    print("Game timer fired: timeRemaining = \(gameState.timeRemaining)")
                    gameManager.updateGame()
                }
                if gameState.timeRemaining <= 0 && !gameOverPopup && !showCountdown {
                    gameEnd()
                }
            }
        }
    }
    
    func startCountdown() {
        showCountdown = true
        timeRemaining = 3
        
        countdownTimer?.invalidate()
        
        DispatchQueue.main.async {
            self.countdownTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] timer in
                guard let self = self else {
                    timer.invalidate()
                    return
                }
                
                print("Countdown timer: \(self.timeRemaining)")
                
                if self.timeRemaining > 1 {
                    self.timeRemaining -= 1
                } else {
                    timer.invalidate()
                    self.countdownTimer = nil
                    self.showCountdown = false
                    
                    DispatchQueue.main.async {
                        self.gameManager.startGame()
                    }
                }
            }
            
            RunLoop.main.add(self.countdownTimer!, forMode: .common)
        }
    }
    
    func gameEnd() {
        gameManager.endGame()
        gameState.gameRunning = false
        gameOverPopup = true
    }
}

struct BubbleView: View {
    let bubble: Bubble
    
    var body: some View {
        Circle()
            .fill(bubble.color.color)
            .frame(width: bubble.size, height: bubble.size)
            .shadow(color: .black.opacity(0.3), radius: 2, x: 1, y: 1)
    }
}
