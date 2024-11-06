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
            VStack(alignment: .leading) {
                Text("AWB: \(label.awbNumber)")
                    .font(.headline)
                Text("Destination: \(label.destination)")
                    .font(.subheadline)
                Text("Scanned: \(label.timestamp, formatter: itemFormatter)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
    
    private let itemFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .medium
        return formatter
    }()
}
