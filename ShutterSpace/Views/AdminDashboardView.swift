//
//  AdminDashboardView.swift
//  ShutterSpace
//
//  Created by Elifele Fredrik on 01/06/26.
//

//
//  AdminDashboardView.swift
//  ShutterSpace
//
//  Created by Elifele Fredrik on 01/06/26.
//

import SwiftUI

struct AdminDashboardView: View {
    @StateObject private var authViewModel = AuthViewModel()

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Image(systemName: "lock.shield.fill")
                    .font(.system(size: 70))
                    .foregroundColor(.blue)
                    .padding(.top, 40)

                Text("Admin Dashboard")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                Text("System Administrator Access")
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                List {
                    Section(header: Text("System Management")) {

                        NavigationLink(destination: AdminUserListView()) {
                            Label("Manage Users", systemImage: "person.3.fill")
                        }

                        NavigationLink(destination: AdminBookingListView()) {
                            Label(
                                "Manage Bookings",
                                systemImage: "calendar.badge.clock"
                            )
                        }

                        NavigationLink(destination: AdminFinancialReportView())
                        {
                            Label(
                                "Financial Reports",
                                systemImage: "chart.line.uptrend.xyaxis"
                            )
                        }
                        NavigationLink(destination: AdminReportsListView()) {
                            Label(
                                "User Reports",
                                systemImage: "exclamationmark.shield.fill"
                            )
                        }
                    }
                }
                .listStyle(InsetGroupedListStyle())
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(role: .destructive) {
                        authViewModel.logout()
                    } label: {
                        Label(
                            "Log Out",
                            systemImage: "rectangle.portrait.and.arrow.right"
                        )
                        .foregroundColor(.red)
                    }
                }
            }
            .preferredColorScheme(.dark)
        }
    }
}

#Preview {
    AdminDashboardView()
}
