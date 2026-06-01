//
//  DashboardViewModel.swift
//  ShutterSpace
//
//  Created by Sean tandjaja on 31/05/26.
//

import Foundation
import Combine
import FirebaseDatabase

// MARK: - Supporting Models

struct PendingRequest: Identifiable {
    let id: String
    let clientName: String
    let packageTitle: String
    let totalCost: Double
    let date: String
    let timeSlot: String
}

@MainActor
class DashboardViewModel: ObservableObject {
    
    // MARK: - Properties
    @Published var photographerName: String = "Loading..."
    @Published var totalEarnings: Double = 0.0
    @Published var totalSessions: Int = 0
    @Published var pendingRequests: [PendingRequest] = []
    @Published var isLoading: Bool = true
    
    // Hardcoded for current session based on the provided Firebase structure
    let currentUserId: String = "photo_001"
    private let databaseRef = Database.database().reference()
    
    // MARK: - Public Methods
    
    /// Fetches all required dashboard data concurrently.
    func fetchDashboardData() async {
        isLoading = true
        
        async let profileTask: () = fetchPhotographerProfile()
        async let bookingsTask: () = fetchBookings()
        
        _ = await (profileTask, bookingsTask)
        
        isLoading = false
    }
    
    /// Updates the booking status to "Accepted"
    func acceptBooking(bookingId: String) async {
        do {
            try await databaseRef.child("bookings").child(bookingId).child("status").setValue("Accepted")
            await fetchDashboardData() // Refresh list
        } catch {
            print("Error accepting booking: \(error.localizedDescription)")
        }
    }
    
    /// Updates the booking status to "Declined"
    func declineBooking(bookingId: String) async {
        do {
            try await databaseRef.child("bookings").child(bookingId).child("status").setValue("Declined")
            await fetchDashboardData() // Refresh list
        } catch {
            print("Error declining booking: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Private Methods
    
    /// Fetches the photographer's basic profile info to display their name.
    private func fetchPhotographerProfile() async {
        do {
            let snapshot = try await databaseRef.child("users").child(currentUserId).getData()
            if let dict = snapshot.value as? [String: Any],
               let firstName = dict["firstName"] as? String,
               let lastName = dict["lastName"] as? String {
                self.photographerName = "\(firstName) \(lastName)"
            }
        } catch {
            print("Error fetching profile: \(error.localizedDescription)")
        }
    }
    
    /// Fetches and processes bookings to calculate stats and list pending requests.
    private func fetchBookings() async {
        do {
            let snapshot = try await databaseRef.child("bookings").getData()
            guard let children = snapshot.children.allObjects as? [DataSnapshot] else { return }
            
            var earnings: Double = 0
            var sessions: Int = 0
            var requests: [PendingRequest] = []
            
            for child in children {
                guard let dict = child.value as? [String: Any],
                      let photoId = dict["photographerId"] as? String,
                      photoId == self.currentUserId,
                      let status = dict["status"] as? String else { continue }
                
                let cost = dict["totalCost"] as? Double ?? 0.0
                let date = dict["date"] as? String ?? "TBD"
                let timeSlot = dict["timeSlot"] as? String ?? "TBD"
                let clientId = dict["clientId"] as? String ?? ""
                let packageId = dict["packageId"] as? String ?? ""
                let bookingId = dict["bookingId"] as? String ?? child.key
                
                if status == "Completed" || status == "Accepted" {
                    earnings += cost
                    sessions += 1
                } else if status == "Pending" {
                    let clientName = await fetchClientName(clientId: clientId)
                    let packageTitle = await fetchPackageTitle(packageId: packageId)
                    
                    let request = PendingRequest(
                        id: bookingId,
                        clientName: clientName,
                        packageTitle: packageTitle,
                        totalCost: cost,
                        date: date,
                        timeSlot: timeSlot
                    )
                    requests.append(request)
                }
            }
            
            self.totalEarnings = earnings
            self.totalSessions = sessions
            self.pendingRequests = requests
            
        } catch {
            print("Error fetching bookings: \(error.localizedDescription)")
        }
    }
    
    /// Helper to resolve the client's name dynamically.
    private func fetchClientName(clientId: String) async -> String {
        do {
            let snapshot = try await databaseRef.child("users").child(clientId).getData()
            if let dict = snapshot.value as? [String: Any],
               let first = dict["firstName"] as? String,
               let last = dict["lastName"] as? String {
                return "\(first) \(last)"
            }
        } catch {
            print("Error fetching client: \(error.localizedDescription)")
        }
        return "Unknown Client"
    }
    
    /// Helper to resolve the package title dynamically.
    private func fetchPackageTitle(packageId: String) async -> String {
        do {
            let snapshot = try await databaseRef.child("servicePackages").child(currentUserId).child(packageId).getData()
            if let dict = snapshot.value as? [String: Any],
               let title = dict["title"] as? String {
                return title
            }
        } catch {
            print("Error fetching package: \(error.localizedDescription)")
        }
        return "Custom Session"
    }
}

