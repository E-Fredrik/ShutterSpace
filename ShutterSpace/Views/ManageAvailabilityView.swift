//
//  ManageAvailabilityView.swift
//  ShutterSpace
//
//  Created by Elifele Fredrik on 01/06/26.
//

import SwiftUI

struct ManageAvailabilityView: View {

    // MARK: - Properties

    @StateObject private var viewModel: ManageAvailabilityViewModel = ManageAvailabilityViewModel()
    @FocusState private var isInputFocused: Bool

    // MARK: - Body

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

    // MARK: - Sub-views

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
                    TextField("e.g. 9:00 AM", text: $viewModel.newTimeSlotInput)
                        .focused($isInputFocused)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)

                    Button {
                        isInputFocused = false
                        Task { await viewModel.addTimeSlot() }
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .foregroundColor(.white)
                    }
                    .disabled(viewModel.newTimeSlotInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
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
            Text("Type the time in any format (e.g. 9:00 AM, 14:00) and tap + to add it.")
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
