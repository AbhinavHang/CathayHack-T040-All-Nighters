import Foundation

// Update CargoLabel model to handle the MongoDB format
struct CargoLabel: Identifiable, Codable, Hashable {
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
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case awbNumber, origin, destination, timestamp, weight
        case pieces, shipper, consignee, specialHandling, status
        case description, deadline
        case v = "__v"
    }
    
    // Custom decoder
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(String.self, forKey: .id)
        awbNumber = try container.decode(String.self, forKey: .awbNumber)
        origin = try container.decode(String.self, forKey: .origin)
        destination = try container.decode(String.self, forKey: .destination)
        timestamp = try container.decode(Date.self, forKey: .timestamp)
        weight = try container.decode(String.self, forKey: .weight)
        pieces = try container.decode(Int.self, forKey: .pieces)
        shipper = try container.decode(String.self, forKey: .shipper)
        consignee = try container.decode(String.self, forKey: .consignee)
        specialHandling = try container.decode([String].self, forKey: .specialHandling)
        status = try container.decode(String.self, forKey: .status)
        description = try container.decode(String.self, forKey: .description)
        deadline = try container.decodeIfPresent(Date.self, forKey: .deadline)
    }
    
    // Custom encoder
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(id, forKey: .id)
        try container.encode(awbNumber, forKey: .awbNumber)
        try container.encode(origin, forKey: .origin)
        try container.encode(destination, forKey: .destination)
        try container.encode(timestamp, forKey: .timestamp)
        try container.encode(weight, forKey: .weight)
        try container.encode(pieces, forKey: .pieces)
        try container.encode(shipper, forKey: .shipper)
        try container.encode(consignee, forKey: .consignee)
        try container.encode(specialHandling, forKey: .specialHandling)
        try container.encode(status, forKey: .status)
        try container.encode(description, forKey: .description)
        try container.encode(deadline, forKey: .deadline)
    }
    
    // Manual initializer for creating instances
    init(id: String,
         awbNumber: String,
         origin: String,
         destination: String,
         timestamp: Date,
         weight: String,
         pieces: Int,
         shipper: String,
         consignee: String,
         specialHandling: [String],
         status: String,
         description: String,
         deadline: Date?) {
        self.id = id
        self.awbNumber = awbNumber
        self.origin = origin
        self.destination = destination
        self.timestamp = timestamp
        self.weight = weight
        self.pieces = pieces
        self.shipper = shipper
        self.consignee = consignee
        self.specialHandling = specialHandling
        self.status = status
        self.description = description
        self.deadline = deadline
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: CargoLabel, rhs: CargoLabel) -> Bool {
        return lhs.id == rhs.id
    }
}

// Example extension for creating mock data
extension CargoLabel {
    static func mockData() -> [CargoLabel] {
        return [
            CargoLabel(
                id: "AWB789",
                awbNumber: "160-98765432",
                origin: "HKG",
                destination: "PVG",
                timestamp: Date(),
                weight: "750 KG",
                pieces: 5,
                shipper: "Medical Corp",
                consignee: "Shanghai Hospital",
                specialHandling: ["DGR"],
                status: "Awaiting",
                description: "Medical Supplies",
                deadline: Date().addingTimeInterval(3600)
            ),
            CargoLabel(
                id: "AWB101",
                awbNumber: "160-45678912",
                origin: "PVG",
                destination: "NRT",
                timestamp: Date(),
                weight: "320 KG",
                pieces: 2,
                shipper: "Fresh Foods Co",
                consignee: "Tokyo Markets Ltd",
                specialHandling: ["PER"],
                status: "Awaiting",
                description: "Perishable Food",
                deadline: Date().addingTimeInterval(7200)
            )
        ]
    }
    
    // Helper method to create a single mock item
    static func mockItem(withId id: String) -> CargoLabel {
        CargoLabel(
            id: id,
            awbNumber: "160-\(Int.random(in: 10000000...99999999))",
            origin: "HKG",
            destination: "LAX",
            timestamp: Date(),
            weight: "\(Int.random(in: 100...1000)) KG",
            pieces: Int.random(in: 1...10),
            shipper: "Test Shipper",
            consignee: "Test Consignee",
            specialHandling: ["TEST"],
            status: "Awaiting",
            description: "Test Cargo",
            deadline: Date().addingTimeInterval(3600)
        )
    }
}

// APIResponse wrapper for handling MongoDB responses
struct MongoDBResponse: Codable {
    let data: [CargoLabel]
    
    enum CodingKeys: String, CodingKey {
        case data = "0"
    }
}
