import Foundation
import CoreData
import SwiftUI

// MARK: - Core Data Errors

enum CoreDataError: LocalizedError {
    case persistentStoreLoadFailed(underlying: Error)
    case saveContextFailed(underlying: Error)
    case fetchRequestFailed(underlying: Error)
    case migrationFailed(underlying: Error)
    case modelNotFound
    case contextNotAvailable
    
    var errorDescription: String? {
        switch self {
        case .persistentStoreLoadFailed(let error):
            return "Failed to load persistent store: \(error.localizedDescription)"
        case .saveContextFailed(let error):
            return "Failed to save data: \(error.localizedDescription)"
        case .fetchRequestFailed(let error):
            return "Failed to fetch data: \(error.localizedDescription)"
        case .migrationFailed(let error):
            return "Failed to migrate data: \(error.localizedDescription)"
        case .modelNotFound:
            return "Core Data model not found"
        case .contextNotAvailable:
            return "Core Data context not available"
        }
    }
    
    var recoverySuggestion: String? {
        switch self {
        case .persistentStoreLoadFailed, .migrationFailed:
            return "Try restarting the app. If the problem persists, contact support."
        case .saveContextFailed:
            return "Your progress may not be saved. Please try again."
        case .fetchRequestFailed:
            return "Unable to load your progress. Please try again."
        case .modelNotFound, .contextNotAvailable:
            return "A technical error occurred. Please restart the app."
        }
    }
}

// MARK: - Core Data Manager

class CoreDataManager: ObservableObject {
    static let shared = CoreDataManager()
    
    @Published var isLoading = false
    @Published var lastError: CoreDataError?
    @Published var connectionStatus: ConnectionStatus = .unknown
    
    enum ConnectionStatus {
        case unknown
        case connected
        case disconnected
        case error(CoreDataError)
        
        var isHealthy: Bool {
            switch self {
            case .connected: return true
            default: return false
            }
        }
    }
    
