import Foundation

enum DevicePatchService {
    static func apply(project: PatchProject) throws -> PatchTransactionReceipt {
        var availableBundleIDs = Set<String>()
        var roots: [String: URL] = [:]
        
        let customBundleID = UserDefaults.standard.string(forKey: "TargetGameBundleID") ?? ""
        let originalBundleIDs = orderedBundleIdentifiers(in: project)
        
        for bundleID in originalBundleIDs {
            var actualBundleID = bundleID
            if !customBundleID.isEmpty && (bundleID == "com.dts.freefireth" || bundleID == "com.dts.freefiremax") {
                actualBundleID = customBundleID
            }
            if let path = ContainerStore.resolveAppContainerPath(bundleID: actualBundleID),
               ContainerStore.isApplicationContainerPath(path) {
                availableBundleIDs.insert(bundleID)
                roots[bundleID] = PatchPathValidator.canonicalFileURL(URL(fileURLWithPath: path, isDirectory: true))
            }
        }
        
        guard !availableBundleIDs.isEmpty else {
            throw PatchPackageError.targetAppUnavailable(originalBundleIDs.first ?? "unknown")
        }
        
        var filteredProject = project
        filteredProject.directories = project.directories.filter { availableBundleIDs.contains($0.bundleID) }
        filteredProject.rules = project.rules.filter { availableBundleIDs.contains($0.bundleID) }
        
        return try PatchTransaction.apply(
            project: filteredProject,
            backupRoot: try PatchProjectLibrary.backupRootURL(),
            containerResolver: { bundleID in
                guard let root = roots[bundleID] else {
                    throw PatchPackageError.targetAppUnavailable(bundleID)
                }
                return root
            }
        )
    }

    static func restore(receipt: PatchTransactionReceipt) throws {
        let originalBundleIDs = try PatchTransaction.requiredBundleIdentifiers(for: receipt)
        var availableBundleIDs = Set<String>()
        var roots: [String: URL] = [:]
        
        let customBundleID = UserDefaults.standard.string(forKey: "TargetGameBundleID") ?? ""
        
        for bundleID in originalBundleIDs {
            var actualBundleID = bundleID
            if !customBundleID.isEmpty && (bundleID == "com.dts.freefireth" || bundleID == "com.dts.freefiremax") {
                actualBundleID = customBundleID
            }
            if let path = ContainerStore.resolveAppContainerPath(bundleID: actualBundleID),
               ContainerStore.isApplicationContainerPath(path) {
                availableBundleIDs.insert(bundleID)
                roots[bundleID] = PatchPathValidator.canonicalFileURL(URL(fileURLWithPath: path, isDirectory: true))
            }
        }
        
        guard !availableBundleIDs.isEmpty else { return } // Nothing to restore if apps are gone
        
        try PatchTransaction.restore(
            receipt: receipt,
            containerResolver: { bundleID in
                guard let root = roots[bundleID] else {
                    throw PatchPackageError.targetAppUnavailable(bundleID)
                }
                return root
            }
        )
    }

    static func latestReceipt(projectID: UUID) -> PatchTransactionReceipt? {
        guard let backupRoot = try? PatchProjectLibrary.backupRootURL() else { return nil }
        return PatchTransaction.latestReceipt(projectID: projectID, backupRoot: backupRoot)
    }

    private static func orderedBundleIdentifiers(in project: PatchProject) -> [String] {
        project.allBundleIdentifiers
    }

    private static func withResolvedContainers<T>(
        bundleIDs: [String],
        operation: ([String: URL]) throws -> T
    ) throws -> T {
        var roots: [String: URL] = [:]

        for bundleID in bundleIDs {
            guard let path = ContainerStore.resolveAppContainerPath(bundleID: bundleID),
                  ContainerStore.isApplicationContainerPath(path) else {
                throw PatchPackageError.targetAppUnavailable(bundleID)
            }
            roots[bundleID] = PatchPathValidator.canonicalFileURL(URL(fileURLWithPath: path, isDirectory: true))
        }
        return try operation(roots)
    }
}
