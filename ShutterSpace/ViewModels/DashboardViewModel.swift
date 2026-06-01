//
//  DashboardViewModel.swift
//  ShutterSpace
//
//  Created by Sean tandjaja on 31/05/26.
//

import Combine
import FirebaseDatabase
import Foundation

struct PendingRequest: Identifiable {
    let id: String
    let clientName: String
    let packageTitle: String
    let totalCost: Double
    let date: String
    let timeSlot: String
}

struct AcceptedSession: Identifiable {
    let id: String
    let bookingId: String
    let clientName: String
    let packageTitle: String
    let totalCost: Double
    let date: String
    let timeSlot: String
}

@MainActor
class DashboardViewModel: ObservableObject {
    @Published var photographerName: String = "Loading..."
    @Published var totalEarnings: Double = 0.0
    @Published var totalSessions: Int = 0
    @Published var pendingRequests: [PendingRequest] = []
    @Published var acceptedSessions: [AcceptedSession] = []
    @Published var isLoading: Bool = true

    let currentUserId: String = "photo_001"
    private let databaseRef = Database.database().reference()

    func fetchDashboardData() async {
        isLoading = true

        async let profileTask: () = fetchPhotographerProfile()
        async let bookingsTask: () = fetchBookings()

        _ = await (profileTask, bookingsTask)

        isLoading = false
    }

    func acceptBooking(bookingId: String) async {
        do {
            try await databaseRef.child("bookings").child(bookingId).child("status").setValue(
                "Accepted")
            await fetchDashboardData()
        } catch {
            print("Error accepting booking: \(error.localizedDescription)")
        }
    }

    func declineBooking(bookingId: String) async {
        do {
            try await databaseRef.child("bookings").child(bookingId).child("status").setValue(
                "Declined")
            await fetchDashboardData()
        } catch {
            print("Error declining booking: \(error.localizedDescription)")
        }
    }

    func markSessionAsCompleted(bookingId: String, resultsLink: String) async {
        var updatePayload: [String: Any] = ["status": "Completed"]
        let trimmedLink: String = resultsLink.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmedLink.isEmpty {
            updatePayload["resultsLink"] = trimmedLink
        }
        do {
            try await databaseRef.child("bookings").child(bookingId).updateChildValues(
                updatePayload)
            await fetchDashboardData()
        } catch {
            print("Error marking session as completed: \(error.localizedDescription)")
        }
    }

    private func fetchPhotographerProfile() async {
        do {
            let snapshot = try await databaseRef.child("users").child(currentUserId).getData()
            if let dict = snapshot.value as? [String: Any],
                let firstName = dict["firstName"] as? String,
                let lastName = dict["lastName"] as? String
            {
                self.photographerName = "\(firstName) \(lastName)"
            }
        } catch {
            print("Error fetching profile: \(error.localizedDescription)")
        }
    }

    private func fetchBookings() async {
        do {
            let snapshot = try await databaseRef.child("bookings").getData()
            guard let children = snapshot.children.allObjects as? [DataSnapshot] else { return }

            var earnings: Double = 0
            var sessions: Int = 0
            var requests: [PendingRequest] = []
            var accepted: [AcceptedSession] = []

            for child in children {
                guard let dict = child.value as? [String: Any],
                    let photoId = dict["photographerId"] as? String,
                    photoId == self.currentUserId,
                    let status = dict["status"] as? String
                else { continue }

                let cost: Double = dict["totalCost"] as? Double ?? 0.0
                let date: String = dict["date"] as? String ?? "TBD"
                let timeSlot: String = dict["timeSlot"] as? String ?? "TBD"
                let clientId: String = dict["clientId"] as? String ?? ""
                let packageId: String = dict["packageId"] as? String ?? ""
                let bookingId: String = dict["bookingId"] as? String ?? child.key

                if status == "Completed" {
                    earnings += cost
                    sessions += 1
                } else if status == "Accepted" {
                    earnings += cost
                    sessions += 1
                    let clientName: String = await fetchClientName(clientId: clientId)
                    let packageTitle: String = await fetchPackageTitle(packageId: packageId)
                    let session = AcceptedSession(
                        id: bookingId,
                        bookingId: bookingId,
                        clientName: clientName,
                        packageTitle: packageTitle,
                        totalCost: cost,
                        date: date,
                        timeSlot: timeSlot
                    )
                    accepted.append(session)
                } else if status == "Pending" {
                    let clientName: String = await fetchClientName(clientId: clientId)
                    let packageTitle: String = await fetchPackageTitle(packageId: packageId)

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
            self.acceptedSessions = accepted

        } catch {
            print("Error fetching bookings: \(error.localizedDescription)")
        }
    }

    private func fetchClientName(clientId: String) async -> String {
        do {
            let snapshot = try await databaseRef.child("users").child(clientId).getData()
            if let dict = snapshot.value as? [String: Any],
                let first = dict["firstName"] as? String,
                let last = dict["lastName"] as? String
            {
                return "\(first) \(last)"
            }
        } catch {
            print("Error fetching client: \(error.localizedDescription)")
        }
        return "Unknown Client"
    }

    private func fetchPackageTitle(packageId: String) async -> String {
        do {
            let snapshot = try await databaseRef.child("servicePackages").child(currentUserId)
                .child(packageId).getData()
            if let dict = snapshot.value as? [String: Any],
                let title = dict["title"] as? String
            {
                return title
            }
        } catch {
            print("Error fetching package: \(error.localizedDescription)")
        }
        return "Custom Session"
    }
}
