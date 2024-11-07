// SimpleAPITest.swift
import SwiftUI

struct TestView: View {
    @State private var response = "No data yet"
    @State private var isLoading = false
    
    var body: some View {
        VStack(spacing: 20) {
            Text("API Test")
                .font(.title)
            
            if isLoading {
                ProgressView()
                    .scaleEffect(1.5)
            }
            
            Text(response)
                .padding()
                .background(Color.secondary.opacity(0.1))
                .cornerRadius(8)
            
            Button("Test Connection") {
                testAPI()
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
    
    private func testAPI() {
        isLoading = true
        self.response = "Testing..."
        
        guard let url = URL(string: "http://localhost:3000/data") else {
            self.response = "Invalid URL"
            isLoading = false
            return
        }
        
        URLSession.shared.dataTask(with: url) { responseData, urlResponse, error in
            DispatchQueue.main.async {
                self.isLoading = false
                
                if let error = error {
                    self.response = "Error: \(error.localizedDescription)"
                    return
                }
                
                guard let httpResponse = urlResponse as? HTTPURLResponse else {
                    self.response = "Invalid response type"
                    return
                }
                
                print("Status Code: \(httpResponse.statusCode)")
                
                guard let data = responseData,
                      let stringResponse = String(data: data, encoding: .utf8) else {
                    self.response = "No data received"
                    return
                }
                
                self.response = stringResponse
            }
        }.resume()
    }
}
