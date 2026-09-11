import Foundation
import SwiftUI

class AppNotificationManager: ObservableObject {
    static let shared = AppNotificationManager()
    
    @Published var showNotification = false
    @Published var notificationTitle = ""
    @Published var notificationMessage = ""
    
    private let apiUrl = "https://app-notification-server.ddnstore.workers.dev/api/get-notification"
    
    func fetchNotification() {
        // Delay fetching to prevent interrupting kernel exploits on app launch
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) { [weak self] in
            guard let self = self else { return }
            guard let url = URL(string: self.apiUrl) else { return }
            
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
                        
                        DispatchQueue.main.async {
                            // Show every time the app opens if not empty
                            if !message.isEmpty {
                                self.notificationTitle = title
                                self.notificationMessage = message
                                self.showNotification = true
                            }
                        }
                    }
                } catch {
                    print("JSON parse error")
                }
            }.resume()
        }
    }
}
