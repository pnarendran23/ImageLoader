//
//  NetworkMonitor.swift
//  ImageLoader
//
//  Created by PradheepNarendran on 18/04/24.
//

import Network
import UIKit

extension Notification.Name {
    static let networkNotification = Notification.Name("networkNotification")
}

class NetworkMonitor {
    static let shared = NetworkMonitor()

    private let monitor = NWPathMonitor()
    private var isMonitoring = false

    var isConnected: Bool {
      return monitor.currentPath.status == .satisfied
    }

    private init() {}

    func startMonitoring() {
        guard !isMonitoring else { return }

        monitor.pathUpdateHandler = { [weak self] path in
            self?.handleNetworkChange(path)
        }

        let queue = DispatchQueue(label: "NetworkMonitor")
        monitor.start(queue: queue)
        isMonitoring = true
    }

    func stopMonitoring() {
        guard isMonitoring else { return }

        monitor.cancel()
        isMonitoring = false
    }

    private func handleNetworkChange(_ path: NWPath) {
      let userInfo: [AnyHashable: Any] = ["status": path.status == .satisfied]
      NotificationCenter.default.post(name: .networkNotification, object: nil, userInfo: userInfo)
    }
}
