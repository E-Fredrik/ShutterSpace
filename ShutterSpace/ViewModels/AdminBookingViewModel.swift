//
//  AdminBookingViewModel.swift
//  ShutterSpace
//
//  Created by Elifele Fredrik on 03/06/26.
//



import Combine
import FirebaseDatabase
import Foundation

@MainActor
class AdminBookingViewModel: ObservableObject {
    @Published var allBookings: [AdminBooking] = []
    @Published var isLoading: Bool = false
    @Published var searchText: String = ""
    
    
    @Published var totalPlatformVolume: Double = 0.0
    @Published var totalPlatformRevenue: Double = 0.0 
    @Published var pendingPayouts: Double = 0.0
    
    private let databaseRef = Database.database().reference()
    
    var filteredBookings: [AdminBooking] {
        if searchText.isEmpty {
            return allBookings
        } else {
            return allBookings.filter {
                $0.id.localizedCaseInsensitiveContains(searchText) ||
                $0.status.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    func fetchAllBookings() async {
        isLoading = true
        do {
            let snapshot = try await databaseRef.child("bookings").getData()
            
            if let children = snapshot.children.allObjects as? [DataSnapshot] {
                var fetched: [AdminBooking] = []
                var volume: Double = 0.0
                var pending: Double = 0.0
                
                for child in children {
                    if let dict = child.value as? [String: Any] {
                        
                        var extractedPrice: Double = 0.0
                        if let costVal = dict["totalCost"] {
                            if let doubleVal = costVal as? Double { extractedPrice = doubleVal }
                            else if let intVal = costVal as? Int { extractedPrice = Double(intVal) }
                        }
                        
                        let status = dict["status"] as? String ?? "Unknown"
                        
                        let booking = AdminBooking(
                            id: child.key, // Auto-generated push ID
                            clientId: dict["clientId"] as? String ?? "Unknown",
                            photographerId: dict["photographerId"] as? String ?? "Unknown",
                            status: status,
                            price: extractedPrice, // Using the new totalCost logic
                            date: dict["date"] as? String ?? "Unknown Date"
                        )
                        fetched.append(booking)
                        
                        // Calculate Financials
                        if status == "Completed" {
                            volume += extractedPrice
                        } else if status == "Pending" || status == "Accepted" {
                            pending += extractedPrice
                        }
                    }
                }
                
                self.allBookings = fetched.sorted { $0.date > $1.date } // Newest first
                self.totalPlatformVolume = volume
                self.totalPlatformRevenue = volume * 0.10 // 10% platform cut
                self.pendingPayouts = pending
            }
        } catch {
            print("Error fetching bookings: \(error.localizedDescription)")
        }
        isLoading = false
    }
}