    // MARK: - Core Data Stack
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "HOLDDataModel")
        
        // Configure store description for better error handling
        if let storeDescription = container.persistentStoreDescriptions.first {
            storeDescription.shouldInferMappingModelAutomatically = true
            storeDescription.shouldMigrateStoreAutomatically = true
            storeDescription.setOption(FileProtectionType.complete as NSObject, forKey: NSPersistentHistoryTrackingKey)
        }
        
        container.loadPersistentStores { [weak self] _, error in
            DispatchQueue.main.async {
                if let error = error {
                    let coreDataError = CoreDataError.persistentStoreLoadFailed(underlying: error)
                    self?.handleError(coreDataError)
                    self?.connectionStatus = .error(coreDataError)
                } else {
                    self?.connectionStatus = .connected
                    print("✅ Core Data loaded successfully")
                }
            }
        }
        
        // Enable automatic merging
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        
        return container
    }()
    
    var viewContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    var backgroundContext: NSManagedObjectContext {
        return persistentContainer.newBackgroundContext()
    }
    
    private init() {
        setupNotifications()
    }
    
    // MARK: - Error Handling
    
    private func handleError(_ error: CoreDataError) {
        DispatchQueue.main.async {
            self.lastError = error
            print("❌ Core Data Error: \(error.localizedDescription)")
            
            // Log error for debugging
            #if DEBUG
            print("🔍 Error details: \(error)")
            #endif
        }
    }
    
    func clearLastError() {
        lastError = nil
    }
    
    // MARK: - Context Management
    
    func save(context: NSManagedObjectContext? = nil) -> Result<Void, CoreDataError> {
        let targetContext = context ?? viewContext
        
        guard targetContext.hasChanges else {
            return .success(())
        }
        
        do {
            try targetContext.save()
            print("✅ Core Data saved successfully")
            return .success(())
        } catch {
            let coreDataError = CoreDataError.saveContextFailed(underlying: error)
            handleError(coreDataError)
            return .failure(coreDataError)
        }
    }
    
    func performBackgroundTask<T>(_ task: @escaping (NSManagedObjectContext) throws -> T) async -> Result<T, CoreDataError> {
        return await withCheckedContinuation { continuation in
            let context = backgroundContext
            
            context.perform {
                do {
                    let result = try task(context)
                    continuation.resume(returning: .success(result))
                } catch {
                    let coreDataError: CoreDataError
                    if let cdError = error as? CoreDataError {
                        coreDataError = cdError
                    } else {
                        coreDataError = CoreDataError.saveContextFailed(underlying: error)
                    }
                    continuation.resume(returning: .failure(coreDataError))
                }
            }
        }
    }
    
    // MARK: - Session Operations
    
    func saveSession(_ sessionData: SessionData) async -> Result<Void, CoreDataError> {
        return await performBackgroundTask { context in
            let session = Session(context: context)
            session.id = sessionData.id
            session.startedAt = sessionData.startedAt
            session.completedAt = sessionData.completedAt
            session.holdDuration = sessionData.holdDuration
            session.preparationRounds = Int16(sessionData.preparationRounds)
            session.protocolType = sessionData.protocolType
            
            if context.hasChanges {
                try context.save()
            }
        }
    }
    
    func fetchSessions() async -> Result<[SessionData], CoreDataError> {
        return await performBackgroundTask { context in
            let request: NSFetchRequest<Session> = Session.fetchRequest()
            request.sortDescriptors = [NSSortDescriptor(keyPath: \Session.startedAt, ascending: false)]
            
            do {
                let sessions = try context.fetch(request)
                return sessions.compactMap { session in
                    guard let id = session.id,
                          let startedAt = session.startedAt else {
                        return nil
                    }
                    
                    return SessionData(
                        id: id,
                        startedAt: startedAt,
                        completedAt: session.completedAt,
                        holdDuration: session.holdDuration,
                        preparationRounds: Int(session.preparationRounds),
                        protocolType: session.protocolType ?? "Box Breathing"
                    )
                }
            } catch {
                throw CoreDataError.fetchRequestFailed(underlying: error)
            }
        }
    }
    
    func deleteSession(withId id: UUID) async -> Result<Void, CoreDataError> {
        return await performBackgroundTask { context in
            let request: NSFetchRequest<Session> = Session.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
            request.fetchLimit = 1
            
            do {
                let sessions = try context.fetch(request)
                if let session = sessions.first {
                    context.delete(session)
                    if context.hasChanges {
                        try context.save()
                    }
                }
            } catch {
                throw CoreDataError.fetchRequestFailed(underlying: error)
            }
        }
    }
    
    func deleteAllSessions() async -> Result<Void, CoreDataError> {
        return await performBackgroundTask { context in
            let request: NSFetchRequest<NSFetchRequestResult> = Session.fetchRequest()
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: request)
            
            do {
                try context.execute(deleteRequest)
                try context.save()
            } catch {
                throw CoreDataError.saveContextFailed(underlying: error)
            }
        }
    }
    
    // MARK: - Health Check
    
    func performHealthCheck() async -> Bool {
        do {
            let testResult = await fetchSessions()
            switch testResult {
            case .success:
                DispatchQueue.main.async {
                    self.connectionStatus = .connected
                }
                return true
            case .failure(let error):
                DispatchQueue.main.async {
                    self.connectionStatus = .error(error)
                }
                return false
            }
        }
    }
    
    // MARK: - Notifications
    
    private func setupNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(contextDidSave),
            name: .NSManagedObjectContextDidSave,
            object: nil
        )
    }
    
    @objc private func contextDidSave(notification: Notification) {
        guard let context = notification.object as? NSManagedObjectContext,
              context !== viewContext else { return }
        
        DispatchQueue.main.async {
            self.viewContext.mergeChanges(fromContextDidSave: notification)
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
