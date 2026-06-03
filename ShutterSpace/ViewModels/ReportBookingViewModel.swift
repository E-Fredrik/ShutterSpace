//
//  ReportBookingViewModel.swift
//  ShutterSpace
//
//  Created by Elifele Fredrik on 03/06/26.
//

import Combine
import FirebaseDatabase
import Foundation

@MainActor
class ReportBookingViewModel: ObservableObject {
    @Published var isSubmitting: Bool = false
    @Published var errorMessage: String? = nil
    @Published var isSuccess: Bool = false
    
    private let databaseRef = Database.database().reference()
    
    var currentUserId: String {
        UserDefaults.standard.string(forKey: "currentUserId") ?? ""
    }
    
    func submitReport(bookingId: String, reportedUserId: String, reason: String, description: String) async {
        isSubmitting = true
        self.errorMessage = nil
        
        let reportId = UUID().uuidString
        let reportData: [String: Any] = [
            "reportId": reportId,
            "bookingId": bookingId,
            "reporterId": currentUserId,
            "reportedUserId": reportedUserId,
            "reason": reason,
            "description": description,
            "status": "Pending",
            "timestamp": Date().timeIntervalSince1970
        ]
        
        do {
            try await databaseRef.child("reports").child(reportId).setValue(reportData)
            self.isSuccess = true
        } catch {
            self.errorMessage = "Failed to submit report: \(error.localizedDescription)"
        }
        
        isSubmitting = false
    }
}
