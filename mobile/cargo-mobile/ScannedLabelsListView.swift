//
//  ScannedLabelsListView.swift
//  cargo-mobile-2
//
//  Created by Аяжан on 6/11/2024.
//

import Foundation
//
//  ScannedLabelsListView.swift
//  cargo-mobile
//
//  Created by Аяжан on 6/11/2024.
//

import Foundation
import SwiftUI

struct ScannedLabelsListView: View {
    let labels: [CargoLabel]
    
    var body: some View {
        List(labels) { label in
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("AWB: \(label.awbNumber)")
                        .font(.headline)
                    Spacer()
                    Text(label.status)
                        .font(.subheadline)
                        .padding(4)
                        .background(statusColor(for: label.status))
                        .foregroundColor(.white)
                        .cornerRadius(4)
                }
                
                Text("Destination: \(label.destination)")
                    .font(.subheadline)
                
                HStack {
                    Text("Weight: \(label.weight)")
                    Spacer()
                    Text("Pieces: \(label.pieces)")
                }
                .font(.subheadline)
                .foregroundColor(.secondary)
                
                Divider()
                
                Text("Shipper: \(label.shipper)")
                    .font(.subheadline)
                Text("Consignee: \(label.consignee)")
                    .font(.subheadline)
                
                if !label.specialHandling.isEmpty {
                    HStack {
                        ForEach(label.specialHandling, id: \.self) { code in
                            Text(code)
                                .font(.caption)
                                .padding(4)
                                .background(Color.orange)
                                .foregroundColor(.white)
                                .cornerRadius(4)
                        }
                    }
                }
                
                Text("Scanned: \(label.timestamp, formatter: itemFormatter)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.vertical, 4)
        }
    }
    
    private func statusColor(for status: String) -> Color {
        switch status {
        case "In Transit":
            return .blue
        case "Arrived":
            return .green
        default:
            return .gray
        }
    }
    
    private let itemFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .medium
        return formatter
    }()
}
