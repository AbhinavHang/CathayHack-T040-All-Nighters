//
//  HistoryView.swift
//  cargo-mobile
//
//  Created by Аяжан on 6/11/2024.
//

import Foundation
import SwiftUI
import AVFoundation
import Foundation
import UIKit

// HistoryView.swift
struct HistoryView: View {
    @StateObject private var viewModel = HistoryViewModel()
    @State private var searchText = ""
    
    var filteredHistory: [CargoLabel] {
        if searchText.isEmpty {
            return viewModel.historyItems.sorted { $0.timestamp > $1.timestamp } // Most recent first
        }
        return viewModel.historyItems.filter { cargo in
            cargo.awbNumber.localizedCaseInsensitiveContains(searchText) ||
            cargo.destination.localizedCaseInsensitiveContains(searchText) ||
            cargo.description.localizedCaseInsensitiveContains(searchText) ||
            cargo.shipper.localizedCaseInsensitiveContains(searchText)
        }.sorted { $0.timestamp > $1.timestamp }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                if viewModel.isLoading {
                    ProgressView("Loading history...")
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
                                await viewModel.loadHistory()
                            }
                        }
                        .buttonStyle(.bordered)
                    }
                    .padding()
                } else {
                    List {
                        ForEach(filteredHistory) { cargo in
                            NavigationLink(destination: CargoDetailView(cargo: cargo)) {
                                HistoryItemRow(cargo: cargo)
                            }
                        }
                    }
                    .searchable(text: $searchText, prompt: "Search AWB, destination...")
                    .overlay(Group {
                        if filteredHistory.isEmpty {
                            ContentUnavailableView(
                                label: {
                                    Label(
                                        searchText.isEmpty ? "No History" : "No Results",
                                        systemImage: searchText.isEmpty ? "clock.arrow.circlepath" : "magnifyingglass"
                                    )
                                },
                                description: {
                                    Text(searchText.isEmpty ? "No completed cargo items yet" : "Try searching with different terms")
                                }
                            )
                        }
                    })
                }
            }
            .navigationTitle("History")
            .refreshable {
                await viewModel.loadHistory()
            }
        }
        .task {
            await viewModel.loadHistory()
        }
    }
}

// HistoryItemRow.swift
struct HistoryItemRow: View {
    let cargo: CargoLabel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(cargo.awbNumber)
                    .font(.headline)
                Spacer()
                Text(cargo.timestamp.formatted(date: .abbreviated, time: .shortened))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            HStack {
                Image(systemName: "airplane")
                Text("\(cargo.origin) → \(cargo.destination)")
            }
            .font(.subheadline)
            
            HStack {
                VStack(alignment: .leading) {
                    Text(cargo.description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Text("\(cargo.pieces) pieces • \(cargo.weight)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                Spacer()
                CompletedBadge()
            }
            
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
        }
        .padding(.vertical, 4)
    }
}

// CompletedBadge.swift
struct CompletedBadge: View {
    var body: some View {
        Text("Completed")
            .font(.caption)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(Color.green)
            .foregroundColor(.white)
            .cornerRadius(4)
    }
}

// HistoryViewModel.swift
@MainActor
class HistoryViewModel: ObservableObject {
    @Published var historyItems: [CargoLabel] = []
    @Published var isLoading = false
    @Published var error: String?
    
    func loadHistory() async {
        isLoading = true
        error = nil
        
        do {
            let items = try await APIService.shared.fetchHistoryCargo()
            historyItems = items
        } catch {
            self.error = error.localizedDescription
        }
        
        isLoading = false
    }
}

// Add to APIService.swift
extension APIService {
    func fetchHistoryCargo() async throws -> [CargoLabel] {
        guard let url = URL(string: "\(baseURL)/cargo/history") else {
            logger.error("Invalid URL: \(self.baseURL)/cargo/history")
            throw APIError.invalidURL
        }
        
        logger.info("Fetching history from: \(url.absoluteString)")
        
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            
            if let httpResponse = response as? HTTPURLResponse {
                logger.info("Response status code: \(httpResponse.statusCode)")
            }
            
            if let jsonString = String(data: data, encoding: .utf8) {
                logger.info("Raw response: \(jsonString)")
            }
            
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .custom { decoder in
                let container = try decoder.singleValueContainer()
                let dateString = try container.decode(String.self)
                
                let formatter = DateFormatter()
                formatter.locale = Locale(identifier: "en_US_POSIX")
                formatter.timeZone = TimeZone(secondsFromGMT: 0)
                
                // Try different date formats
                let formats = [
                    "yyyy-MM-dd'T'HH:mm:ss.SSSZ",
                    "yyyy-MM-dd'T'HH:mm:ssZ"
                ]
                
                for format in formats {
                    formatter.dateFormat = format
                    if let date = formatter.date(from: dateString) {
                        return date
                    }
                }
                
                throw DecodingError.dataCorruptedError(
                    in: container,
                    debugDescription: "Cannot decode date string \(dateString)"
                )
            }
            
            return try decoder.decode([CargoLabel].self, from: data)
        } catch {
            logger.error("Error: \(error.localizedDescription)")
            throw APIError.decodingError(error.localizedDescription)
        }
    }
}
