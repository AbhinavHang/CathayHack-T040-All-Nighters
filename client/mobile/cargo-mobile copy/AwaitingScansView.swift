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
    @State private var searchText = ""
    
    // Hardcoded awaiting scans data
    let awaitingScans = [
        AwaitingScan(
            id: "AWB789",
            awbNumber: "160-98765432",
            deadline: Date().addingTimeInterval(3600), // 1 hour
            origin: "HKG",
            destination: "PVG",
            specialHandling: ["DGR"],
            pieces: 5,
            weight: "750 KG",
            description: "Medical Supplies"
        ),
        AwaitingScan(
            id: "AWB101",
            awbNumber: "160-45678912",
            deadline: Date().addingTimeInterval(7200), // 2 hours
            origin: "PVG",
            destination: "NRT",
            specialHandling: ["PER"],
            pieces: 2,
            weight: "320 KG",
            description: "Perishable Food"
        ),
        AwaitingScan(
            id: "AWB202",
            awbNumber: "160-36925814",
            deadline: Date().addingTimeInterval(14400), // 4 hours
            origin: "ICN",
            destination: "SIN",
            specialHandling: [],
            pieces: 10,
            weight: "1200 KG",
            description: "Auto Parts"
        )
    ]
    
    var sortedAndFilteredScans: [AwaitingScan] {
        let filtered = searchText.isEmpty ? awaitingScans : awaitingScans.filter { scan in
            scan.awbNumber.localizedCaseInsensitiveContains(searchText) ||
            scan.destination.localizedCaseInsensitiveContains(searchText) ||
            scan.description.localizedCaseInsensitiveContains(searchText)
        }
        return filtered.sorted { $0.deadline < $1.deadline }
    }
    
    var body: some View {
        NavigationView {
            List(sortedAndFilteredScans) { scan in
                AwaitingScanRow(scan: scan)
            }
            .searchable(text: $searchText, prompt: "Search AWB, destination...")
            .navigationTitle("Awaiting Scans")
        }
    }
}
