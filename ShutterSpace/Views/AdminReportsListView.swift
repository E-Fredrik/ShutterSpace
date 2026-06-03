//
//  AdminReportsListView.swift
//  ShutterSpace
//
//  Created by Elifele Fredrik on 03/06/26.
//

import SwiftUI

struct AdminReportsListView: View {
    @StateObject private var viewModel = AdminReportsViewModel()
    
    var body: some View {
        Group {
            if viewModel.isLoading {
                ProgressView("Loading Reports...")
            } else if viewModel.reports.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "checkmark.shield.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.green)
                    Text("No Reports")
                        .font(.title2)
                        .fontWeight(.semibold)
                    Text("The platform is currently clear of reported issues.")
                        .foregroundColor(.secondary)
                }
            } else {
                List {
                    ForEach(viewModel.reports) { report in
                        ReportRowView(report: report, viewModel: viewModel)
                    }
                }
                .listStyle(InsetGroupedListStyle())
            }
        }
        .navigationTitle("Manage Reports")
        .task {
            await viewModel.fetchReports()
        }
        .refreshable {
            await viewModel.fetchReports()
        }
        .preferredColorScheme(.dark)
    }
}

struct ReportRowView: View {
    let report: Report
    @ObservedObject var viewModel: AdminReportsViewModel
    @State private var isShowingActions = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(report.reason)
                    .font(.headline)
                    .foregroundColor(report.reason.contains("Scam") ? .red : .primary)
                
                Spacer()
                
                Text(report.status)
                    .font(.caption)
                    .fontWeight(.bold)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(statusColor(for: report.status).opacity(0.2))
                    .foregroundColor(statusColor(for: report.status))
                    .cornerRadius(8)
            }
            
            Text(report.description)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Divider()
            
            HStack {
                VStack(alignment: .leading) {
                    Text("Reporter ID: \(report.reporterId.prefix(8))...")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text("Reported ID: \(report.reportedUserId.prefix(8))...")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                if report.status == "Pending" {
                    Button {
                        isShowingActions = true
                    } label: {
                        Text("Take Action")
                            .font(.footnote)
                            .fontWeight(.semibold)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
        .padding(.vertical, 4)
        .confirmationDialog("Handle Report", isPresented: $isShowingActions, titleVisibility: .visible) {
            Button("Suspend Reported User", role: .destructive) {
                Task {
                    await viewModel.suspendReportedUser(userId: report.reportedUserId, reportId: report.reportId)
                }
            }
            Button("Mark as Resolved") {
                Task {
                    await viewModel.updateReportStatus(reportId: report.reportId, newStatus: "Resolved")
                }
            }
            Button("Dismiss Report") {
                Task {
                    await viewModel.updateReportStatus(reportId: report.reportId, newStatus: "Dismissed")
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Select an action to handle this report. Suspending the user will restrict their platform access immediately.")
        }
    }
    
    private func statusColor(for status: String) -> Color {
        if status == "Pending" { return .orange }
        if status.contains("Resolved") { return .green }
        return .gray
    }
}
