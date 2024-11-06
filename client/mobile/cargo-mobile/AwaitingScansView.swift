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
    // Hardcoded awaiting scans data
    let awaitingScans = [
        AwaitingScan(
            id: "AWB789",
            awbNumber: "160-98765432",
            priority: "High",
            deadline: Date().addingTimeInterval(3600), // 1 hour from now
            destination: "PVG",
            specialHandling: ["DGR"]
        ),
        AwaitingScan(
            id: "AWB101",
            awbNumber: "160-45678912",
            priority: "Medium",
            deadline: Date().addingTimeInterval(7200), // 2 hours from now
            destination: "NRT",
            specialHandling: ["PER"]
        ),
        AwaitingScan(
            id: "AWB202",
            awbNumber: "160-36925814",
            priority: "Low",
            deadline: Date().addingTimeInterval(14400), // 4 hours from now
            destination: "ICN",
            specialHandling: []
        )
    ]
    
    var body: some View {
        NavigationView {
            List(awaitingScans) { scan in
                AwaitingScanRow(scan: scan)
            }
            .navigationTitle("Awaiting Scans")
        }
    }
}
