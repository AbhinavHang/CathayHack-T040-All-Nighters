//
//  CargoDetailView.swift
//  cargo-mobile
//
//  Created by Аяжан on 6/11/2024.
//

import Foundation
import SwiftUI
import AVFoundation
import Foundation
import UIKit

struct CargoDetailView: View {
    let cargo: CargoLabel
    
    var body: some View {
        List {
            Section("Airway Bill Information") {
                DetailRow(title: "AWB Number", value: cargo.awbNumber)
                DetailRow(title: "Origin", value: cargo.origin)
                DetailRow(title: "Destination", value: cargo.destination)
                if let deadline = cargo.deadline {
                    DetailRow(title: "Load Until", value: deadline.formatted(date: .abbreviated, time: .shortened))
                }
            }
            
            Section("Cargo Details") {
                DetailRow(title: "Description", value: cargo.description)
                DetailRow(title: "Pieces", value: "\(cargo.pieces)")
                DetailRow(title: "Weight", value: cargo.weight)
            }
            
            Section("Parties") {
                DetailRow(title: "Shipper", value: cargo.shipper)
                DetailRow(title: "Consignee", value: cargo.consignee)
            }
            
            if !cargo.specialHandling.isEmpty {
                Section("Special Handling") {
                    ForEach(cargo.specialHandling, id: \.self) { code in
                        Text(code)
                            .font(.subheadline)
                            .padding(4)
                            .background(Color.orange)
                            .foregroundColor(.white)
                            .cornerRadius(4)
                    }
                }
            }
            
            Section("Status") {
                HStack {
                    Text(cargo.status)
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(statusColor(for: cargo.status))
                        .cornerRadius(8)
                    
                    Spacer()
                    
                    Text("Last Updated: \(cargo.timestamp.formatted())")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .navigationTitle("Cargo Details")
    }
    
    private func statusColor(for status: String) -> Color {
        switch status {
        case "In Transit": return .blue
        case "Arrived": return .green
        default: return .gray
        }
    }
}
