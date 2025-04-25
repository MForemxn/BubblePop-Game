//
//  SoundManager.swift
//  BubblePop Game
//
//  Created by Mason Foreman on 28/3/2025.
//

import Foundation
import AVFoundation
import Combine

class SoundManager {
    private var audioPlayers: [URL: AVAudioPlayer] = [:]
    private var isEnabled: Bool = true
    private let gameSettings: GameSettings
    private var backgroundMusicPlayer: AVAudioPlayer?

    init(gameSettings: GameSettings) {
        self.gameSettings = gameSettings
        // Set up audio session
        do {
            try AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to set up audio session: \(error)")
        }
        
        // Observe settings changes
        gameSettings.objectWillChange.sink { [weak self] _ in
            self?.handleSettingsChange()
        }
    }
    
    private func handleSettingsChange() {
        if gameSettings.musicEnabled {
            playBackgroundMusic()
        } else {
            stopBackgroundMusic()
        }
        
        isEnabled = gameSettings.soundEnabled
    }
    
    func toggleSound(enabled: Bool) {
        isEnabled = enabled
    }
    
    func playSound(named filename: String, fileExtension: String = "wav") {
        guard isEnabled else { return }
        
        guard let url = Bundle.main.url(forResource: filename, withExtension: fileExtension) else {
            print("Sound file \(filename).\(fileExtension) not found")
            return
        }
        
        if let player = audioPlayers[url] {
            player.currentTime = 0
            player.play()
        } else {
            do {
                let player = try AVAudioPlayer(contentsOf: url)
                player.prepareToPlay()
                audioPlayers[url] = player
                player.play()
            } catch {
                print("Failed to play sound: \(error)")
            }
        }
    }
    
    func playSoundForBubble(_ color: BubbleColor) {
        switch color {
        case .red:
            playSound(named: "pop_red")
        case .pink:
            playSound(named: "pop_pink")
        case .green:
            playSound(named: "pop_green")
        case .blue:
            playSound(named: "pop_blue")
        case .black:
            playSound(named: "pop_black")
        }
    }

    func playBackgroundMusic() {
        guard gameSettings.musicEnabled else { return }
        
        if backgroundMusicPlayer == nil {
            guard let url = Bundle.main.url(forResource: "background_music", withExtension: "mp3") else {
                print("Background music file not found")
                return
            }
            
            do {
                let player = try AVAudioPlayer(contentsOf: url)
                player.numberOfLoops = -1 // Loop indefinitely
                player.prepareToPlay()
                backgroundMusicPlayer = player
            } catch {
                print("Failed to create background music player: \(error)")
                return
            }
        }
        
        backgroundMusicPlayer?.play()
    }

    func stopBackgroundMusic() {
        backgroundMusicPlayer?.stop()
    }

    func playPopSound() {
        playSound(named: "pop_general")
    }
}
