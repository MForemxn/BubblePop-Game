//
//  InviteFriendsView.swift
//  BubblePop Game
//
//  Created by Assistant on 20/7/2025.
//

import SwiftUI
import Contacts

struct InviteFriendsView: View {
    let gameSettings: GameSettings
    let playerName: String
    let onStartBattle: ([String]) -> Void
    let onBack: () -> Void
    
    @StateObject private var messageManager = MessageManager.shared
    @State private var selectedContacts: [String] = []
    @State private var showingContactPicker = false
    @State private var showingManualEntry = false
    @State private var manualPhoneNumber = ""
    @State private var showingInviteSent = false
    @State private var inviteSentMessage = ""
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.blue.opacity(0.1),
                        Color.purple.opacity(0.1)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 30) {
                    // Header
                    VStack(spacing: 10) {
                        Image(systemName: "person.2.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.blue)
                        
                        Text("Invite Friends to Battle!")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .multilineTextAlignment(.center)
                        
                        Text("Challenge your friends to see who can pop more bubbles!")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    
                    // Game Settings Display
                    gameSettingsCard
                    
                    // Selected Contacts
                    if !selectedContacts.isEmpty {
                        selectedContactsView
                    }
                    
                    Spacer()
                    
                    // Action Buttons
                    VStack(spacing: 15) {
                        // Add Contact Button
                        Button(action: { showingContactPicker = true }) {
                            HStack {
                                Image(systemName: "person.badge.plus")
                                Text("Add from Contacts")
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                        }
                        .disabled(!messageManager.canSendMessages)
                        
                        // Manual Entry Button
                        Button(action: { showingManualEntry = true }) {
                            HStack {
                                Image(systemName: "keyboard")
                                Text("Enter Phone Number")
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                        }
                        .disabled(!messageManager.canSendMessages)
                        
                        // Send Invites Button
                        Button(action: sendInvites) {
                            HStack {
                                Image(systemName: "paperplane.fill")
                                Text("Send Battle Invites")
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(selectedContacts.isEmpty ? Color.gray : Color.orange)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                        }
                        .disabled(selectedContacts.isEmpty || !messageManager.canSendMessages)
                        
                        // Start Random Match Button
                        Button(action: { onStartBattle([]) }) {
                            HStack {
                                Image(systemName: "shuffle")
                                Text("Find Random Opponent")
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.purple)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                        }
                    }
                    
                    // Messages Not Available Warning
                    if !messageManager.canSendMessages {
                        VStack(spacing: 8) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(.orange)
                            Text("Messages not available on this device")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.orange.opacity(0.1))
                        )
                    }
                }
                .padding()
            }
            .navigationTitle("Battle Mode")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Back") {
                        onBack()
                    }
                }
            }
        }
        .sheet(isPresented: $showingContactPicker) {
            ContactPickerView(selectedContacts: $selectedContacts)
        }
        .sheet(isPresented: $showingManualEntry) {
            manualEntryView
        }
        .alert("Invitation Sent!", isPresented: $showingInviteSent) {
            Button("OK") { }
        } message: {
            Text(inviteSentMessage)
        }
    }
    
    // MARK: - Views
    
    private var gameSettingsCard: some View {
        VStack(spacing: 12) {
            Text("Battle Settings")
                .font(.headline)
                .fontWeight(.bold)
            
            HStack {
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Image(systemName: "gauge")
                        Text("Difficulty:")
                    }
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    
                    Text(gameSettings.difficulty.rawValue.capitalized)
                        .font(.title3)
                        .fontWeight(.semibold)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 6) {
                    HStack {
                        Image(systemName: "clock")
                        Text("Duration:")
                    }
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    
                    Text("\(gameSettings.gameTime)s")
                        .font(.title3)
                        .fontWeight(.semibold)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color(UIColor.secondarySystemBackground))
                .shadow(radius: 3)
        )
    }
    
    private var selectedContactsView: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Selected Friends")
                .font(.headline)
                .fontWeight(.bold)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 10) {
                ForEach(selectedContacts, id: \.self) { contact in
                    HStack {
                        Text(formatPhoneNumber(contact))
                            .font(.subheadline)
                            .lineLimit(1)
                        
                        Spacer()
                        
                        Button(action: {
                            selectedContacts.removeAll { $0 == contact }
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.red)
                        }
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color(UIColor.tertiarySystemBackground))
                    )
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color(UIColor.secondarySystemBackground))
                .shadow(radius: 3)
        )
    }
    
    private var manualEntryView: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Enter Phone Number")
                    .font(.title2)
                    .fontWeight(.bold)
                
                TextField("Phone number", text: $manualPhoneNumber)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.phonePad)
                
                Button("Add Contact") {
                    if !manualPhoneNumber.isEmpty && !selectedContacts.contains(manualPhoneNumber) {
                        selectedContacts.append(manualPhoneNumber)
                        manualPhoneNumber = ""
                        showingManualEntry = false
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(manualPhoneNumber.isEmpty ? Color.gray : Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
                .disabled(manualPhoneNumber.isEmpty)
                
                Spacer()
            }
            .padding()
            .navigationTitle("Add Contact")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        showingManualEntry = false
                        manualPhoneNumber = ""
                    }
                }
            }
        }
    }
    
    // MARK: - Methods
    
    private func sendInvites() {
        messageManager.sendInvitation(
            to: selectedContacts,
            from: playerName,
            gameSettings: gameSettings
        ) { success in
            DispatchQueue.main.async {
                if success {
                    inviteSentMessage = "Battle invitations sent to \(selectedContacts.count) friend(s)!"
                    showingInviteSent = true
                    
                    // Start the multiplayer match with these recipients
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        onStartBattle(selectedContacts)
                    }
                } else {
                    inviteSentMessage = "Failed to send invitations. Please try again."
                    showingInviteSent = true
                }
            }
        }
    }
    
    private func formatPhoneNumber(_ number: String) -> String {
        // Simple formatting for display
        let cleaned = number.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
        if cleaned.count == 10 {
            return "(\(cleaned.prefix(3))) \(cleaned.dropFirst(3).prefix(3))-\(cleaned.suffix(4))"
        }
        return number
    }
}

