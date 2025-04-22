import SwiftUI
import GameKit

struct HighScoresView: View {
    @ObservedObject var leaderboardManager: LeaderboardManager
    let onBack: () -> Void  // Closure to handle navigation
    @State private var showGameKitLeaderboard = false
    
    var body: some View {
        VStack {
            if leaderboardManager.highScores.isEmpty {
                Text("No scores yet")
                    .font(.headline)
                    .padding()
            } else {
                List {
                    ForEach(leaderboardManager.highScores) { player in
                        NavigationLink(destination: DetailedScoreView(player: player, onBack: {})) {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(player.name)
                                        .font(.headline)
                                    
                                    Text(player.date, style: .date)
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                                
                                Spacer()
                                
                                Text("\(player.score)")
                                    .font(.title2)
                                    .fontWeight(.bold)
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }
            }
            
            if GameKitManager.shared.isAuthenticated {
                Button("Show Game Center Leaderboard") {
                    leaderboardManager.showGameKitLeaderboard()
                }
                .padding()
                .buttonStyle(.borderedProminent)
            }
        }
        .navigationTitle("High Scores")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        HighScoresView(leaderboardManager: LeaderboardManager(), onBack: {})
    }
}

extension HighScoresView {
    @ViewBuilder
    private func navigationBarItems() -> some View {
        // Placeholder for custom back button
    }
}

extension HighScoresView {
    @ViewBuilder
    private func navigationTitle() -> some View {
        Text("High Scores")
    }
}

extension HighScoresView {
    @ViewBuilder
    private func navigationBarTitleDisplayMode() -> some View {
        .inline
    }
} 