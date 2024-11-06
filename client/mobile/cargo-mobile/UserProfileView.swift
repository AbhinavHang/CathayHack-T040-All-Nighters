//
//  UserProfileView.swift
//  cargo-mobile
//
//  Created by Аяжан on 6/11/2024.
//

import Foundation
import SwiftUI
import AVFoundation
import Foundation
import UIKit

struct UserProfileView: View {
    // Hardcoded user data
    let userData = UserProfile(
        id: "EMP123",
        name: "John Smith",
        role: "Cargo Handler",
        station: "HKG",
        shift: "Morning (06:00-14:00)",
        performanceMetrics: PerformanceMetrics(
            scansToday: 45,
            accuracy: 98.5,
            averageTimePerScan: 12.3
        ),
        recentActivity: [
            "Completed DGR training - 2024/03/15",
            "Safety certification renewed - 2024/02/28",
            "Employee of the month - January 2024"
        ]
    )
    
    var body: some View {
        NavigationView {
            List {
                Section("Personal Information") {
                    InfoRow(title: "ID", value: userData.id)
                    InfoRow(title: "Name", value: userData.name)
                    InfoRow(title: "Role", value: userData.role)
                    InfoRow(title: "Station", value: userData.station)
                    InfoRow(title: "Shift", value: userData.shift)
                }
                
                Section("Today's Performance") {
                    InfoRow(title: "Scans", value: "\(userData.performanceMetrics.scansToday)")
                    InfoRow(title: "Accuracy", value: "\(userData.performanceMetrics.accuracy)%")
                    InfoRow(title: "Avg. Time/Scan", value: "\(userData.performanceMetrics.averageTimePerScan)s")
                }
                
                Section("Recent Activity") {
                    ForEach(userData.recentActivity, id: \.self) { activity in
                        Text(activity)
                            .font(.subheadline)
                    }
                }
            }
            .navigationTitle("User Profile")
        }
    }
}


struct CargoLabelRow: View {
    let label: CargoLabel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(label.awbNumber)
                    .font(.headline)
                Spacer()
                Text(label.status)
                    .font(.subheadline)
                    .padding(4)
                    .background(statusColor(for: label.status))
                    .foregroundColor(.white)
                    .cornerRadius(4)
            }
            
            Text("To: \(label.destination)")
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
            
            Text("Scanned: \(label.timestamp.formatted())")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
    }
    
    private func statusColor(for status: String) -> Color {
        switch status {
        case "In Transit": return .blue
        case "Arrived": return .green
        default: return .gray
        }
    }
}

struct AwaitingScanRow: View {
    let scan: AwaitingScan
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(scan.awbNumber)
                    .font(.headline)
                Spacer()
                PriorityBadge(priority: scan.priority)
            }
            
            Text("To: \(scan.destination)")
                .font(.subheadline)
            
            if !scan.specialHandling.isEmpty {
                HStack {
                    ForEach(scan.specialHandling, id: \.self) { code in
                        Text(code)
                            .font(.caption)
                            .padding(4)
                            .background(Color.orange)
                            .foregroundColor(.white)
                            .cornerRadius(4)
                    }
                }
            }
            
            HStack {
                Image(systemName: "clock")
                Text("Deadline: \(scan.deadline.formatted(date: .omitted, time: .shortened))")
            }
            .font(.caption)
            .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
    }
}

struct PriorityBadge: View {
    let priority: String
    
    var body: some View {
        Text(priority)
            .font(.caption)
            .padding(4)
            .background(priorityColor)
            .foregroundColor(.white)
            .cornerRadius(4)
    }
    
    private var priorityColor: Color {
        switch priority {
        case "High": return .red
        case "Medium": return .orange
        default: return .blue
        }
    }
}

struct InfoRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .bold()
        }
    }
}

// Additional Models
struct AwaitingScan: Identifiable {
    let id: String
    let awbNumber: String
    let priority: String
    let deadline: Date
    let destination: String
    let specialHandling: [String]
}

struct UserProfile {
    let id: String
    let name: String
    let role: String
    let station: String
    let shift: String
    let performanceMetrics: PerformanceMetrics
    let recentActivity: [String]
}

struct PerformanceMetrics {
    let scansToday: Int
    let accuracy: Double
    let averageTimePerScan: Double
}
