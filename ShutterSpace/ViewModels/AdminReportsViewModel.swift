//
//  AdminReportsViewModel.swift
//  ShutterSpace
//
//  Created by Elifele Fredrik on 03/06/26.
//

import Combine
import FirebaseDatabase
import Foundation

@MainActor
class AdminReportsViewModel: ObservableObject {
    @Published var reports: [Report] = []
    @Published var isLoading: Bool = false
    
    private let databaseRef = Database.database().reference()
    
    func fetchReports() async { //Shows reports that has been submitted by users, sorted by pending first and then by newest
        isLoading = true
        do {
            let snapshot = try await databaseRef.child("reports").getData()
            if let children = snapshot.children.allObjects as? [DataSnapshot] {
                var fetchedReports: [Report] = []
                for child in children {
                    if let dict = child.value as? [String: Any],
                       let jsonData = try? JSONSerialization.data(withJSONObject: dict),
                       let report = try? JSONDecoder().decode(Report.self, from: jsonData) {
                        fetchedReports.append(report)
                    }
                }
                // Sort to show pending reports first, then by newest
                self.reports = fetchedReports.sorted { 
                    if $0.status == $1.status {
                        return $0.timestamp > $1.timestamp
                    }
                    return $0.status == "Pending"
                }
            }
        } catch {
            print("Error fetching reports: \(error.localizedDescription)")
        }
        isLoading = false
    }
    
    func updateReportStatus(reportId: String, newStatus: String) async {
        do {
            try await databaseRef.child("reports").child(reportId).updateChildValues(["status": newStatus])
            await fetchReports()
        } catch {
            print("Error updating report status: \(error.localizedDescription)")
        }
    }
    
    func suspendReportedUser(userId: String, reportId: String) async {
        do {
            // 1. Suspend the user to handle the scam situation
            try await databaseRef.child("users").child(userId).updateChildValues(["status": "Suspended"])
            // 2. Mark the report as resolved
            try await databaseRef.child("reports").child(reportId).updateChildValues(["status": "Resolved (User Suspended)"])
            await fetchReports()
        } catch {
            print("Error suspending user: \(error.localizedDescription)")
        }
    }
}