// MARK: - Contact Picker View
struct ContactPickerView: UIViewControllerRepresentable {
    @Binding var selectedContacts: [String]
    @Environment(\.presentationMode) var presentationMode
    
    func makeUIViewController(context: Context) -> ContactPickerViewController {
        let controller = ContactPickerViewController()
        controller.delegate = context.coordinator
        return controller
    }
    
    func updateUIViewController(_ uiViewController: ContactPickerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, ContactPickerDelegate {
        let parent: ContactPickerView
        
        init(_ parent: ContactPickerView) {
            self.parent = parent
        }
        
        func contactPicker(didSelect contacts: [String]) {
            parent.selectedContacts = contacts
            parent.presentationMode.wrappedValue.dismiss()
        }
        
        func contactPickerDidCancel() {
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}

// MARK: - Contact Picker Controller
protocol ContactPickerDelegate: AnyObject {
    func contactPicker(didSelect contacts: [String])
    func contactPickerDidCancel()
}

class ContactPickerViewController: UIViewController {
    weak var delegate: ContactPickerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // For demo purposes, show a simple selection interface
        // In a real app, you'd implement proper contact picking
        setupUI()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        let label = UILabel()
        label.text = "Contact picker would go here\n(Demo mode)"
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        
        let cancelButton = UIButton(type: .system)
        cancelButton.setTitle("Cancel", for: .normal)
        cancelButton.addTarget(self, action: #selector(cancelTapped), for: .touchUpInside)
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(label)
        view.addSubview(cancelButton)
        
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            cancelButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            cancelButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20)
        ])
    }
    
    @objc private func cancelTapped() {
        delegate?.contactPickerDidCancel()
    }
}

#Preview {
    InviteFriendsView(
        gameSettings: GameSettings(),
        playerName: "Player1",
        onStartBattle: { _ in },
        onBack: { }
    )
}