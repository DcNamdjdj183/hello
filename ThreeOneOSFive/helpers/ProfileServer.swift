import Network
import Foundation
import SwiftUI

class ProfileServer: ObservableObject {
    static let shared = ProfileServer()
    private var listener: NWListener?
    private var fileData: Data?
    
    @Published var serverURL: URL?
    
    func startServer(with fileURL: URL) {
        self.fileData = try? Data(contentsOf: fileURL)
        if listener != nil { return }
        
        do {
            let parameters = NWParameters.tcp
            let port = NWEndpoint.Port(integerLiteral: 8080)
            listener = try NWListener(using: parameters, on: port)
            listener?.newConnectionHandler = { [weak self] connection in
                connection.start(queue: .main)
                connection.receive(minimumIncompleteLength: 1, maximumLength: 1024) { data, _, _, _ in
                    guard let self = self, let fd = self.fileData else {
                        connection.cancel()
                        return
                    }
                    let header = "HTTP/1.1 200 OK\r\nContent-Type: application/x-apple-aspen-config\r\nContent-Length: \(fd.count)\r\nConnection: close\r\n\r\n"
                    let resp = header.data(using: .utf8)! + fd
                    connection.send(content: resp, completion: .contentProcessed({ _ in
                        connection.cancel()
                    }))
                }
            }
            listener?.start(queue: .main)
            self.serverURL = URL(string: "http://127.0.0.1:8080/profile.mobileconfig")
        } catch {
            print("Failed to start server: \\(error)")
        }
    }
}
