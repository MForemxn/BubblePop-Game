//
//  DetailedScoreView.swift
//  BubblePop Game
//
//  Created by Mason Foreman on 28/3/2025.
//

import SwiftUI
import GameKit

struct DetailedScoreView: View {
    let player: Player
    let onBack: () -> Void
    @Environment(\.presentationMode) private var presentationMode
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header section
                VStack(alignment: .center, spacing: 10) {
                    Text(player.name)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("Score: \(player.score)")
                        .font(.title)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.blue.opacity(0.2))
                        )
                        .foregroundColor(.primary)
                }
                .frame(maxWidth: .infinity)
                .padding(.bottom, 20)
                
                // Game details section
                Group {
                    sectionHeader("Game Details")
                    
                    detailRow(title: "Date Played", value: formatDate(player.date))
                    
                    if !player.gameKitPlayerId.isEmpty {
                        detailRow(title: "Game Center ID", value: player.gameKitPlayerId)
                    }
                }
                
                // Game settings section
                Group {
                    sectionHeader("Game Settings")
                    
                    detailRow(title: "Game Duration", value: "\(player.gameSettings.gameTime) seconds")
                    detailRow(title: "Bubble Speed", value: player.gameSettings.bubbleSpeed.capitalized)
                    detailRow(title: "Maximum Bubbles", value: "\(player.gameSettings.maxBubbles)")
                }
                
                Spacer()
            }
            .padding()
        }
        .navigationTitle("Score Details")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    onBack()
                    presentationMode.wrappedValue.dismiss()
                }) {
                    HStack {
                        Image(systemName: "chevron.left")
                        Text("Back")
                    }
                    .foregroundColor(.blue)
                }
            }
        }
    }
    
    private func sectionHeader(_ title: String) -> some View {
        Text(title)
            .font(.headline)
            .foregroundColor(.secondary)
            .padding(.top, 10)
    }
    
    private func detailRow(title: String, value: String) -> some View {
        HStack(alignment: .top) {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .frame(width: 140, alignment: .leading)
            
            Spacer()
            
            Text(value)
                .font(.body)
                .multilineTextAlignment(.trailing)
        }
        .padding(.vertical, 4)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

#Preview {
    NavigationStack {
        DetailedScoreView(
            player: Player(
                name: "Player Name",
                score: 1200,
                date: Date(),
                gameKitPlayerId: "gk_12345",
                gameSettings: GameSettingsData(gameTime: 60, maxBubbles: 15, bubbleSpeed: "medium")
            ),
            onBack: {}
        )
    }
} 