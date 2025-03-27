//
//  NameEntryView.swift
//  BubblePop Game
//
//  Created by Mason Foreman on 28/3/2025.
//

import SwiftUI
import GameKit

struct NameEntryView: View {
    @State private var playerName: String = ""
    @ObservedObject var gameKitManager = GameKitManager.shared
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Enter Your Name")
                .font(.largeTitle)
                .padding()
            
            TextField("Your name", text: $playerName)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)
                .onAppear {
                    // If authenticated, load Game Center alias
                    if gameKitManager.isAuthenticated {
                        playerName = GKLocalPlayer.local.displayName
                    }
                }
            
            Button(action: {
                // TODO: Save player name and transition to the game
            }) {
                Text("Start Game")
                    .font(.headline)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                    .padding(.horizontal)
            }
        }
        .onAppear {
            // This ensures GameKitManager initializes and attempts authentication.
            _ = gameKitManager
        }
    }
}

struct NameEntryView_Previews: PreviewProvider {
    static var previews: some View {
        NameEntryView()
    }
}
