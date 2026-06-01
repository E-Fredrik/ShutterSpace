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
    @Published var selectedDate: Date = Date()
    @Published var selectedTimeSlot: String?
    @Published var selectedPackage: ServicePackage?
    @Published var packages: [ServicePackage] = []
    
    @Published var availableTimeSlots: [String] = ["9:00 AM", "12:00 PM", "1:30 PM", "4:30 PM"]
    @Published var isBookingInProgress: Bool = false
    @Published var bookingComplete: Bool = false
    @Published var paymentErrorMessage: String? = nil
    
    let platformFee: Double = 15000.0
    let photographerId: String
    var clientId: String {
        UserDefaults.standard.string(forKey: "currentUserId") ?? ""
    }
    
    private let databaseRef = Database.database().reference()
    
    init(photographerId: String) {
        self.photographerId = photographerId
    }
    
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
    
    func selectTimeSlot(_ time: String) {
        self.selectedTimeSlot = time
    }
    
    func selectPackage(_ package: ServicePackage) {
        self.selectedPackage = package
    }
    
    func calculateSubtotal() -> Double {
        return selectedPackage?.price ?? 0.0
    }
    
    func calculateFinalTotal() -> Double {
        return calculateSubtotal() + platformFee
    }
    
        func processPaymentAndBook(cardName: String, cardNumber: String, expMonth: String, expYear: String, cvv: String) async throws {
            isBookingInProgress = true
            paymentErrorMessage = nil
            
            let nameComponents = cardName.trimmingCharacters(in: .whitespacesAndNewlines).components(separatedBy: " ")
            let firstName = nameComponents.first ?? "Client"
            let lastName = nameComponents.count > 1 ? nameComponents.dropFirst().joined(separator: " ") : firstName
            
            do {
                let paymentToken = try await XenditManager.shared.createToken(
                    firstName: firstName,
                    lastName: lastName,
                    cardNumber: cardNumber,
                    expMonth: expMonth,
                    expYear: expYear,
                    cvv: cvv,
                    amount: calculateFinalTotal()
                )
                
                await createBooking(paymentTokenId: paymentToken)
                
                self.bookingComplete = true
            } catch let error as SafePaymentError {
                self.paymentErrorMessage = error.localizedDescription
                isBookingInProgress = false
                throw error
            } catch {
                self.paymentErrorMessage = "An unexpected error occurred: \(error.localizedDescription)"
                isBookingInProgress = false
                throw error
            }
            
            isBookingInProgress = false
        }
    
    private func createBooking(paymentTokenId: String) async {
        guard let package = selectedPackage, let timeSlot = selectedTimeSlot else { return }
        
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
            "status": "Paid",
            "paymentTokenId": paymentTokenId, 
            "totalCost": total,
            "date": dateString,
            "timeSlot": timeSlot
        ]
        
        do {
            try await databaseRef.child("bookings").child(newBookingId).setValue(bookingData)
        } catch {
            self.paymentErrorMessage = "Database Error: Could not finalize booking."
        }
    }
}
