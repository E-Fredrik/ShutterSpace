//
//  BookingViewModel.swift
//  ShutterSpace
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

    @Published var availableTimeSlots: [String] = []
    
    @Published var activeBookings: [(date: String, startMin: Int, endMin: Int)] = []
    
    @Published var isBookingInProgress: Bool = false
    @Published var bookingComplete: Bool = false
    @Published var paymentErrorMessage: String? = nil
    @Published var showErrorAlert: Bool = false // NEW: Handles error popups

    let platformFee: Double = 15000.0
    let photographerId: String
    var clientId: String {
        UserDefaults.standard.string(forKey: "currentUserId") ?? ""
    }

    private let databaseRef = Database.database().reference()

    init(photographerId: String) {
        self.photographerId = photographerId
    }
    
    private func timeToMinutes(_ timeStr: String) -> Int { //Formats time strings like "10:30 AM" or "2 PM" into total minutes from midnight for easier calculations
        let cleanStr = timeStr.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        let isPM = cleanStr.contains("pm")
        let isAM = cleanStr.contains("am")

        let numbersOnly = cleanStr.replacingOccurrences(of: "am", with: "")
                                  .replacingOccurrences(of: "pm", with: "")
                                  .trimmingCharacters(in: .whitespacesAndNewlines)

        let components = numbersOnly.components(separatedBy: CharacterSet(charactersIn: ":."))
        if components.isEmpty { return 0 }

        var hours = Int(components[0]) ?? 0
        let minutes = components.count > 1 ? (Int(components[1]) ?? 0) : 0

        if isPM && hours < 12 { hours += 12 }
        if isAM && hours == 12 { hours = 0 }

        return (hours * 60) + minutes
    }

    func fetchPackages() async {
        do {
            let snapshot = try await databaseRef.child("servicePackages").child(photographerId).getData()
            if let children = snapshot.children.allObjects as? [DataSnapshot] {
                var fetchedPackages: [ServicePackage] = []
                for child in children {
                    if let dict = child.value as? [String: Any],
                        let jsonData = try? JSONSerialization.data(withJSONObject: dict),
                        let package = try? JSONDecoder().decode(ServicePackage.self, from: jsonData)
                    {
                        fetchedPackages.append(package)
                    }
                }
                self.packages = fetchedPackages
            }
        } catch { }
    }

    func fetchAvailableTimeSlots() async {
        do {
            let snapshot = try await databaseRef.child("availability").child(photographerId).child("timeSlots").getData()
            self.availableTimeSlots = snapshot.value as? [String] ?? []
        } catch { }
    }

    func fetchAllBookedTimeSlots() async {
        do {
            let snapshot = try await databaseRef.child("bookings").getData()
            guard let children = snapshot.children.allObjects as? [DataSnapshot] else {
                self.activeBookings = []
                return
            }

            var fetched: [(date: String, startMin: Int, endMin: Int)] = []

            for child in children {
                guard
                    let dict = child.value as? [String: Any],
                    let photoId = dict["photographerId"] as? String,
                    photoId == photographerId,
                    let status = dict["status"] as? String,
                    status == "Accepted" || status == "Completed" || status == "Pending",
                    let bookingDate = dict["date"] as? String,
                    let timeSlot = dict["timeSlot"] as? String
                else { continue }

                let duration = dict["duration"] as? Int ?? 60
                let startMin = timeToMinutes(timeSlot)
                let endMin = startMin + duration
                
                fetched.append((date: bookingDate, startMin: startMin, endMin: endMin))
            }
            self.activeBookings = fetched
        } catch {
            self.activeBookings = []
        }
    }
    
    func isSlotAvailable(_ time: String) -> Bool {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let selectedDateString = formatter.string(from: selectedDate)
        
        let startMin = timeToMinutes(time)
        let duration = selectedPackage?.duration ?? 1
        let endMin = startMin + duration

        for booking in activeBookings {
            if booking.date == selectedDateString {
                if startMin < booking.endMin && endMin > booking.startMin {
                    return false
                }
            }
        }
        return true
    }

    func selectTimeSlot(_ time: String) { self.selectedTimeSlot = time }
    func selectPackage(_ package: ServicePackage) { self.selectedPackage = package }
    func calculateSubtotal() -> Double { return selectedPackage?.price ?? 0.0 }
    func calculateFinalTotal() -> Double { return calculateSubtotal() + platformFee }

    @Published var currentBookingId: String? = nil

    // FIXED: No longer requires parameters. Fetches user data directly from Firebase!
    func setupMidtransPayment() async throws -> URL {
        isBookingInProgress = true
        paymentErrorMessage = nil
        showErrorAlert = false

        // 1. Fetch current user credentials automatically
        var firstName = "Client"
        var lastName = ""
        var email = "client@shutterspace.com"
        
        do {
            let snapshot = try await databaseRef.child("users").child(clientId).getData()
            if let dict = snapshot.value as? [String: Any] {
                firstName = dict["firstName"] as? String ?? "Client"
                lastName = dict["lastName"] as? String ?? ""
                email = dict["email"] as? String ?? "client@shutterspace.com"
            }
        } catch {
            print("Error fetching user data, proceeding with defaults: \(error.localizedDescription)")
        }

        let newBookingId = UUID().uuidString
        self.currentBookingId = newBookingId
        let total = calculateFinalTotal()

        do {
            // 2. Generate the URL using the auto-fetched data
            let urlString = try await MidtransManager.shared.fetchSnapUrl(
                orderId: newBookingId, amount: total, firstName: firstName, lastName: lastName, email: email
            )
            await createBooking(bookingId: newBookingId, status: "Awaiting Payment")
            isBookingInProgress = false
            return URL(string: urlString)!
        } catch {
            self.paymentErrorMessage = error.localizedDescription
            self.showErrorAlert = true
            self.isBookingInProgress = false
            throw error
        }
    }

    func markBookingAsPaid() {
        guard let bookingId = currentBookingId else { return }
        let updates: [String: Any] = ["status": "Pending", "paymentStatus": "Escrow Held"]
        databaseRef.child("bookings").child(bookingId).updateChildValues(updates)
        self.bookingComplete = true
    }

    func cancelBooking() {
        guard let bookingId = currentBookingId else { return }
        databaseRef.child("bookings").child(bookingId).removeValue()
        self.currentBookingId = nil
    }

    private func createBooking(bookingId: String, status: String) async {
        guard let package = selectedPackage, let timeSlot = selectedTimeSlot else { return }
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"

        let bookingData: [String: Any] = [
            "bookingId": bookingId,
            "photographerId": photographerId,
            "clientId": clientId,
            "packageId": package.packageId,
            "status": status,
            "totalCost": calculateFinalTotal(),
            "date": formatter.string(from: selectedDate),
            "timeSlot": timeSlot,
            "duration": package.duration
        ]
        try? await databaseRef.child("bookings").child(bookingId).setValue(bookingData)
    }
}
