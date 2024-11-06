import Foundation

struct CargoLabel: Identifiable, Hashable {
    let id: String
    let awbNumber: String
    let origin: String
    let destination: String
    let timestamp: Date
    let weight: String
    let pieces: Int
    let shipper: String
    let consignee: String
    let specialHandling: [String]
    let status: String
    let description: String
    let deadline: Date?
    
    static func mockDataFor(qrCode: String) -> CargoLabel {
        let mockData: [String: CargoLabel] = [
            "AWB123": CargoLabel(
                id: "AWB123",
                awbNumber: "160-12345678",
                origin: "HKG",
                destination: "LAX",
                timestamp: Date(),
                weight: "245.5 KG",
                pieces: 3,
                shipper: "ABC Electronics Ltd",
                consignee: "XYZ Trading Co",
                specialHandling: ["PER", "VUN"],
                status: "In Transit",
                description: "Electronic Components",
                deadline: Date().addingTimeInterval(3600) // 1 hour from now
            ),
            "AWB456": CargoLabel(
                id: "AWB456",
                awbNumber: "160-87654321",
                origin: "PVG",
                destination: "SIN",
                timestamp: Date(),
                weight: "1,240 KG",
                pieces: 8,
                shipper: "Global Tech Manufacturing",
                consignee: "Singapore Electronics",
                specialHandling: ["DGR", "CAO"],
                status: "Arrived",
                description: "Industrial Equipment",
                deadline: Date().addingTimeInterval(7200) // 2 hours from now
            )
        ]
        
        return mockData[qrCode] ?? CargoLabel(
            id: qrCode,
            awbNumber: "Unknown",
            origin: "Unknown",
            destination: "Unknown",
            timestamp: Date(),
            weight: "N/A",
            pieces: 0,
            shipper: "Unknown",
            consignee: "Unknown",
            specialHandling: [],
            status: "Not Found",
            description: "Unknown",
            deadline: nil
        )
    }
}
