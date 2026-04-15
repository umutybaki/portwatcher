import SwiftUI

struct SettingsView: View {
    @AppStorage("autoRefresh") private var autoRefresh = false
    @AppStorage("filterSystem") private var filterSystem = true
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("PortWatcher Preferences")
                .font(.headline)
            
            Toggle(isOn: $autoRefresh) {
                VStack(alignment: .leading) {
                    Text("Auto Refresh")
                    Text("Continuously poll for active ports every 5 seconds.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Toggle(isOn: $filterSystem) {
                VStack(alignment: .leading) {
                    Text("Filter System Processes")
                    Text("Hide common macOS background services (e.g. AirPlay).")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
        }
        .padding()
        .frame(width: 350, height: 200)
    }
}
