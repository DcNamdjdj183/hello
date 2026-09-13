import SwiftUI

struct GameSelectorView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var apps: [InstalledApp] = []
    @State private var searchText = ""
    @AppStorage("TargetGameBundleID") private var targetGameBundleID: String = ""
    @AppStorage("TargetGameName") private var targetGameName: String = ""

    private var filteredApps: [InstalledApp] {
        if searchText.isEmpty {
            return apps
        }
        return apps.filter { $0.displayName.localizedCaseInsensitiveContains(searchText) }
    }

    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Current Target")) {
                    if targetGameBundleID.isEmpty {
                        Text("Default (Free Fire TH / MAX)")
                            .foregroundColor(.gray)
                    } else {
                        HStack {
                            VStack(alignment: .leading) {
                                Text(targetGameName.isEmpty ? targetGameBundleID : targetGameName)
                                    .font(.headline)
                                Text(targetGameBundleID)
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                            Spacer()
                            Button("Reset") {
                                targetGameBundleID = ""
                                targetGameName = ""
                            }
                            .foregroundColor(.red)
                        }
                    }
                }
                
                Section(header: Text("Available Apps")) {
                    ForEach(filteredApps, id: \.bundleID) { app in
                        Button(action: {
                            targetGameBundleID = app.bundleID
                            targetGameName = app.displayName
                            presentationMode.wrappedValue.dismiss()
                        }) {
                            HStack {
                                BrowserAppIcon(app: app)
                                VStack(alignment: .leading) {
                                    Text(app.displayName)
                                        .foregroundColor(.primary)
                                    Text(app.bundleID)
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Select Game")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing: Button("Cancel") {
                presentationMode.wrappedValue.dismiss()
            })
            .searchable(text: $searchText, prompt: "Search apps...")
            .onAppear {
                DispatchQueue.global(qos: .userInitiated).async {
                    let apiApps = ContainerStore.installedAppsFromAPI()
                    let dynamicIdentifiers = ContainerStore.dynamicAppIdentifiers()
                    let mcmApps = ContainerStore.installedAppsFromMCM(identifiers: dynamicIdentifiers)
                    
                    var seen = Set<String>()
                    var uniqueApps: [InstalledApp] = []
                    for app in (apiApps + mcmApps) {
                        if seen.insert(app.bundleID).inserted {
                            uniqueApps.append(app)
                        }
                    }
                    uniqueApps.sort { $0.displayName.localizedCaseInsensitiveCompare($1.displayName) == .orderedAscending }
                    
                    DispatchQueue.main.async {
                        self.apps = uniqueApps
                    }
                }
            }
        }
    }
}
