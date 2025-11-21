import SwiftUI

public struct ProfileView: View {
    @ObservedObject var auth: AuthService = .shared
    @State private var draft: UserProfile = UserProfile(name: "", email: "")
    @State private var savedBanner = false
    @State private var showingSignOutConfirm = false
    @State private var showDeleteConfirmation = false
    @State private var showDeleteError = false
    @State private var deleteErrorMessage = ""
    @State private var isDeletingAccount = false

    public init() {}

    public var body: some View {
        Form {
            Section(header: Text("Identity")) {
                TextField("Name", text: $draft.name)
                TextField("Email", text: $draft.email)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
            }
            Section(header: Text("Contact")) {
                TextField("Company", text: $draft.company)
                TextField("Phone", text: $draft.phone)
                    .keyboardType(.phonePad)
            }
            Section(header: Text("About")) {
                TextField("Bio", text: $draft.bio, axis: .vertical)
            }

            Section {
                Button("Save") { save() }
                Button("Sign Out", role: .destructive) { showingSignOutConfirm = true }
            }

            // MARK: - Account Deletion (Apple Guideline 5.1.1(v) Compliance)
            Section {
                Button("Delete Account", role: .destructive) {
                    showDeleteConfirmation = true
                }
                .disabled(isDeletingAccount)
                
                Text("Permanently delete your account and all associated data. This action cannot be undone.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle("Profile")
        .onAppear { draft = auth.user ?? draft }
        .alert("Saved", isPresented: $savedBanner) { Button("OK", role: .cancel) { } }
        .confirmationDialog("Are you sure you want to sign out?", isPresented: $showingSignOutConfirm, titleVisibility: .visible) {
            Button("Sign Out", role: .destructive) { auth.signOut() }
            Button("Cancel", role: .cancel) { }
        }
        .alert("Delete Account", isPresented: $showDeleteConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                deleteAccount()
            }
        } message: {
            Text("Are you sure you want to permanently delete your account? This will remove all your data and cannot be undone.")
        }
        .alert("Error", isPresented: $showDeleteError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(deleteErrorMessage)
        }
    }

    private func save() {
        auth.updateProfile(draft)
        savedBanner = true
    }

    private func deleteAccount() {
        isDeletingAccount = true
        auth.deleteAccount { success, errorMessage in
            isDeletingAccount = false
            if !success, let message = errorMessage {
                deleteErrorMessage = message
                showDeleteError = true
            }
            // If successful, auth state will update automatically
        }
    }
}


