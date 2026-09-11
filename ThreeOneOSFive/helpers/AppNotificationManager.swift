import Foundation
import SwiftUI

class AppNotificationManager: ObservableObject {
    static let shared = AppNotificationManager()
    
    @Published var showNotification = false
    @Published var notificationTitle = ""
    @Published var notificationMessage = ""
    
    // ĐỔI LINK NÀY THÀNH LINK CLOUDFLARE WORKER CỦA BẠN
    private let apiUrl = "https://app-notification-server.ddnstore.workers.dev/api/get-notification"
    
    // Lưu lại thời gian của thông báo mới nhất đã xem để không hiện lại nếu không có thông báo mới
    // Nếu bạn muốn LÚC NÀO thoát ra vào lại cũng hiện, thì tắt dòng check timestamp đi.
    // Theo yêu cầu "mỗi khi thoát ra vào lại app sẽ hiện thông báo", ta sẽ luôn hiện nếu message != ""
    @AppStorage("lastSeenNotificationTimestamp") private var lastSeenTimestamp: Double = 0
    
    func fetchNotification() {
        guard let url = URL(string: apiUrl) else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.timeoutInterval = 5
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print("Lỗi fetch thông báo:", error?.localizedDescription ?? "")
                return
            }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    let title = json["title"] as? String ?? "Thông Báo"
                    let message = json["message"] as? String ?? ""
                    let timestamp = json["timestamp"] as? Double ?? 0
                    
                    DispatchQueue.main.async {
                        // Hiện thông báo nếu có nội dung
                        // (Bạn có thể check `timestamp > self.lastSeenTimestamp` nếu chỉ muốn hiện 1 lần cho mỗi thông báo mới)
                        if !message.isEmpty {
                            self.notificationTitle = title
                            self.notificationMessage = message
                            self.showNotification = true
                            self.lastSeenTimestamp = timestamp
                        }
                    }
                }
            } catch {
                print("Lỗi parse JSON thông báo")
            }
        }.resume()
    }
}
