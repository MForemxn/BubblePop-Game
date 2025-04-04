import SwiftUI

struct GameOverView: View {
    let score: Int
    let playerName: String
    var onPlayAgain: () -> Void
    var onViewHighScores: () -> Void
    var onMainMenu: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Game Over")
                .font(.largeTitle)
                .fontWeight(.bold)
                
            Text("Score: \(score)")
                .font(.title)
                .padding()
                .background(RoundedRectangle(cornerRadius: 10).fill(Color.white.opacity(0.2)))
                
            Text("Great job, \(playerName)!")
                .font(.headline)
                .foregroundColor(.white)
                
            VStack(spacing: 10) {
                Button(action: onPlayAgain) {
                    Text("Play Again")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                
                Button(action: onViewHighScores) {
                    Text("View High Scores")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                
                Button(action: onMainMenu) {
                    Text("Main Menu")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
            .padding(.horizontal, 20)
        }
        .padding()
        .background(LinearGradient(
            gradient: Gradient(colors: [Color.purple.opacity(0.7), Color.blue.opacity(0.7)]),
            startPoint: .top, endPoint: .bottom
        ))
        .cornerRadius(20)
        .shadow(radius: 10)
        .padding()
    }
}

#Preview {
    GameOverView(
        score: 120,
        playerName: "Mason",
        onPlayAgain: {},
        onViewHighScores: {},
        onMainMenu: {}
    )
}
