//
//  AwaitingScansView.swift
//  cargo-mobile
//
//  Created by Аяжан on 6/11/2024.
//

import Foundation
import SwiftUI
import AVFoundation
import Foundation
import UIKit

struct AwaitingScansView: View {
    @StateObject private var viewModel = AwaitingScansViewModel()
    @State private var searchText = ""
    @State private var showError = false
    
    var filteredScans: [CargoLabel] {
        if searchText.isEmpty {
            return viewModel.awaitingCargo.sorted { $0.deadline ?? Date() < $1.deadline ?? Date() }
        }
        return viewModel.awaitingCargo.filter { cargo in
            cargo.awbNumber.localizedCaseInsensitiveContains(searchText) ||
            cargo.destination.localizedCaseInsensitiveContains(searchText) ||
            cargo.description.localizedCaseInsensitiveContains(searchText)
        }.sorted { $0.deadline ?? Date() < $1.deadline ?? Date() }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                if viewModel.isLoading {
                    ProgressView("Loading cargo...")
                        .scaleEffect(1.2)
                } else if viewModel.error != nil {
                    VStack(spacing: 16) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.largeTitle)
                            .foregroundColor(.red)
                        Text(viewModel.error ?? "Unknown error")
                            .multilineTextAlignment(.center)
                        Button("Try Again") {
                            Task {
                                await viewModel.loadAwaitingCargo()
                            }
                        }
                        .buttonStyle(.bordered)
                    }
                    .padding()
                } else {
                    List {
                        ForEach(filteredScans) { cargo in
                            NavigationLink(destination: CargoDetailView(cargo: cargo)) {
                                CargoRowView(cargo: cargo)
                            }
                        }
                    }
                    .refreshable {
                        await viewModel.loadAwaitingCargo()
                    }
                    .searchable(text: $searchText, prompt: "Search AWB, destination...")
                    .overlay(Group {
                        if filteredScans.isEmpty {
                            ContentUnavailableView(
                                label: {
                                    Label(
                                        searchText.isEmpty ? "No Cargo" : "No Results",
                                        systemImage: searchText.isEmpty ? "shippingbox" : "magnifyingglass"
                                    )
                                },
                                description: {
                                    Text(searchText.isEmpty ? "No cargo waiting to be scanned" : "Try searching with different terms")
                                }
                            )
                        }
                    })
                }
            }
            .navigationTitle("Awaiting Scans")
            .alert("Error", isPresented: $showError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(viewModel.error ?? "Unknown error occurred")
            }
        }
        .task {
            await viewModel.loadAwaitingCargo()
        }
    }
}


struct CargoRowView: View {
    let cargo: CargoLabel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(cargo.awbNumber)
                    .font(.headline)
                Spacer()
                if let deadline = cargo.deadline {
                    TimeRemainingView(deadline: deadline)
                }
            }
            
            HStack {
                Image(systemName: "airplane")
                Text("\(cargo.origin) → \(cargo.destination)")
            }
            .font(.subheadline)
            
            if !cargo.specialHandling.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(cargo.specialHandling, id: \.self) { code in
                            Text(code)
                                .font(.caption)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.orange)
                                .foregroundColor(.white)
                                .cornerRadius(4)
                        }
                    }
                }
            }
            
            if let deadline = cargo.deadline {
                HStack {
                    Image(systemName: "clock")
                    Text("Load until: \(deadline.formatted(date: .abbreviated, time: .shortened))")
                }
                .font(.caption)
                .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

struct TimeRemainingView: View {
    let deadline: Date
    @State private var timeRemaining: TimeInterval = 0
    let timer = Timer.publish(every: 60, on: .main, in: .common).autoconnect()
    
    var body: some View {
        Text(formatTimeRemaining())
            .font(.caption)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(timeRemainingColor)
            .foregroundColor(.white)
            .cornerRadius(4)
            .onAppear {
                updateTimeRemaining()
            }
            .onReceive(timer) { _ in
                updateTimeRemaining()
            }
    }
    
    private func updateTimeRemaining() {
        timeRemaining = deadline.timeIntervalSinceNow
    }
    
    private func formatTimeRemaining() -> String {
        let hours = Int(timeRemaining / 3600)
        let minutes = Int((timeRemaining.truncatingRemainder(dividingBy: 3600)) / 60)
        return "\(hours)h \(minutes)m"
    }
    
    private var timeRemainingColor: Color {
        if timeRemaining < 3600 { // Less than 1 hour
            return .red
        } else if timeRemaining < 7200 { // Less than 2 hours
            return .orange
        } else {
            return .blue
        }
    }
}

@MainActor
class AwaitingScansViewModel: ObservableObject {
    @Published var awaitingCargo: [CargoLabel] = []
    @Published var isLoading = false
    @Published var error: String?
    
    func loadAwaitingCargo() async {
        isLoading = true
        error = nil
        
        do {
            awaitingCargo = try await APIService.shared.fetchAwaitingCargo()
        } catch let error as APIError {
            self.error = error.localizedDescription
        } catch {
            self.error = "Failed to load cargo: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
}
