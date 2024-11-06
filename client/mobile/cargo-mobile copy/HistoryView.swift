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

struct HistoryView: View {
    let scannedLabels: [CargoLabel]
    @State private var searchText = ""
    
    var filteredLabels: [CargoLabel] {
        if searchText.isEmpty {
            return scannedLabels
        }
        return scannedLabels.filter { label in
            label.awbNumber.localizedCaseInsensitiveContains(searchText) ||
            label.destination.localizedCaseInsensitiveContains(searchText) ||
            label.shipper.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                List {
                    ForEach(filteredLabels) { label in
                        CargoLabelRow(label: label)
                    }
                }
                .searchable(text: $searchText, prompt: "Search AWB, destination...")
            }
            .navigationTitle("Scan History")
        }
    }
}

