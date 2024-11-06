import Foundation

struct CargoLabel: Identifiable, Hashable {
    let id: String
    let awbNumber: String
    let destination: String
    let timestamp: Date
    let weight: String
    let pieces: Int
    let shipper: String
    let consignee: String
    let specialHandling: [String]
    let status: String // no need
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: CargoLabel, rhs: CargoLabel) -> Bool {
        return lhs.id == rhs.id
    }
    
    // Hardcoded cargo details based on QR code
    static func mockDataFor(qrCode: String) -> CargoLabel {
        // In real app, you would fetch this from an API/database
        let mockData: [String: CargoLabel] = [
            "AWB123": CargoLabel(
                id: "AWB123",
                awbNumber: "160-12345678",
                destination: "HKG",
                timestamp: Date(),
                weight: "245.5 KG",
                pieces: 3,
                shipper: "ABC Electronics Ltd",
                consignee: "XYZ Trading Co",
                specialHandling: ["PER", "VUN"],
                status: "In Transit"
            ),
            "AWB456": CargoLabel(
                id: "AWB456",
                awbNumber: "160-87654321",
                destination: "SIN",
                timestamp: Date(),
                weight: "1,240 KG",
                pieces: 8,
                shipper: "Global Tech Manufacturing",
                consignee: "Singapore Electronics",
                specialHandling: ["DGR", "CAO"],
                status: "Arrived"
            )
        ]
        
        return mockData[qrCode] ?? CargoLabel(
            id: qrCode,
            awbNumber: "Cathay Pacific",
            destination: "Hong Kong",
            timestamp: Date(),
            weight: "30KG",
            pieces: 0,
            shipper: "Cathay Pacifc",
            consignee: "John Lau",
            specialHandling: [],
            status: "Done"
        )
    }
}
