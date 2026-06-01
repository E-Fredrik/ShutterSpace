//
//  BookingViewModel.swift
//  ShutterSpace
//
//  Created by Sean tandjaja on 31/05/26.
//

import Combine
import FirebaseDatabase
import Foundation

@MainActor
class BookingViewModel: ObservableObject {
    @Published var selectedDate: Date = Date()
    @Published var selectedTimeSlot: String?
    @Published var selectedPackage: ServicePackage?
    @Published var packages: [ServicePackage] = []

    @Published var availableTimeSlots: [String] = [
        "9:00 AM", "12:00 PM", "1:30 PM", "4:30 PM",
    ]
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
            let snapshot = try await databaseRef.child("servicePackages").child(
                photographerId
            ).getData()
            if let children = snapshot.children.allObjects as? [DataSnapshot] {
                var fetchedPackages: [ServicePackage] = []
                for child in children {
                    if let dict = child.value as? [String: Any],
                        let jsonData = try? JSONSerialization.data(
                            withJSONObject: dict
                        ),
                        let package = try? JSONDecoder().decode(
                            ServicePackage.self,
                            from: jsonData
                        )
                    {
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

    //    func processPaymentAndBook(cardNumber: String, expMonth: String, expYear: String, cvv: String, firstName: String, lastName: String) async throws {
    //        isBookingInProgress = true
    //        paymentErrorMessage = nil
    //
    //        do {
    //            let paymentToken = try await XenditManager.shared.createToken(
    //                cardNumber: cardNumber,
    //                expMonth: expMonth,
    //                expYear: expYear,
    //                cvv: cvv,
    //                amount: calculateFinalTotal(),
    //                firstName: firstName,
    //                lastName: lastName
    //            )
    //
    //            await createBooking(paymentTokenId: paymentToken)
    //            self.bookingComplete = true
    //
    //        } catch let error as SafePaymentError {
    //            self.paymentErrorMessage = error.localizedDescription
    //            isBookingInProgress = false
    //            throw error
    //        } catch {
    //            self.paymentErrorMessage = "An unexpected error occurred: \(error.localizedDescription)"
    //            isBookingInProgress = false
    //            throw error
    //        }
    //
    //        isBookingInProgress = false
    //    }

    @Published var currentBookingId: String? = nil

    func setupMidtransPayment(
        firstName: String,
        lastName: String,
        email: String
    ) async throws -> URL {
        isBookingInProgress = true
        paymentErrorMessage = nil

        let newBookingId = UUID().uuidString
        self.currentBookingId = newBookingId
        let total = calculateFinalTotal()

        do {
            let urlString = try await MidtransManager.shared.fetchSnapUrl(
                orderId: newBookingId,
                amount: total,
                firstName: firstName,
                lastName: lastName,
                email: email
            )

            await createBooking(
                bookingId: newBookingId,
                status: "Awaiting Payment"
            )

            isBookingInProgress = false
            return URL(string: urlString)!

        } catch {
            self.paymentErrorMessage = error.localizedDescription
            isBookingInProgress = false
            throw error
        }
    }

    func markBookingAsPaid() {
            guard let bookingId = currentBookingId else { return }
       
            let updates: [String: Any] = [
                "status": "Pending",
                "paymentStatus": "Escrow Held"
            ]
            
            databaseRef.child("bookings").child(bookingId).updateChildValues(updates)
            self.bookingComplete = true
        }

    private func createBooking(bookingId: String, status: String) async {
        guard let package = selectedPackage, let timeSlot = selectedTimeSlot
        else { return }

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let dateString = formatter.string(from: selectedDate)

        let total = calculateFinalTotal()

        let bookingData: [String: Any] = [
            "bookingId": bookingId,
            "photographerId": photographerId,
            "clientId": clientId,
            "packageId": package.packageId,
            "status": status,
            "totalCost": total,
            "date": dateString,
            "timeSlot": timeSlot,
        ]

        try? await databaseRef.child("bookings").child(bookingId).setValue(
            bookingData
        )
    }

    private func createBooking(paymentTokenId: String) async {
        guard let package = selectedPackage, let timeSlot = selectedTimeSlot
        else { return }

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
            "timeSlot": timeSlot,
        ]

        do {
            try await databaseRef.child("bookings").child(newBookingId)
                .setValue(bookingData)
        } catch {
            self.paymentErrorMessage =
                "Database Error: Could not finalize booking."
        }
    }
}
