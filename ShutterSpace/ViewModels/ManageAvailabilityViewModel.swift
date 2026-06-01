//
//  ManageAvailabilityViewModel.swift
//  ShutterSpace
//
//  Created by Elifele Fredrik on 01/06/26.
//

import Foundation
import SwiftUI
import Combine
import FirebaseDatabase

@MainActor
class ManageAvailabilityViewModel: ObservableObject {

    @Published var availableTimeSlots: [String] = []
    @Published var isLoading: Bool = false
    @Published var newTimeSlotInput: String = ""
    @Published var shouldShowDuplicateError: Bool = false

    private let databaseReference: DatabaseReference = Database.database().reference()
    private var photographerId: String {
        UserDefaults.standard.string(forKey: "currentUserId") ?? ""
    }

    func fetchTimeSlots() async {
        guard !photographerId.isEmpty else { return }
        isLoading = true
        do {
            let snapshot = try await databaseReference
                .child("availability")
                .child(photographerId)
                .child("timeSlots")
                .getData()
            if let slots = snapshot.value as? [String] {
                self.availableTimeSlots = slots
            } else {
                self.availableTimeSlots = []
            }
        } catch {
            print("Error fetching time slots: \(error.localizedDescription)")
        }
        isLoading = false
    }

    func addTimeSlot() async {
        let trimmedSlot: String = newTimeSlotInput.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedSlot.isEmpty else { return }

        if availableTimeSlots.contains(trimmedSlot) {
            shouldShowDuplicateError = true
            return
        }

        shouldShowDuplicateError = false
        availableTimeSlots.append(trimmedSlot)
        newTimeSlotInput = ""
        await saveTimeSlots()
    }

    func removeTimeSlots(at offsets: IndexSet) async {
        availableTimeSlots.remove(atOffsets: offsets)
        await saveTimeSlots()
    }

    private func saveTimeSlots() async {
        guard !photographerId.isEmpty else { return }
        do {
            try await databaseReference
                .child("availability")
                .child(photographerId)
                .child("timeSlots")
                .setValue(availableTimeSlots)
        } catch {
            print("Error saving time slots: \(error.localizedDescription)")
        }
    }
}
