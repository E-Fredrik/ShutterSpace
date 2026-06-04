//
//  UserProfileViewModel.swift
//  ShutterSpace
//
//  Created by Elifele Fredrik on 29/05/26.
//

import Combine
import FirebaseAuth  // NEW: Required to sign out
import FirebaseDatabase
import Foundation

@MainActor
class UserProfileViewModel: ObservableObject {
    @Published var firstName: String = ""
    @Published var lastName: String = ""
    @Published var email: String = ""
    @Published var profileImageUrl: String = ""
    @Published var isLoading: Bool = false
    private let databaseReference = Database.database().reference()

    func fetchCurrentUser() async {
        guard let userId = UserDefaults.standard.string(forKey: "currentUserId")
        else { return }
        isLoading = true
        do {
            let snapshot = try await databaseReference.child("users").child(
                userId
            ).getData()

            if let dict = snapshot.value as? [String: Any] {
                self.firstName = dict["firstName"] as? String ?? ""
                self.lastName = dict["lastName"] as? String ?? ""
                self.email = dict["email"] as? String ?? ""
                self.profileImageUrl = dict["profileImageUrl"] as? String ?? ""
            }

        } catch {
            print(error)
        }

        isLoading = false
    }

    func logout() {
        // NEW: Force Firebase Auth sign out
        try? Auth.auth().signOut()

        UserDefaults.standard.removeObject(forKey: "currentUserId")
        UserDefaults.standard.removeObject(forKey: "currentUserRole")
    }
}
