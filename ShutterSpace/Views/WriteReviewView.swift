//
//  WriteReviewView.swift
//  ShutterSpace
//
//  Created by Elifele Fredrik on 01/06/26.
//

import SwiftUI

struct WriteReviewView: View {
    let session: SessionItem
    @ObservedObject var viewModel: MySessionsViewModel

    @Environment(\.dismiss) private var dismiss

    @State private var selectedStarRating: Int = 0
    @State private var writtenReview: String = ""
    @State private var isSubmitting: Bool = false
    @State private var submitErrorMessage: String = ""

    private var isSubmitEnabled: Bool {
        selectedStarRating > 0 && !writtenReview.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 32) {
                    renderPhotographerHeader()
                    renderStarSelector()
                    renderWrittenReviewField()
                    if !submitErrorMessage.isEmpty {
                        Text(submitErrorMessage)
                            .font(.footnote)
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    renderSubmitButton()
                }
                .padding()
            }
            .navigationTitle("Leave a Review")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .preferredColorScheme(.dark)
        }
    }

    private func renderPhotographerHeader() -> some View {
        VStack(spacing: 8) {
            Image(systemName: "camera.aperture")
                .font(.system(size: 48))
                .foregroundColor(.white)
            Text(session.photographerName)
                .font(.title2)
                .fontWeight(.bold)
            Text(session.packageTitle)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding(.top, 16)
    }

    private func renderStarSelector() -> some View {
        VStack(spacing: 12) {
            Text("How was your experience?")
                .font(.headline)
            HStack(spacing: 12) {
                ForEach(1...5, id: \.self) { starIndex in
                    Button {
                        selectedStarRating = starIndex
                    } label: {
                        Image(systemName: starIndex <= selectedStarRating ? "star.fill" : "star")
                            .font(.system(size: 36))
                            .foregroundColor(starIndex <= selectedStarRating ? .yellow : .secondary)
                            .scaleEffect(starIndex == selectedStarRating ? 1.2 : 1.0)
                            .animation(.spring(response: 0.3, dampingFraction: 0.5), value: selectedStarRating)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            if selectedStarRating > 0 {
                Text(ratingLabel(for: selectedStarRating))
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .transition(.opacity)
                    .animation(.easeInOut, value: selectedStarRating)
            }
        }
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(16)
    }

    private func renderWrittenReviewField() -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Share your thoughts")
                .font(.headline)
            ZStack(alignment: .topLeading) {
                if writtenReview.isEmpty {
                    Text("Tell others about your session with this photographer...")
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 4)
                        .padding(.vertical, 8)
                }
                TextEditor(text: $writtenReview)
                    .frame(minHeight: 120)
                    .scrollContentBackground(.hidden)
            }
            .padding(12)
            .background(Color(UIColor.secondarySystemBackground))
            .cornerRadius(12)
        }
    }

    private func renderSubmitButton() -> some View {
        Button {
            Task {
                isSubmitting = true
                submitErrorMessage = ""
                await viewModel.submitReview(
                    bookingId: session.bookingId,
                    photographerId: session.photographerId,
                    starRating: selectedStarRating,
                    writtenReview: writtenReview.trimmingCharacters(in: .whitespacesAndNewlines)
                )
                isSubmitting = false
                if viewModel.errorMessage.isEmpty {
                    dismiss()
                } else {
                    submitErrorMessage = viewModel.errorMessage
                }
            }
        } label: {
            Group {
                if isSubmitting {
                    ProgressView()
                        .tint(.black)
                } else {
                    Text("Submit Review")
                        .fontWeight(.semibold)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(isSubmitEnabled ? Color.white : Color.gray.opacity(0.4))
            .foregroundColor(isSubmitEnabled ? .black : .secondary)
            .cornerRadius(12)
        }
        .disabled(!isSubmitEnabled || isSubmitting)
    }

    private func ratingLabel(for starRating: Int) -> String {
        switch starRating {
        case 1: return "Poor"
        case 2: return "Fair"
        case 3: return "Good"
        case 4: return "Very Good"
        case 5: return "Excellent!"
        default: return ""
        }
    }
}
