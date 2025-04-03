//
//  NameEntryView.swift
//  BubblePop Game
//
//  Created by Mason Foreman on 28/3/2025.
//


import SwiftUI
import GameKit

struct NameEntryView: View {
    @Binding var playerName: String
    @ObservedObject var gameKitManager = GameKitManager.shared
    var onStartGame: () -> Void
    
    var body: some View {
        VStack(spacing: 30) {
            // Logo/title
            Text("🫧 BubblePop 🫧")
                .font(.system(size: 40, weight: .bold, design: .rounded))
                .foregroundColor(.blue)
                .shadow(color: .purple.opacity(0.5), radius: 5, x: 0, y: 2)
            
            // Name entry
            VStack(alignment: .leading, spacing: 10) {
                Text("Enter Your Name")
                    .font(.headline)
                    .padding(.leading, 5)
                
                TextField("Your name", text: $playerName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal, 5)
                    .autocapitalization(.words)
                    .onAppear {
                        // If authenticated, load Game Center alias
                        if gameKitManager.isAuthenticated {
                            playerName = gameKitManager.playerName
                        }
                    }
            }
            .padding(.horizontal)
            
            // Play button
            Button(action: {
                guard !playerName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
                onStartGame()
            }) {
                Text("Start Game")
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.blue, Color.purple]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .foregroundColor(.white)
                    .cornerRadius(15)
                    .shadow(radius: 5)
            }
            .padding(.horizontal)
            .disabled(playerName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            .opacity(playerName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 0.6 : 1)
            
            // Game instructions
            VStack(alignment: .leading, spacing: 15) {
                Text("How to Play:")
                    .font(.headline)
                
                VStack(alignment: .leading, spacing: 8) {
                    HStack(alignment: .top) {
                        Text("•")
                        Text("Tap bubbles to pop them and earn points")
                    }
                    
                    HStack(alignment: .top) {
                        Text("•")
                        Text("Pop the same color bubbles in sequence for bonus points")
                    }
                    
                    HStack(alignment: .top) {
                        Text("•")
                        Text("Bubble values: Red (1), Pink (2), Green (5), Blue (8), Black (10)")
                    }
                }
                .font(.subheadline)
                .foregroundColor(.secondary)
            }
            .padding()
            .background(Color.white.opacity(0.2))
            .cornerRadius(10)
            .padding(.horizontal)
            
            Spacer()
        }
        .padding(.top, 50)
        .background(
            Image(systemName: "bubble.left")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .foregroundColor(.blue.opacity(0.03))
                .rotationEffect(.degrees(45))
                .offset(x: 50, y: -100)
                .scaleEffect(5)
        )
    }
}

struct NameEntryView_Previews: PreviewProvider {
    static var previews: some View {
        NameEntryView(playerName: .constant("Player"), onStartGame: {})
    }
}
