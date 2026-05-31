//
//  BookingViewModel.swift
//  ShutterSpace
//
//  Created by Sean tandjaja on 31/05/26.
//

import Foundation
import Combine
import FirebaseDatabase

@MainActor
class BookingViewModel: ObservableObject {
    
    // MARK: - Properties
    @Published var selectedDate: Date = Date()
    @Published var selectedTimeSlot: String?
    @Published var selectedPackage: ServicePackage?
    @Published var packages: [ServicePackage] = []
    
    // Dummy data
    @Published var availableTimeSlots: [String] = ["9:00 AM", "12:00 PM", "1:30 PM", "4:30 PM"]
    @Published var isBookingInProgress: Bool = false
    @Published var bookingComplete: Bool = false
    
    let platformFee: Double = 12.00
    let photographerId: String
    let clientId: String = "client_001"
    
    private let databaseRef = Database.database().reference()
    
    // MARK: - Lifecycle
    init(photographerId: String) {
        self.photographerId = photographerId
    }
    
    // MARK: - Public Methods
    
    /// Fetches the available service packages for the designated photographer from Firebase.
    func fetchPackages() async {
        do {
            let snapshot = try await databaseRef.child("servicePackages").child(photographerId).getData()
            if let children = snapshot.children.allObjects as? [DataSnapshot] {
                var fetchedPackages: [ServicePackage] = []
                for child in children {
                    if let dict = child.value as? [String: Any],
                       let jsonData = try? JSONSerialization.data(withJSONObject: dict),
                       let package = try? JSONDecoder().decode(ServicePackage.self, from: jsonData) {
                        fetchedPackages.append(package)
                    }
                }
                self.packages = fetchedPackages
            }
        } catch {
            print("Error fetching packages: \(error.localizedDescription)")
        }
    }
    
    /// Registers the user's selection of a specific time slot.
    func selectTimeSlot(_ time: String) {
        self.selectedTimeSlot = time
    }
    
    /// Registers the user's selection of a service package.
    func selectPackage(_ package: ServicePackage) {
        self.selectedPackage = package
    }
    
    /// Calculates the subtotal cost derived from the selected service package.
    func calculateSubtotal() -> Double {
        return selectedPackage?.price ?? 0.0
    }
    
    /// Calculates the final total cost by adding the platform fee to the subtotal.
    func calculateFinalTotal() -> Double {
        return calculateSubtotal() + platformFee
    }
    
    /// Assembles the booking details and writes the new record to the Firebase Realtime Database.
    func createBooking() async {
        guard let package = selectedPackage, let timeSlot = selectedTimeSlot else { return }
        
        isBookingInProgress = true
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let dateString = formatter.string(from: selectedDate)
        
        let newBookingId = UUID().uuidString
        let total = calculateFinalTotal()
        
        let bookingData: [String: Any] = [
            "bookingId": newBookingId,
            "photographerId": photographerId,
            "clientId": clientId,
            "packageId": package.packageId,
            "status": "Pending",
            "totalCost": total,
            "date": dateString,
            "timeSlot": timeSlot
        ]
        
        do {
            try await databaseRef.child("bookings").child(newBookingId).setValue(bookingData)
            self.bookingComplete = true
        } catch {
            print("Failed to save booking: \(error.localizedDescription)")
        }
        
        isBookingInProgress = false
    }
}
