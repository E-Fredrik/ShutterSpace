//
//  ManageAvailabilityView.swift
//  ShutterSpace
//
//  Created by Elifele Fredrik on 01/06/26.
//

import SwiftUI

struct ManageAvailabilityView: View {

    @StateObject private var viewModel: ManageAvailabilityViewModel = ManageAvailabilityViewModel()
    
    @State private var selectedTime: Date = Date()

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading {
                    renderLoadingState()
                } else {
                    renderContent()
                }
            }
            .navigationTitle("Manage Availability")
            .navigationBarTitleDisplayMode(.large)
            .task {
                await viewModel.fetchTimeSlots()
            }
            .preferredColorScheme(.dark)
        }
    }

    private func renderLoadingState() -> some View {
        VStack(spacing: 16) {
            ProgressView()
            Text("Loading your availability...")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func renderContent() -> some View {
        List {
            renderAddSlotSection()
            renderExistingSlotsSection()
        }
        .listStyle(.insetGrouped)
        .scrollContentBackground(.hidden)
        .background(Color(UIColor.systemBackground))
    }

    private func renderAddSlotSection() -> some View {
        Section {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Text("Time")
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    DatePicker(
                        "Select Time",
                        selection: $selectedTime,
                        displayedComponents: .hourAndMinute
                    )
                    .labelsHidden()
                    .datePickerStyle(.compact)

                    Button {
                        let formatter = DateFormatter()
                        formatter.dateFormat = "H:mm"
                        viewModel.newTimeSlotInput = formatter.string(from: selectedTime)
                        
                        Task { await viewModel.addTimeSlot() }
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .foregroundColor(.white)
                            .padding(.leading, 8)
                    }
                }

                if viewModel.shouldShowDuplicateError {
                    Text("This time slot already exists.")
                        .font(.caption)
                        .foregroundColor(.red)
                        .transition(.opacity)
                        .animation(.easeInOut, value: viewModel.shouldShowDuplicateError)
                }
            }
            .padding(.vertical, 4)
        } header: {
            Text("Add Time Slot")
        } footer: {
            Text("Select a time using the picker and tap + to add it.")
                .font(.caption)
        }
    }

    private func renderExistingSlotsSection() -> some View {
        Section {
            if viewModel.availableTimeSlots.isEmpty {
                Text("No time slots added yet.")
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 8)
            } else {
                ForEach(viewModel.availableTimeSlots, id: \.self) { timeSlot in
                    HStack {
                        Image(systemName: "clock")
                            .foregroundColor(.secondary)
                            .frame(width: 24)
                        Text(timeSlot)
                    }
                }
                .onDelete { offsets in
                    Task { await viewModel.removeTimeSlots(at: offsets) }
                }
            }
        } header: {
            HStack {
                Text("Current Time Slots")
                Spacer()
                if !viewModel.availableTimeSlots.isEmpty {
                    EditButton()
                        .font(.subheadline)
                }
            }
        }
    }
}

#Preview {
    ManageAvailabilityView()
}
