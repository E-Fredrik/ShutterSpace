//
//  MySessionsViewModel.swift
//  ShutterSpace
//
//  Created by Elifele Fredrik on 01/06/26.
//

import Foundation
import Combine
import FirebaseDatabase

struct SessionItem: Identifiable {
    let id: String
    let bookingId: String
    let photographerId: String
    let photographerName: String
    let packageTitle: String
    let totalCost: Double
    let date: String
    let timeSlot: String
    let status: String
    let resultsLink: String?
    let hasBeenReviewed: Bool
}

@MainActor
class MySessionsViewModel: ObservableObject {
    @Published var activeSessions: [SessionItem] = []
    @Published var completedSessions: [SessionItem] = []
    @Published var isLoading: Bool = false
    @Published var shouldShowReviewSubmittedBanner: Bool = false
    @Published var errorMessage: String = ""

    private let databaseReference: DatabaseReference = Database.database().reference()
    private var currentUserId: String {
        UserDefaults.standard.string(forKey: "currentUserId") ?? ""
    }

    func fetchSessions() async {
        guard !currentUserId.isEmpty else { return }
        isLoading = true

        do {
            let snapshot = try await databaseReference.child("bookings").getData()
            guard let children = snapshot.children.allObjects as? [DataSnapshot] else {
                isLoading = false
                return
            }

            var activeItems: [SessionItem] = []
            var completedItems: [SessionItem] = []

            for child in children {
                guard
                    let dict = child.value as? [String: Any],
                    let clientId = dict["clientId"] as? String,
                    clientId == currentUserId,
                    let status = dict["status"] as? String,
                    status != "Declined"
                else { continue }

                let bookingId: String = dict["bookingId"] as? String ?? child.key
                let photographerId: String = dict["photographerId"] as? String ?? ""
                let packageId: String = dict["packageId"] as? String ?? ""
                let totalCost: Double = dict["totalCost"] as? Double ?? 0.0
                let date: String = dict["date"] as? String ?? "TBD"
                let timeSlot: String = dict["timeSlot"] as? String ?? "TBD"
                let resultsLink: String? = dict["resultsLink"] as? String

                let photographerName: String = await fetchPhotographerName(photographerId: photographerId)
                let packageTitle: String = await fetchPackageTitle(photographerId: photographerId, packageId: packageId)
                let hasBeenReviewed: Bool = dict["isReviewed"] as? Bool ?? false

                let sessionItem = SessionItem(
                    id: bookingId,
                    bookingId: bookingId,
                    photographerId: photographerId,
                    photographerName: photographerName,
                    packageTitle: packageTitle,
                    totalCost: totalCost,
                    date: date,
                    timeSlot: timeSlot,
                    status: status,
                    resultsLink: resultsLink,
                    hasBeenReviewed: hasBeenReviewed
                )

                if status == "Completed" {
                    completedItems.append(sessionItem)
                } else {
                    activeItems.append(sessionItem)
                }
            }

            self.activeSessions = activeItems
            self.completedSessions = completedItems

        } catch {
            self.errorMessage = "Failed to load sessions: \(error.localizedDescription)"
            print("Error fetching sessions: \(error.localizedDescription)")
        }

        isLoading = false
    }

    func submitReview(
        bookingId: String,
        photographerId: String,
        starRating: Int,
        writtenReview: String
    ) async {
        errorMessage = ""
        let newReviewId: String = UUID().uuidString
        let formatter: DateFormatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let createdAt: String = formatter.string(from: Date())

        let reviewData: [String: Any] = [
            "reviewId": newReviewId,
            "bookingId": bookingId,
            "clientId": currentUserId,
            "photographerId": photographerId,
            "starRating": starRating,
            "writtenReview": writtenReview,
            "createdAt": createdAt
        ]

        do {
            try await databaseReference.child("reviews").child(newReviewId).setValue(reviewData)
            try await databaseReference
                .child("bookings")
                .child(bookingId)
                .child("isReviewed")
                .setValue(true)
            await recalculatePhotographerRating(photographerId: photographerId)
            await fetchSessions()
            shouldShowReviewSubmittedBanner = true
        } catch {
            self.errorMessage = "Failed to submit review: \(error.localizedDescription)"
            print("Error submitting review: \(error.localizedDescription)")
        }
    }

    private func fetchPhotographerName(photographerId: String) async -> String {
        do {
            let snapshot = try await databaseReference.child("users").child(photographerId).getData()
            if let dict = snapshot.value as? [String: Any],
               let firstName = dict["firstName"] as? String,
               let lastName = dict["lastName"] as? String {
                return "\(firstName) \(lastName)"
            }
        } catch {
            print("Error fetching photographer name: \(error.localizedDescription)")
        }
        return "Unknown Photographer"
    }

    private func fetchPackageTitle(photographerId: String, packageId: String) async -> String {
        do {
            let snapshot = try await databaseReference
                .child("servicePackages")
                .child(photographerId)
                .child(packageId)
                .getData()
            if let dict = snapshot.value as? [String: Any],
               let title = dict["title"] as? String {
                return title
            }
        } catch {
            print("Error fetching package title: \(error.localizedDescription)")
        }
        return "Custom Session"
    }

    private func recalculatePhotographerRating(photographerId: String) async {
        do {
            let snapshot = try await databaseReference
                .child("reviews")
                .queryOrdered(byChild: "photographerId")
                .queryEqual(toValue: photographerId)
                .getData()

            guard let children = snapshot.children.allObjects as? [DataSnapshot],
                  !children.isEmpty else { return }

            let totalStars: Int = children.compactMap { child -> Int? in
                guard let dict = child.value as? [String: Any],
                      let stars = dict["starRating"] as? Int else { return nil }
                return stars
            }.reduce(0, +)

            let averageRating: Double = Double(totalStars) / Double(children.count)
            let roundedRating: Double = (averageRating * 10).rounded() / 10

            try await databaseReference
                .child("users")
                .child(photographerId)
                .child("rating")
                .setValue(roundedRating)
        } catch {
            print("Error recalculating rating: \(error.localizedDescription)")
        }
    }
}
