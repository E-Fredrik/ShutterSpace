//
//  DashboardViewModel.swift
//  ShutterSpace
//
//  Created by Sean tandjaja on 31/05/26.
//

import Combine
import FirebaseDatabase
import Foundation

@MainActor
class DashboardViewModel: ObservableObject {
    @Published var photographerName: String = "Loading..."
    @Published var totalEarnings: Double = 0.0
    @Published var totalSessions: Int = 0
    @Published var pendingRequests: [DashboardSession] = []
    @Published var acceptedSessions: [DashboardSession] = []
    @Published var isLoading: Bool = true
    @Published var showAlert: Bool = false
    @Published var alertMessage: String = ""

    var currentUserId: String {
        UserDefaults.standard.string(forKey: "currentUserId") ?? ""
    }
    private let databaseRef = Database.database().reference()

    func fetchDashboardData() async {
        isLoading = true

        async let profileTask: () = fetchPhotographerProfile()
        async let bookingsTask: () = fetchBookings()

        _ = await (profileTask, bookingsTask)

        isLoading = false
    }

    func acceptBooking(session: DashboardSession) async {
        if session.isOverlapping {
            self.alertMessage =
                "You cannot accept this booking because it overlaps with an already accepted session on your schedule."
            self.showAlert = true
            return
        }

        do {
            try await databaseRef.child("bookings").child(session.bookingId)
                .child("status").setValue("Accepted")
            await fetchDashboardData()
        } catch {}
    }

    func declineBooking(bookingId: String) async {
        do {
            let updates: [String: Any] = [
                "status": "Declined",
                "paymentStatus": "Refunded to Client",
            ]

            try await databaseRef.child("bookings").child(bookingId)
                .updateChildValues(updates)

            await fetchDashboardData()
        } catch {
            print("Failed to decline booking: \(error.localizedDescription)")
        }
    }

    func markSessionAsCompleted(bookingId: String, totalCost: Double) async {
        isLoading = true

        do {

            let bookingUpdates: [String: Any] = [
                "status": "Completed",
                "paymentStatus": "Released to Photographer",
            ]
            try await databaseRef.child("bookings").child(bookingId)
                .updateChildValues(bookingUpdates)

            let platformFee = 15000.0
            let photographerCut = totalCost - platformFee

            let currentUserId =
                UserDefaults.standard.string(forKey: "currentUserId") ?? ""
            let earningsRef = databaseRef.child("photographers").child(
                currentUserId
            ).child("totalEarnings")

            let snapshot = try await earningsRef.getData()
            let currentEarnings = snapshot.value as? Double ?? 0.0
            let newTotalEarnings = currentEarnings + photographerCut

            try await earningsRef.setValue(newTotalEarnings)

            await fetchDashboardData()

        } catch {
            print("Failed to complete session: \(error.localizedDescription)")
        }

        isLoading = false
    }

    private func timeToMinutes(_ timeStr: String) -> Int {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "h:mm a"
        if let date = formatter.date(from: timeStr) {
            return Calendar.current.component(.hour, from: date) * 60
                + Calendar.current.component(.minute, from: date)
        }
        formatter.dateFormat = "HH:mm"
        if let date = formatter.date(from: timeStr) {
            return Calendar.current.component(.hour, from: date) * 60
                + Calendar.current.component(.minute, from: date)
        }
        return 0
    }

    private func fetchPhotographerProfile() async {
        do {
            let snapshot = try await databaseRef.child("users").child(
                currentUserId
            ).getData()
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
            guard let children = snapshot.children.allObjects as? [DataSnapshot]
            else { return }

            var earnings: Double = 0
            var sessions: Int = 0
            var requests: [DashboardSession] = []
            var accepted: [DashboardSession] = []

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
                let bookingId: String =
                    dict["bookingId"] as? String ?? child.key

                // Fallback to fetch package duration if not in booking dict
                let packageData = await fetchPackageData(packageId: packageId)
                let duration = dict["duration"] as? Int ?? packageData.duration

                if status == "Completed" {
                    earnings += cost
                    sessions += 1
                } else if status == "Accepted" || status == "Pending" {

                    if status == "Accepted" {
                        earnings += cost
                        sessions += 1
                    }

                    let clientName = await fetchClientName(clientId: clientId)

                    let session = DashboardSession(
                        id: bookingId,
                        bookingId: bookingId,
                        clientName: clientName,
                        packageTitle: packageData.title,
                        totalCost: cost,
                        date: date,
                        timeSlot: timeSlot,
                        status: status,
                        duration: duration
                    )

                    if status == "Accepted" {
                        accepted.append(session)
                    } else if status == "Pending" {
                        requests.append(session)
                    }
                }
            }

            // NEW: Flag overlaps in Pending Requests
            for i in 0..<requests.count {
                let reqStart = timeToMinutes(requests[i].timeSlot)
                let reqEnd = reqStart + requests[i].duration

                var overlaps = false
                for acc in accepted where acc.date == requests[i].date {
                    let accStart = timeToMinutes(acc.timeSlot)
                    let accEnd = accStart + acc.duration

                    if reqStart < accEnd && reqEnd > accStart {
                        overlaps = true
                        break
                    }
                }
                requests[i].isOverlapping = overlaps
            }

            self.totalEarnings = earnings
            self.totalSessions = sessions
            self.pendingRequests = requests
            self.acceptedSessions = accepted

        } catch {}
    }

    private func fetchPackageData(packageId: String) async -> (
        title: String, duration: Int
    ) {
        do {
            let snap = try await databaseRef.child("servicePackages").child(
                currentUserId
            ).child(packageId).getData()
            if let dict = snap.value as? [String: Any],
                let title = dict["title"] as? String
            {
                let duration = dict["duration"] as? Int ?? 60
                return (title, duration)
            }
        } catch {}
        return ("Custom Session", 60)
    }

    private func fetchClientName(clientId: String) async -> String {
        do {
            let snapshot = try await databaseRef.child("users").child(clientId)
                .getData()
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
            let snapshot = try await databaseRef.child("servicePackages").child(
                currentUserId
            )
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
