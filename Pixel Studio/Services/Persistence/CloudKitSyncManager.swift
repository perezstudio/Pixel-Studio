import Foundation
import CloudKit
import SwiftData
import Combine

/// Monitors CloudKit sync status and provides UI feedback.
@Observable
final class CloudKitSyncManager {

    // MARK: - State

    enum SyncStatus: Equatable {
        case idle
        case syncing
        case succeeded
        case failed(String)
        case accountUnavailable

        var displayName: String {
            switch self {
            case .idle:                return "Idle"
            case .syncing:             return "Syncing..."
            case .succeeded:           return "Up to date"
            case .failed(let msg):     return "Error: \(msg)"
            case .accountUnavailable:  return "iCloud unavailable"
            }
        }

        var systemImage: String {
            switch self {
            case .idle:                return "cloud"
            case .syncing:             return "arrow.triangle.2.circlepath.icloud"
            case .succeeded:           return "checkmark.icloud"
            case .failed:              return "exclamationmark.icloud"
            case .accountUnavailable:  return "icloud.slash"
            }
        }
    }

    var syncStatus: SyncStatus = .idle
    var lastSyncDate: Date?

    private let container: CKContainer
    private var eventSubscription: AnyCancellable?

    // MARK: - Init

    init(containerIdentifier: String = "iCloud.com.perezstudio.Pixel-Studio") {
        self.container = CKContainer(identifier: containerIdentifier)
        checkAccountStatus()
        startMonitoring()
    }

    // MARK: - Account

    func checkAccountStatus() {
        container.accountStatus { [weak self] status, error in
            DispatchQueue.main.async {
                guard let self else { return }
                if let error {
                    self.syncStatus = .failed(error.localizedDescription)
                    return
                }
                switch status {
                case .available:
                    self.syncStatus = .idle
                case .noAccount, .restricted, .temporarilyUnavailable:
                    self.syncStatus = .accountUnavailable
                case .couldNotDetermine:
                    self.syncStatus = .idle
                @unknown default:
                    self.syncStatus = .idle
                }
            }
        }
    }

    // MARK: - Monitoring

    private func startMonitoring() {
        // Monitor account changes
        NotificationCenter.default.addObserver(
            forName: .CKAccountChanged,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.checkAccountStatus()
        }

        // Monitor NSPersistentCloudKitContainer events if available
        eventSubscription = NotificationCenter.default.publisher(
            for: NSNotification.Name("NSPersistentCloudKitContainer.eventChangedNotification")
        )
        .receive(on: DispatchQueue.main)
        .sink { [weak self] notification in
            self?.handleCloudKitEvent(notification)
        }
    }

    private func handleCloudKitEvent(_ notification: Notification) {
        // NSPersistentCloudKitContainer.Event has type and endDate properties
        guard let event = notification.userInfo?["event"] as? NSObject else { return }

        let endDate = event.value(forKey: "endDate") as? Date
        let succeeded = event.value(forKey: "succeeded") as? Bool ?? false
        let error = event.value(forKey: "error") as? NSError

        if endDate == nil {
            // Event in progress
            syncStatus = .syncing
        } else if let error {
            syncStatus = .failed(error.localizedDescription)
        } else if succeeded {
            syncStatus = .succeeded
            lastSyncDate = Date()
        } else {
            syncStatus = .idle
        }
    }

    // MARK: - Manual Refresh

    func refreshSync() {
        syncStatus = .syncing
        checkAccountStatus()
    }
}
