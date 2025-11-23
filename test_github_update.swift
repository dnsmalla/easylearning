import Foundation

// Test the GitHub update URLs
let urls = [
    "https://raw.githubusercontent.com/dnsmalla/easylearning/main/jpleanrning/manifest.json",
    "https://raw.githubusercontent.com/dnsmalla/easylearning/main/jpleanrning/japanese_learning_data_n5_jisho.json"
]

for urlString in urls {
    guard let url = URL(string: urlString) else { continue }
    
    let task = URLSession.shared.dataTask(with: url) { data, response, error in
        if let error = error {
            print("❌ \(urlString): \(error.localizedDescription)")
            return
        }
        
        if let httpResponse = response as? HTTPURLResponse {
            print("✅ \(urlString): HTTP \(httpResponse.statusCode)")
            if let data = data {
                print("   Size: \(data.count) bytes")
            }
        }
    }
    task.resume()
}

// Keep alive
RunLoop.main.run(until: Date(timeIntervalSinceNow: 5))
