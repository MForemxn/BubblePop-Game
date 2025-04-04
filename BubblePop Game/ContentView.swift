import SwiftUI

struct ContentView: View {
    @StateObject private var gameState = GameState(
        gameSettings: GameSettings(maxBubbles: 15, gameDuration: 60), // Proper initialization
        animationManager: AnimationManager(),
        soundManager: SoundManager()
    )
    @StateObject private var settings = GameSettings(maxBubbles: 15, gameDuration: 60)
    @State private var showSettings = false
    @State private var currentView: AppView = .nameEntry
    
    enum AppView {
        case nameEntry, game, highScores, settings
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [Color.blue.opacity(0.3), Color.purple.opacity(0.3)]),
                    startPoint: .top, endPoint: .bottom
                )
                .edgesIgnoringSafeArea(.all)
                
                switch currentView {
                case .nameEntry:
                    NameEntryView(
                        gameManager: GameManager(gameSettings: $gameState.gameSettings),
                        playerName: $gameState.playerName,
                        onStartGame: { currentView = .game }
                    )
                    .transition(.move(edge: .trailing))
                case .game:
                    MainGameView(gameState: gameState, gameManager: GameManager())
                        .environmentObject(settings)
                        .onDisappear { gameState.resetGame() }
                        .transition(.opacity)
                case .highScores:
                    HighScoresView(onBack: { currentView = .nameEntry })
                        .transition(.opacity)
                case .settings:
                    SettingsView(onBack: { currentView = .nameEntry })
                        .environmentObject(settings)
                        .transition(.opacity)
                }
            }
            .navigationTitle(navigationTitle)
            .navigationBarItems(leading: leadingBarItems, trailing: trailingBarItems)
            .navigationBarBackButtonHidden(true)
            .animation(.easeInOut, value: currentView)
            .sheet(isPresented: $gameState.gameOver) {
                GameOverView(
                    score: gameState.currentScore,
                    playerName: gameState.playerName,
                    onPlayAgain: {
                        gameState.gameOver = false
                        gameState.startGame()
                    },
                    onViewHighScores: {
                        gameState.gameOver = false
                        currentView = .highScores
                    },
                    onMainMenu: {
                        gameState.gameOver = false
                        currentView = .nameEntry
                    }
                )
            }
        }
    }
    
    private var navigationTitle: String {
        switch currentView {
        case .nameEntry: return "BubblePop"
        case .game: return "Game in Progress"
        case .highScores: return "High Scores"
        case .settings: return "Settings"
        }
    }
    
    private var leadingBarItems: some View {
        Group {
            if currentView != .nameEntry {
                Button(action: {
                    if currentView == .game { gameState.resetGame() }
                    currentView = .nameEntry
                }) {
                    HStack {
                        Image(systemName: "arrow.left")
                        Text("Back")
                    }
                }
            }
        }
    }
    
    private var trailingBarItems: some View {
        Group {
            if currentView == .nameEntry {
                HStack {
                    Button(action: { currentView = .highScores }) {
                        Image(systemName: "trophy")
                    }
                    Button(action: { currentView = .settings }) {
                        Image(systemName: "gear")
                    }
                }
            } else if currentView == .game {
                Text("Score: \(gameState.currentScore)")
                    .bold()
                    .padding(.horizontal)
                    .background(Capsule().fill(Color.white.opacity(0.3)))
            }
        }
    }
}

#Preview {
    ContentView()
}
