import Foundation
import SwiftUI
import AVFoundation
import OSLog

class APIService: ObservableObject {
    static let shared = APIService()
    let baseURL = "https://test-td2g.vercel.app/api"
    let logger = Logger(subsystem: "com.cargo-mobile", category: "API")
    
    func fetchAwaitingCargo() async throws -> [CargoLabel] {
        guard let url = URL(string: "\(baseURL)/cargo/awaiting") else {
            logger.error("Invalid URL: \(self.baseURL)/cargo/awaiting")
            throw APIError.invalidURL
        }
        
        logger.info("Fetching data from: \(url.absoluteString)")
        
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            
            // Log response and data
            if let httpResponse = response as? HTTPURLResponse {
                logger.info("Response status code: \(httpResponse.statusCode)")
            }
            
            if let jsonString = String(data: data, encoding: .utf8) {
                logger.info("Raw response: \(jsonString)")
            }
            
            // Decode the response
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .custom { decoder in
                let container = try decoder.singleValueContainer()
                let dateString = try container.decode(String.self)
                
                // Try multiple date formats
                let formats = [
                    "yyyy-MM-dd'T'HH:mm:ss.SSSZ",
                    "yyyy-MM-dd'T'HH:mm:ssZ"
                ]
                
                let formatter = DateFormatter()
                formatter.locale = Locale(identifier: "en_US_POSIX")
                formatter.timeZone = TimeZone(secondsFromGMT: 0)
                
                for format in formats {
                    formatter.dateFormat = format
                    if let date = formatter.date(from: dateString) {
                        return date
                    }
                }
                
                throw DecodingError.dataCorruptedError(
                    in: container,
                    debugDescription: "Cannot decode date string \(dateString)"
                )
            }
            
            let cargoLabels = try decoder.decode([CargoLabel].self, from: data)
            return cargoLabels
            
        } catch {
            logger.error("Error: \(error.localizedDescription)")
            throw APIError.decodingError(error.localizedDescription)
        }
    }
}

enum APIError: LocalizedError {
    case invalidURL
    case invalidResponse
    case notFound
    case serverError(String)
    case decodingError(String)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .invalidResponse:
            return "Invalid response from server"
        case .notFound:
            return "Cargo not found"
        case .serverError(let message):
            return "Server error: \(message)"
        case .decodingError(let message):
            return "Decoding error: \(message)"
        }
    }
}

struct ErrorResponse: Codable {
    let message: String
}


extension APIService {
    func fetchCargoByAWB(_ awbNumber: String) async throws -> CargoLabel {
        guard let url = URL(string: "\(baseURL)/cargo/awb/\(awbNumber)") else {
            throw APIError.invalidURL
        }
        
        logger.info("Fetching cargo details for AWB: \(awbNumber)")
        
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            
            if let httpResponse = response as? HTTPURLResponse {
                logger.info("Response status code: \(httpResponse.statusCode)")
                
                if httpResponse.statusCode == 404 {
                    throw APIError.notFound
                }
            }
            
            if let jsonString = String(data: data, encoding: .utf8) {
                logger.info("Raw response: \(jsonString)")
            }
            
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .custom { decoder in
                let container = try decoder.singleValueContainer()
                let dateString = try container.decode(String.self)
                
                let formatter = DateFormatter()
                formatter.locale = Locale(identifier: "en_US_POSIX")
                formatter.timeZone = TimeZone(secondsFromGMT: 0)
                
                let formats = [
                    "yyyy-MM-dd'T'HH:mm:ss.SSSZ",
                    "yyyy-MM-dd'T'HH:mm:ssZ"
                ]
                
                for format in formats {
                    formatter.dateFormat = format
                    if let date = formatter.date(from: dateString) {
                        return date
                    }
                }
                
                throw DecodingError.dataCorruptedError(
                    in: container,
                    debugDescription: "Cannot decode date string \(dateString)"
                )
            }
            
            return try decoder.decode(CargoLabel.self, from: data)
        } catch {
            logger.error("Error fetching cargo: \(error.localizedDescription)")
            throw error
        }
    }
}
