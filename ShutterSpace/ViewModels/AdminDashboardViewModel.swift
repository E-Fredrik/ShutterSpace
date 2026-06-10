//
//  AdminDashboardViewModel.swift
//  ShutterSpace
//
//  Created by Elifele Fredrik on 03/06/26.
//

import Combine
import FirebaseDatabase
import Foundation

@MainActor
class AdminDashboardViewModel: ObservableObject {
    @Published var allUsers: [User] = []
    @Published var searchText: String = ""
    @Published var isLoading: Bool = false

    private let databaseRef = Database.database().reference()

    var filteredUsers: [User] { //Filter users based on search text matching first name, last name, or email
        if searchText.isEmpty {
            return allUsers
        } else {
            return allUsers.filter { user in
                user.firstName.localizedCaseInsensitiveContains(searchText)
                    || user.lastName.localizedCaseInsensitiveContains(
                        searchText
                    ) || user.email.localizedCaseInsensitiveContains(searchText)
            }
        }
    }

    func fetchAllUsers() async {
        isLoading = true
        do {
            let snapshot = try await databaseRef.child("users").getData()
            if let children = snapshot.children.allObjects as? [DataSnapshot] {
                var fetchedUsers: [User] = []

                for child in children {
                    if let dict = child.value as? [String: Any],
                        let jsonData = try? JSONSerialization.data(
                            withJSONObject: dict
                        )
                    {

                        if let user = try? JSONDecoder().decode(
                            User.self,
                            from: jsonData
                        ) {
                            if user.role != "Admin" {
                                fetchedUsers.append(user)
                            }
                        }
                    }
                }
                self.allUsers = fetchedUsers.sorted {
                    $0.firstName < $1.firstName
                }
            }
        } catch {
            print("Error fetching all users: \(error.localizedDescription)")
        }
        isLoading = false
    }

    func updateUserStatus(userId: String, newStatus: String) async { //Update user status whether banned or active
        do {
            try await databaseRef.child("users").child(userId)
                .updateChildValues([
                    "status": newStatus
                ])
            await fetchAllUsers()
        } catch {
            print("Error updating user status: \(error.localizedDescription)")
        }
    }
}
