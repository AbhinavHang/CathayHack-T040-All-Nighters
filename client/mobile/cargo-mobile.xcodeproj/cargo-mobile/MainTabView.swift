//
//  MainTabView.swift
//  cargo-mobile
//
//  Created by Аяжан on 6/11/2024.
//

import Foundation
import Foundation
import SwiftUI
import AVFoundation
import Foundation
import UIKit

struct MainTabView: View {
    @StateObject private var scannerViewModel = ScannerViewModel()
    
    var body: some View {
        TabView {
            ScannerTabView(viewModel: scannerViewModel)
                .tabItem {
                    Label("Scan", systemImage: "qrcode.viewfinder")
                }
            
            HistoryView(scannedLabels: scannerViewModel.scannedLabels)
                .tabItem {
                    Label("History", systemImage: "clock.fill")
                }
            
            AwaitingScansView()
                .tabItem {
                    Label("Awaiting", systemImage: "hourglass")
                }
            
            UserProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person.fill")
                }
        }
    }
}
