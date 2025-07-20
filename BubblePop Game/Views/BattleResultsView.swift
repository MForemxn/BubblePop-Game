//
//  BattleResultsView.swift
//  BubblePop Game
//
//  Created by Assistant on 20/7/2025.
//

import SwiftUI

struct BattleResultsView: View {
    let battleResult: BattleResult
    let playerName: String
    let opponentName: String
    let gameSettings: GameSettings
    let onPlayAgain: () -> Void
    let onShareResults: () -> Void
    let onBackToMenu: () -> Void
    
    @State private var showingConfetti = false
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.blue.opacity(0.3),
                    Color.purple.opacity(0.3)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 30) {
                // Result Header
                VStack(spacing: 10) {
                    resultIcon
                    
                    Text(resultTitle)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Text(resultSubtitle)
                        .font(.title2)
                        .foregroundColor(.secondary)
                }
                
                // Score Display
                VStack(spacing: 20) {
                    scoreCard(
                        name: playerName,
                        score: myScore,
                        isWinner: isPlayerWinner,
                        isPlayer: true
                    )
                    
                    Text("VS")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.secondary)
                    
                    scoreCard(
                        name: opponentName,
                        score: opponentScore,
                        isWinner: !isPlayerWinner && !isTie,
                        isPlayer: false
                    )
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 15)
                        .fill(Color(UIColor.secondarySystemBackground))
                        .shadow(radius: 5)
                )
                
                // Game Info
                VStack(spacing: 8) {
                    HStack {
                        Text("Difficulty:")
                        Spacer()
                        Text(gameSettings.difficulty.rawValue.capitalized)
                            .fontWeight(.medium)
                    }
                    
                    HStack {
                        Text("Duration:")
                        Spacer()
                        Text("\(gameSettings.gameTime) seconds")
                            .fontWeight(.medium)
                    }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color(UIColor.tertiarySystemBackground))
                )
                
                Spacer()
                
                // Action Buttons
                VStack(spacing: 15) {
                    HStack(spacing: 15) {
                        Button(action: onPlayAgain) {
                            HStack {
                                Image(systemName: "arrow.clockwise")
                                Text("Play Again")
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                        }
                        
                        Button(action: onShareResults) {
                            HStack {
                                Image(systemName: "square.and.arrow.up")
                                Text("Share Results")
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                        }
                    }
                    
                    Button(action: onBackToMenu) {
                        Text("Back to Menu")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.gray)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }
            }
            .padding()
            
            // Confetti Effect
            if showingConfetti && isPlayerWinner {
                ConfettiView()
            }
        }
        .onAppear {
            if isPlayerWinner {
                showingConfetti = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    showingConfetti = false
                }
            }
        }
    }
    
    // MARK: - Computed Properties
    
    private var resultIcon: some View {
        Group {
            switch battleResult {
            case .won:
                Image(systemName: "crown.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.yellow)
            case .lost:
                Image(systemName: "hand.thumbsdown.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.red)
            case .tie:
                Image(systemName: "equal")
                    .font(.system(size: 60))
                    .foregroundColor(.orange)
            }
        }
    }
    
    private var resultTitle: String {
        switch battleResult {
        case .won:
            return "Victory! 🎉"
        case .lost:
            return "Good Try! 💪"
        case .tie:
            return "It's a Tie! 🤝"
        }
    }
    
    private var resultSubtitle: String {
        switch battleResult {
        case .won:
            return "You popped your way to victory!"
        case .lost:
            return "Better luck next time!"
        case .tie:
            return "Great minds think alike!"
        }
    }
    
    private var myScore: Int {
        switch battleResult {
        case .won(let myScore, _), .lost(let myScore, _):
            return myScore
        case .tie(let score):
            return score
        }
    }
    
    private var opponentScore: Int {
        switch battleResult {
        case .won(_, let opponentScore), .lost(_, let opponentScore):
            return opponentScore
        case .tie(let score):
            return score
        }
    }
    
    private var isPlayerWinner: Bool {
        if case .won = battleResult {
            return true
        }
        return false
    }
    
    private var isTie: Bool {
        if case .tie = battleResult {
            return true
        }
        return false
    }
    
    // MARK: - Helper Views
    
    private func scoreCard(name: String, score: Int, isWinner: Bool, isPlayer: Bool) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 5) {
                HStack {
                    Text(name)
                        .font(.headline)
                        .fontWeight(.bold)
                    
                    if isPlayer {
                        Text("(You)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    if isWinner {
                        Image(systemName: "crown.fill")
                            .foregroundColor(.yellow)
                            .font(.caption)
                    }
                }
                
                Text("\(score) points")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(isWinner ? .green : .primary)
            }
            
            Spacer()
            
            if isWinner {
                Text("WINNER")
                    .font(.caption)
                    .fontWeight(.bold)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(5)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(isWinner ? Color.green.opacity(0.1) : Color.clear)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(isWinner ? Color.green : Color.gray.opacity(0.3), lineWidth: 1)
                )
        )
    }
}

// MARK: - Confetti View
struct ConfettiView: View {
    @State private var animate = false
    
    var body: some View {
        ZStack {
            ForEach(0..<50, id: \.self) { index in
                Rectangle()
                    .fill(randomColor())
                    .frame(width: 10, height: 10)
                    .rotationEffect(.degrees(animate ? 360 : 0))
                    .offset(
                        x: animate ? randomOffset() : 0,
                        y: animate ? randomOffset() : -100
                    )
                    .opacity(animate ? 0 : 1)
                    .animation(
                        .easeOut(duration: 2.5)
                        .delay(Double(index) * 0.05),
                        value: animate
                    )
            }
        }
        .onAppear {
            animate = true
        }
    }
    
    private func randomColor() -> Color {
        let colors: [Color] = [.red, .blue, .green, .yellow, .orange, .purple, .pink]
        return colors.randomElement() ?? .blue
    }
    
    private func randomOffset() -> CGFloat {
        return CGFloat.random(in: -200...200)
    }
}

#Preview {
    BattleResultsView(
        battleResult: .won(myScore: 1250, opponentScore: 980),
        playerName: "Player1",
        opponentName: "Player2",
        gameSettings: GameSettings(),
        onPlayAgain: {},
        onShareResults: {},
        onBackToMenu: {}
    )
}