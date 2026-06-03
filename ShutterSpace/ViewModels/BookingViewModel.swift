//
//  BookingViewModel.swift
//  ShutterSpace
//

import Combine
import FirebaseDatabase
import Foundation

struct BookedInterval {
    let startMin: Int
    let endMin: Int
}

@MainActor
class BookingViewModel: ObservableObject {
    @Published var selectedDate: Date = Date()
    @Published var selectedTimeSlot: String?
    @Published var selectedPackage: ServicePackage?
    @Published var packages: [ServicePackage] = []

    @Published var availableTimeSlots: [String] = []
    @Published var bookedIntervals: [BookedInterval] = []
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
    
    private func timeToMinutes(_ timeStr: String) -> Int {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        
        formatter.dateFormat = "h:mm a"
        if let date = formatter.date(from: timeStr) {
            let cal = Calendar.current
            return cal.component(.hour, from: date) * 60 + cal.component(.minute, from: date)
        }
        
        formatter.dateFormat = "HH:mm"
        if let date = formatter.date(from: timeStr) {
            let cal = Calendar.current
            return cal.component(.hour, from: date) * 60 + cal.component(.minute, from: date)
        }
        return 0
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

    func fetchBookedTimeSlots() async {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let selectedDateString = formatter.string(from: selectedDate)

        do {
            let snapshot = try await databaseRef.child("bookings").getData()
            guard let children = snapshot.children.allObjects as? [DataSnapshot] else {
                self.bookedIntervals = []
                return
            }

            var intervals: [BookedInterval] = []

            for child in children {
                guard
                    let dict = child.value as? [String: Any],
                    let photoId = dict["photographerId"] as? String,
                    photoId == photographerId,
                    let status = dict["status"] as? String,
                    status == "Accepted" || status == "Completed",
                    let bookingDate = dict["date"] as? String,
                    bookingDate == selectedDateString,
                    let timeSlot = dict["timeSlot"] as? String
                else { continue }

                let duration = dict["duration"] as? Int ?? 60
                let startMin = timeToMinutes(timeSlot)
                let endMin = startMin + duration
                
                intervals.append(BookedInterval(startMin: startMin, endMin: endMin))
            }

            self.bookedIntervals = intervals
        } catch {
            self.bookedIntervals = []
        }
    }
    
    func isSlotAvailable(_ time: String) -> Bool {
        let startMin = timeToMinutes(time)
        let duration = selectedPackage?.duration ?? 1
        let endMin = startMin + duration

        for interval in bookedIntervals {
            if startMin < interval.endMin && endMin > interval.startMin {
                return false
            }
        }
        return true
    }

    func selectTimeSlot(_ time: String) { self.selectedTimeSlot = time }
    func selectPackage(_ package: ServicePackage) { self.selectedPackage = package }
    func calculateSubtotal() -> Double { return selectedPackage?.price ?? 0.0 }
    func calculateFinalTotal() -> Double { return calculateSubtotal() + platformFee }

    @Published var currentBookingId: String? = nil

    func setupMidtransPayment(firstName: String, lastName: String, email: String) async throws -> URL {
        isBookingInProgress = true
        paymentErrorMessage = nil

        let newBookingId = UUID().uuidString
        self.currentBookingId = newBookingId
        let total = calculateFinalTotal()

        do {
            let urlString = try await MidtransManager.shared.fetchSnapUrl(
                orderId: newBookingId, amount: total, firstName: firstName, lastName: lastName, email: email
            )
            await createBooking(bookingId: newBookingId, status: "Awaiting Payment")
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
        let updates: [String: Any] = ["status": "Pending", "paymentStatus": "Escrow Held"]
        databaseRef.child("bookings").child(bookingId).updateChildValues(updates)
        self.bookingComplete = true
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
