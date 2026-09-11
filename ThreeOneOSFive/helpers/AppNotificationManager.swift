import Foundation
import SwiftUI

class AppNotificationManager: ObservableObject {
    static let shared = AppNotificationManager()
    
    @Published var showNotification = false
    @Published var notificationTitle = ""
    @Published var notificationMessage = ""
    
    private let apiUrl = "https://app-notification-server.ddnstore.workers.dev/api/get-notification"
    
    private var lastSeenTimestamp: Double {
        get { UserDefaults.standard.double(forKey: "lastSeenNotificationTimestamp") }
        set { UserDefaults.standard.set(newValue, forKey: "lastSeenNotificationTimestamp") }
    }
    
    func fetchNotification() {
        guard let url = URL(string: apiUrl) else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.timeoutInterval = 5
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print("Fetch notification error:", error?.localizedDescription ?? "")
                return
            }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    let title = json["title"] as? String ?? "Notification"
                    let message = json["message"] as? String ?? ""
                    let timestamp = json["timestamp"] as? Double ?? 0
                    
                    DispatchQueue.main.async {
                        // Only show if it's a new notification and not empty
                        if !message.isEmpty && timestamp > self.lastSeenTimestamp {
                            self.notificationTitle = title
                            self.notificationMessage = message
                            self.showNotification = true
                            self.lastSeenTimestamp = timestamp
                        }
                    }
                }
            } catch {
                print("JSON parse error")
            }
        }.resume()
    }
}
